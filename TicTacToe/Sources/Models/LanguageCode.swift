/// 言語コード
enum LanguageCode: String, Hashable, CaseIterable {
    case ain
    case ang
    case ar
    case ca
    case cs
    case da
    case de
    case el
    case en
    case eo
    case es
    case fi
    case fr
    case fro
    case goh
    case he
    case hi
    case hr
    case hu
    case id
    case it
    case ja
    case ko
    case ms
    case nb
    case nl
    case pl
    case ptBR = "pt-BR"
    case ptPT = "pt-PT"
    case ro
    case ru
    case sk
    case sv
    case th
    case tr
    case uk
    case vi
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case zhHantTW = "zh-Hant-TW"
    case zhHK = "zh-HK"
}

extension LanguageCode {
    static var current: Self {
        LanguageCode(rawValue: String(localized: "LanguageCode")) ?? .en
    }
}
