require "json"
require "net/http"

# App Store Connect API calls for submission prerequisites that `deliver`
# doesn't handle. Uses the token set by `app_store_connect_api_key`.
# `platform` arguments take the ASC API values (`IOS`, `MAC_OS`).
module ASCHelper
  UI = FastlaneCore::UI

  # Age rating questions that may stay unanswered. `socialMediaAgeRestricted`
  # becomes required once `socialMedia` is true.
  OPTIONAL_AGE_RATING_ATTRIBUTES = %w[
    developerAgeRatingInfoUrl
    gracRatingClassificationNumber
    kidsAgeBand
    socialMediaAgeRestricted
  ].freeze

  # App info states whose age rating can still change, most likely first.
  EDITABLE_APP_INFO_STATES = %w[PREPARE_FOR_SUBMISSION DEVELOPER_REJECTED REJECTED].freeze
  SUPERSEDED_APP_INFO_STATES = %w[READY_FOR_DISTRIBUTION REPLACED_WITH_NEW_INFO].freeze

  module_function

  # Returns [Net::HTTPResponse, parsed JSON or {}] without raising on HTTP errors.
  def raw_request(method, path, body = nil)
    token = Spaceship::ConnectAPI.token || UI.user_error!("No App Store Connect token. Run through a lane that calls app_store_connect_api_key.")
    token.refresh! if token.expired?

    uri = URI("https://api.appstoreconnect.apple.com/v1/#{path}")
    req = Net::HTTP.const_get(method.to_s.capitalize).new(uri)
    req["Authorization"] = "Bearer #{token.text}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate(body) if body

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    json = begin
      res.body.to_s.empty? ? {} : JSON.parse(res.body)
    rescue JSON::ParserError
      {} # e.g. an HTML 502/503 page
    end
    [res, json]
  end

  def request(method, path, body = nil)
    res, json = raw_request(method, path, body)
    return json if res.is_a?(Net::HTTPSuccess)

    details = json["errors"]&.to_json || res.body.to_s[0, 200]
    UI.user_error!("ASC API #{method.upcase} #{path} failed (#{res.code}): #{details}")
  end

  def app_id
    bundle_id = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
    Spaceship::ConnectAPI::App.find(bundle_id)&.id || UI.user_error!("App #{bundle_id} not found on App Store Connect.")
  end

  def find_app_store_version(app_id:, version_string:, platform:)
    request(:get, "apps/#{app_id}/appStoreVersions?filter[platform]=#{platform}&filter[versionString]=#{version_string}")["data"].first
  end

  def app_store_version(app_id:, version_string:, platform:)
    find_app_store_version(app_id: app_id, version_string: version_string, platform: platform) ||
      UI.user_error!("#{platform} App Store version #{version_string} not found. Run `make metadata-push VERSION=#{version_string}` first.")
  end

  # The most recently uploaded build of `version_string` on `platform`, or nil.
  # `attributes.version` is the build number Xcode Cloud assigned.
  def latest_build(app_id:, version_string:, platform:)
    request(:get, "builds?filter[app]=#{app_id}&filter[preReleaseVersion.version]=#{version_string}" \
                  "&filter[preReleaseVersion.platform]=#{platform}&sort=-uploadedDate&limit=1")["data"].first
  end

  # Warns about age rating questions that look unanswered. Apple adds required
  # questions from time to time, so this can't be exhaustive; the authoritative
  # answer comes from `explain_review_submission_errors` when a submission fails.
  def warn_unanswered_age_rating(app_id:)
    info = request(:get, "apps/#{app_id}/appInfos")["data"]
      .reject { |i| SUPERSEDED_APP_INFO_STATES.include?(i.dig("attributes", "state")) }
      .min_by { |i| EDITABLE_APP_INFO_STATES.index(i.dig("attributes", "state")) || EDITABLE_APP_INFO_STATES.size }
    return UI.important("No editable app info found; skipped the age rating check.") if info.nil?

    attributes = request(:get, "appInfos/#{info["id"]}/ageRatingDeclaration").dig("data", "attributes")
    missing = attributes.select { |key, value| value.nil? && !OPTIONAL_AGE_RATING_ATTRIBUTES.include?(key) }.keys
    missing << "socialMediaAgeRestricted" if attributes["socialMedia"] == true && attributes["socialMediaAgeRestricted"].nil?
    return UI.message("Age rating questions look answered.") if missing.empty?

    UI.important("These age rating questions look unanswered (App Information → Age Rating): #{missing.join(", ")}")
  end

  # App Review needs a contact for every version. The repository is public, so the
  # contact comes from `.env` (REVIEW_*) or is entered on App Store Connect.
  def warn_missing_review_contact(version:)
    detail = request(:get, "appStoreVersions/#{version["id"]}/appStoreReviewDetail")["data"]
    attributes = detail&.dig("attributes") || {}
    missing = %w[contactFirstName contactLastName contactPhone contactEmail].select { |key| attributes[key].to_s.empty? }
    return UI.message("App Review contact is set.") if missing.empty?

    UI.important("App Review contact is missing: #{missing.join(", ")}. Set REVIEW_* in .env and run `make metadata-push`, or enter it on App Store Connect (App Review Information).")
  end

  # `deliver` reports a rejected review item only by its title. Adding the version
  # to the draft submission again returns the per-field reasons
  # (meta.associatedErrors); print them so the fix is obvious. Called while
  # handling deliver's error, so it never raises and leaves the draft as it was.
  def explain_review_submission_errors(app_id:, version_string:, platform:)
    version = app_store_version(app_id: app_id, version_string: version_string, platform: platform)
    submission = request(:get, "apps/#{app_id}/reviewSubmissions?filter[platform]=#{platform}&filter[state]=READY_FOR_REVIEW")["data"].first
    return if submission.nil?

    # deliver adds the item before the final submit; if it is already there, the
    # failure came from that last step and adding it again would only say "exists".
    items = request(:get, "reviewSubmissions/#{submission["id"]}/items?include=appStoreVersion")["data"]
    if items.any? { |item| item.dig("relationships", "appStoreVersion", "data", "id") == version["id"] }
      return UI.important("#{platform} #{version_string} is already in draft review submission #{submission["id"]}, so the final submit step failed; see the error above. " \
                          "Remove the item (or cancel the draft) in App Store Connect before running submit_review again.")
    end

    res, json = raw_request(:post, "reviewSubmissionItems", {
      data: {
        type: "reviewSubmissionItems",
        relationships: {
          reviewSubmission: { data: { type: "reviewSubmissions", id: submission["id"] } },
          appStoreVersion: { data: { type: "appStoreVersions", id: version["id"] } },
        },
      },
    })
    if res.is_a?(Net::HTTPSuccess)
      # deliver refuses a draft that already has items, so take this one back out.
      removed, = raw_request(:delete, "reviewSubmissionItems/#{json.dig("data", "id")}")
      return UI.important("#{platform} #{version_string} passes the review item checks, so the failure happened before submission (e.g. build selection or export compliance); see the error above.") if removed.is_a?(Net::HTTPSuccess)

      return UI.important("#{platform} #{version_string} was added to draft review submission #{submission["id"]}. Remove it in App Store Connect before running submit_review again.")
    end

    errors = json["errors"] || []
    reasons = errors.flat_map { |error| (error.dig("meta", "associatedErrors") || {}).flat_map { |path, items| items.map { |e| "#{path}: #{e["detail"]}" } } }
    reasons = errors.map { |error| [error["title"], error["detail"]].compact.join(" ") } if reasons.empty?
    UI.error("App Store Connect did not accept #{platform} #{version_string} for review (#{res.code}):")
    reasons.each { |reason| UI.error("  - #{reason}") }
  rescue StandardError => e
    UI.important("Could not fetch the rejection reasons: #{e.message}. Check the draft review submission in App Store Connect.")
  end
end
