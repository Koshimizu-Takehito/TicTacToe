.PHONY: help open fastlane-setup metadata-pull metadata-push metadata-precheck submit-preflight submit-review

# Auto-load local environment variables (e.g. ASC_KEY_ID, ASC_ISSUER_ID)
# from `.env` if present. `.env` is gitignored; copy `.env.template` to start.
ifneq (,$(wildcard .env))
include .env
export
endif

# fastlane requires a UTF-8 locale.
export LC_ALL := en_US.UTF-8
export LANG := en_US.UTF-8

# ============================================================================
# Default target
# ============================================================================
help:
	@echo "Available commands:"
	@echo "  make open                                  - Open the workspace in Xcode"
	@echo ""
	@echo "App Store metadata and review (fastlane deliver; binaries come from Xcode Cloud):"
	@echo "  make fastlane-setup                        - Install fastlane and download current metadata from ASC"
	@echo "  make metadata-pull                         - Pull latest metadata & screenshots from ASC"
	@echo "  make metadata-precheck                     - Validate the metadata on ASC without uploading"
	@echo "  make metadata-push                         - Upload metadata, screenshots, and release notes to ASC"
	@echo "  make metadata-push VERSION=2.1.0           - Same, creating that App Store version if needed"
	@echo "  make submit-preflight VERSION=2.1.0        - Check versions, builds, and age rating without changing ASC"
	@echo "  make submit-review VERSION=2.1.0 [BUILD=n] - Submit the Xcode Cloud build for App Store review"
	@echo ""
	@echo "PLATFORM=ios|mac limits metadata-push, submit-preflight, and submit-review to one platform."

open:
	@open TicTacToe.xcworkspace

# ============================================================================
# App Store metadata (fastlane deliver)
# ============================================================================

fastlane-setup: ## Install fastlane and pull current metadata from App Store Connect
	@command -v bundle >/dev/null 2>&1 || (echo "❌ bundler is missing. Run: gem install bundler" && exit 1)
	@echo "📦 Installing fastlane via bundler..."
	@bundle install
	@echo "🔐 Verifying App Store Connect API credentials..."
	@test -n "$$ASC_KEY_ID"    || (echo "❌ ASC_KEY_ID is not set"    && exit 1)
	@test -n "$$ASC_ISSUER_ID" || (echo "❌ ASC_ISSUER_ID is not set" && exit 1)
	@test -f "$$ASC_KEY_PATH" || ls fastlane/AuthKey_*.p8 >/dev/null 2>&1 || (echo "❌ Set ASC_KEY_PATH or place fastlane/AuthKey_<KEYID>.p8" && exit 1)
	@echo "⬇️  Pulling current metadata & screenshots from App Store Connect..."
	@bundle exec fastlane pull
	@echo "✅ fastlane setup complete."

metadata-pull: ## Pull latest metadata & screenshots from App Store Connect
	@bundle exec fastlane pull

metadata-precheck: ## Validate the metadata on App Store Connect without uploading
	@bundle exec fastlane precheck_metadata $(if $(PLATFORM),platform:$(PLATFORM))

# VERSION / BUILD / PLATFORM pick what goes to App Store Connect, so accept them
# only from the command line: a value inherited from the shell or `.env` stops the target.
define require_cli_origin
@test "$(origin $(1))" = "undefined" -o "$(origin $(1))" = "command line" || \
	(echo "❌ $(1) comes from the $(origin $(1)); pass it on the command line instead (make $@ $(1)=...)" && exit 1)
endef

metadata-push: ## Upload metadata, screenshots, and release notes (no binary); VERSION=x.y.z creates that version
	$(call require_cli_origin,VERSION)
	$(call require_cli_origin,PLATFORM)
	@bundle exec fastlane push $(if $(VERSION),version:$(VERSION)) $(if $(PLATFORM),platform:$(PLATFORM))

submit-preflight: ## Check versions, builds, and age rating without changing ASC (VERSION=x.y.z)
	$(call require_cli_origin,VERSION)
	$(call require_cli_origin,PLATFORM)
	@test -n "$(VERSION)" || (echo "❌ VERSION is not set (e.g. VERSION=2.1.0)" && exit 1)
	@bundle exec fastlane submit_review_preflight version:$(VERSION) $(if $(PLATFORM),platform:$(PLATFORM))

submit-review: ## Submit an uploaded build for App Store review (VERSION=x.y.z, optional BUILD=n)
	$(call require_cli_origin,VERSION)
	$(call require_cli_origin,BUILD)
	$(call require_cli_origin,PLATFORM)
	@test -n "$(VERSION)" || (echo "❌ VERSION is not set (e.g. VERSION=2.1.0)" && exit 1)
	@bundle exec fastlane submit_review version:$(VERSION) $(if $(BUILD),build:$(BUILD)) $(if $(PLATFORM),platform:$(PLATFORM))
