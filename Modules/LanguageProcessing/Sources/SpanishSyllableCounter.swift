import Foundation

public struct SpanishSyllableCounter: Sendable {
    public init() {}

    public func countSyllables(in word: String) -> Int {
        let letters = preprocess(word)
        guard !letters.isEmpty else { return 0 }
        var count = 0
        var index = 0

        while index < letters.count {
            if let v1 = vowelType(letters[index]) {
                var groupEnd = index
                var lastType = v1
                var next = index + 1
                while next < letters.count, let v2 = vowelType(letters[next]) {
                    if shouldMerge(lastType, v2) {
                        groupEnd = next
                        lastType = v2
                        next += 1
                    } else {
                        break
                    }
                }
                count += 1
                index = groupEnd + 1
            } else {
                index += 1
            }
        }

        return max(count, 1)
    }

    private func preprocess(_ word: String) -> [Character] {
        let lower = word.lowercased(with: Locale(identifier: "es_ES"))
        let chars = Array(lower)
        var result: [Character] = []
        var index = 0

        while index < chars.count {
            let current = chars[index]
            if current == "q", index + 2 < chars.count, chars[index + 1] == "u", isEorI(chars[index + 2]) {
                result.append("q")
                index += 2
                continue
            }
            if current == "g", index + 2 < chars.count, chars[index + 1] == "u", isEorI(chars[index + 2]) {
                if chars[index + 1] == "ü" {
                    result.append("g")
                    result.append("ü")
                    index += 2
                    continue
                }
                result.append("g")
                index += 2
                continue
            }
            if current == "h" {
                index += 1
                continue
            }
            result.append(current)
            index += 1
        }

        if let last = result.last, last == "y" {
            result[result.count - 1] = "i"
        }
        return result
    }

    private func isEorI(_ char: Character) -> Bool {
        char == "e" || char == "i" || char == "é" || char == "í"
    }

    private func shouldMerge(_ left: VowelType, _ right: VowelType) -> Bool {
        !(left == .strong && right == .strong)
    }

    private func vowelType(_ char: Character) -> VowelType? {
        switch char {
        case "a", "á", "e", "é", "o", "ó":
            return .strong
        case "i", "u", "ü", "y":
            return .weak
        case "í", "ú":
            return .strong
        default:
            return nil
        }
    }

    private enum VowelType {
        case strong
        case weak
    }
}
