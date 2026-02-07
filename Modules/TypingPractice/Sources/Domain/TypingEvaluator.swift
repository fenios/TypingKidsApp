import Foundation
import Core

public struct TypingEvaluator {
    public init() {}

    public func evaluate(target: String, typed: String, startedAt: Date, firstKeyAt: Date?, endedAt: Date) -> TypingMetrics {
        let reactionTime = max(0, (firstKeyAt ?? startedAt).timeIntervalSince(startedAt))
        let totalTime = max(0, endedAt.timeIntervalSince(startedAt))
        let errors = errorCount(target: target, typed: typed)
        return TypingMetrics(reactionTime: reactionTime, totalTime: totalTime, errorCount: errors)
    }

    private func errorCount(target: String, typed: String) -> Int {
        let targetChars = Array(target)
        let typedChars = Array(typed)
        let minCount = min(targetChars.count, typedChars.count)
        var errors = 0
        for index in 0..<minCount {
            if targetChars[index] != typedChars[index] { errors += 1 }
        }
        if typedChars.count > targetChars.count {
            errors += typedChars.count - targetChars.count
        } else if targetChars.count > typedChars.count {
            errors += targetChars.count - typedChars.count
        }
        return errors
    }
}
