import Foundation
import Core

public struct ReadingAdaptationConfig: Sendable, Equatable {
    public let minWordsPerSegment: Int
    public let maxWordsPerSegment: Int
    public let initialWordCount: Int
    public let targetWPMRange: ClosedRange<Double>
    public let maxVarianceSeconds: Double
    public let minComprehensionScore: Double
    public let slidingWindowSize: Int
    public let minSamplesBeforeIncrease: Int
    public let maxStepChange: Int

    public init(
        minWordsPerSegment: Int,
        maxWordsPerSegment: Int,
        initialWordCount: Int,
        targetWPMRange: ClosedRange<Double>,
        maxVarianceSeconds: Double,
        minComprehensionScore: Double,
        slidingWindowSize: Int,
        minSamplesBeforeIncrease: Int,
        maxStepChange: Int
    ) {
        self.minWordsPerSegment = minWordsPerSegment
        self.maxWordsPerSegment = maxWordsPerSegment
        self.initialWordCount = initialWordCount
        self.targetWPMRange = targetWPMRange
        self.maxVarianceSeconds = maxVarianceSeconds
        self.minComprehensionScore = minComprehensionScore
        self.slidingWindowSize = slidingWindowSize
        self.minSamplesBeforeIncrease = minSamplesBeforeIncrease
        self.maxStepChange = maxStepChange
    }

    /// Default parameters tuned for ages 7–10.
    /// Values are intentionally configurable to avoid hard-coded behavior and allow experimentation.
    public static func forAges7To10() -> ReadingAdaptationConfig {
        ReadingAdaptationConfig(
            minWordsPerSegment: 1,
            maxWordsPerSegment: 6,
            initialWordCount: 2,
            targetWPMRange: 60...100,
            maxVarianceSeconds: 0.18,
            minComprehensionScore: 0.7,
            slidingWindowSize: 5,
            minSamplesBeforeIncrease: 3,
            maxStepChange: 1
        )
    }
}

public struct ReadingPerformanceSample: Sendable, Equatable {
    public let wpm: Double
    public let varianceSeconds: Double
    public let comprehensionScore: Double?
    public let timestamp: Date

    public init(
        wpm: Double,
        varianceSeconds: Double,
        comprehensionScore: Double?,
        timestamp: Date = Date()
    ) {
        self.wpm = wpm
        self.varianceSeconds = varianceSeconds
        self.comprehensionScore = comprehensionScore
        self.timestamp = timestamp
    }

    /// Builds a performance sample from word timings.
    /// We use variance of per-word durations to represent consistency.
    public static func fromWordTimings(
        _ timings: [WordTiming],
        comprehensionScore: Double?
    ) -> ReadingPerformanceSample {
        let durations = timings.map { $0.duration }
        let totalTime = durations.reduce(0, +)
        let wpm = totalTime > 0 ? (Double(durations.count) / (totalTime / 60)) : 0
        let variance = ReadingPerformanceSample.variance(of: durations)
        return ReadingPerformanceSample(wpm: wpm, varianceSeconds: variance, comprehensionScore: comprehensionScore)
    }

    private static func variance(of values: [Double]) -> Double {
        guard values.count > 1 else { return 0 }
        let mean = values.reduce(0, +) / Double(values.count)
        let squared = values.map { pow($0 - mean, 2) }
        return squared.reduce(0, +) / Double(values.count)
    }
}

public struct ReadingPerformanceStats: Sendable, Equatable {
    public let averageWPM: Double
    public let averageVarianceSeconds: Double
    public let comprehensionAverage: Double?
    public let sampleCount: Int

    public init(
        averageWPM: Double,
        averageVarianceSeconds: Double,
        comprehensionAverage: Double?,
        sampleCount: Int
    ) {
        self.averageWPM = averageWPM
        self.averageVarianceSeconds = averageVarianceSeconds
        self.comprehensionAverage = comprehensionAverage
        self.sampleCount = sampleCount
    }
}

public struct ReadingPerformanceWindow: Sendable, Equatable {
    private(set) var samples: [ReadingPerformanceSample]
    private let maxSamples: Int

    public init(maxSamples: Int) {
        self.samples = []
        self.maxSamples = max(1, maxSamples)
    }

    public mutating func add(_ sample: ReadingPerformanceSample) {
        samples.append(sample)
        if samples.count > maxSamples {
            samples.removeFirst(samples.count - maxSamples)
        }
    }

    public mutating func reset() {
        samples.removeAll()
    }

    public var stats: ReadingPerformanceStats {
        guard !samples.isEmpty else {
            return ReadingPerformanceStats(averageWPM: 0, averageVarianceSeconds: 0, comprehensionAverage: nil, sampleCount: 0)
        }
        let avgWpm = samples.map(\.wpm).reduce(0, +) / Double(samples.count)
        let avgVar = samples.map(\.varianceSeconds).reduce(0, +) / Double(samples.count)
        let comprehensionValues = samples.compactMap(\.comprehensionScore)
        let comprehensionAverage = comprehensionValues.isEmpty ? nil : comprehensionValues.reduce(0, +) / Double(comprehensionValues.count)
        return ReadingPerformanceStats(
            averageWPM: avgWpm,
            averageVarianceSeconds: avgVar,
            comprehensionAverage: comprehensionAverage,
            sampleCount: samples.count
        )
    }
}

public struct ReadingAdaptationContext: Sendable, Equatable {
    public let currentWordCount: Int
    public let stats: ReadingPerformanceStats
    public let config: ReadingAdaptationConfig

    public init(currentWordCount: Int, stats: ReadingPerformanceStats, config: ReadingAdaptationConfig) {
        self.currentWordCount = currentWordCount
        self.stats = stats
        self.config = config
    }
}

public protocol ReadingAdaptationStrategy: Sendable {
    func proposeNextWordCount(context: ReadingAdaptationContext) -> Int
}

/// Baseline strategy that uses a sliding window for stability.
/// - Pedagogy: small, steady adjustments help children build confidence and avoid overwhelm.
public struct BaselineAdaptiveStrategy: ReadingAdaptationStrategy {
    public init() {}

    public func proposeNextWordCount(context: ReadingAdaptationContext) -> Int {
        let stats = context.stats
        let config = context.config
        let current = context.currentWordCount

        let comprehensionOk = (stats.comprehensionAverage ?? 1.0) >= config.minComprehensionScore
        let consistent = stats.averageVarianceSeconds <= config.maxVarianceSeconds
        let inTarget = config.targetWPMRange.contains(stats.averageWPM)

        // Prioritize comprehension and consistency before speed.
        if !comprehensionOk {
            return max(current - 1, config.minWordsPerSegment)
        }
        if !consistent {
            return max(current - 1, config.minWordsPerSegment)
        }

        guard stats.sampleCount >= config.minSamplesBeforeIncrease else {
            return current
        }

        if inTarget {
            return min(current + 1, config.maxWordsPerSegment)
        }

        if stats.averageWPM < config.targetWPMRange.lowerBound {
            // Reading is slow; reduce load to stabilize fluency.
            return max(current - 1, config.minWordsPerSegment)
        }

        return current
    }
}

/// Flow-zone strategy nudges the word count toward a target WPM band.
/// - Pedagogy: a gentle target band avoids pushing speed at the expense of comprehension.
public struct FlowZoneAdaptiveStrategy: ReadingAdaptationStrategy {
    public init() {}

    public func proposeNextWordCount(context: ReadingAdaptationContext) -> Int {
        let stats = context.stats
        let config = context.config
        let current = context.currentWordCount

        let comprehensionOk = (stats.comprehensionAverage ?? 1.0) >= config.minComprehensionScore
        if !comprehensionOk {
            return max(current - 1, config.minWordsPerSegment)
        }

        if stats.averageWPM < config.targetWPMRange.lowerBound {
            return max(current - 1, config.minWordsPerSegment)
        }

        if stats.averageWPM > config.targetWPMRange.upperBound {
            // If the student is already fast, keep load stable to protect comprehension.
            return current
        }

        if stats.averageVarianceSeconds <= config.maxVarianceSeconds {
            return min(current + 1, config.maxWordsPerSegment)
        }

        return current
    }
}

/// Combines baseline + flow zone by choosing the most conservative adjustment.
public struct CombinedReadingAdaptationStrategy: ReadingAdaptationStrategy {
    private let baseline: ReadingAdaptationStrategy
    private let flowZone: ReadingAdaptationStrategy

    public init(
        baseline: ReadingAdaptationStrategy = BaselineAdaptiveStrategy(),
        flowZone: ReadingAdaptationStrategy = FlowZoneAdaptiveStrategy()
    ) {
        self.baseline = baseline
        self.flowZone = flowZone
    }

    public func proposeNextWordCount(context: ReadingAdaptationContext) -> Int {
        let current = context.currentWordCount
        let baselineNext = baseline.proposeNextWordCount(context: context)
        let flowNext = flowZone.proposeNextWordCount(context: context)

        if baselineNext < current || flowNext < current {
            return min(baselineNext, flowNext)
        }
        if baselineNext > current && flowNext > current {
            return max(baselineNext, flowNext)
        }
        return current
    }
}

public struct WordCountSmoother: Sendable, Equatable {
    public let maxStep: Int

    public init(maxStep: Int) {
        self.maxStep = max(1, maxStep)
    }

    public func apply(current: Int, proposed: Int, minValue: Int, maxValue: Int) -> Int {
        let delta = proposed - current
        let clamped = min(max(delta, -maxStep), maxStep)
        let value = current + clamped
        return min(max(value, minValue), maxValue)
    }
}

public struct AdaptiveWordCountController: Sendable {
    private var window: ReadingPerformanceWindow
    private let config: ReadingAdaptationConfig
    private let strategy: ReadingAdaptationStrategy
    private let smoother: WordCountSmoother
    private var currentWordCount: Int

    public init(
        config: ReadingAdaptationConfig,
        strategy: ReadingAdaptationStrategy = CombinedReadingAdaptationStrategy()
    ) {
        self.config = config
        self.strategy = strategy
        self.smoother = WordCountSmoother(maxStep: config.maxStepChange)
        self.window = ReadingPerformanceWindow(maxSamples: config.slidingWindowSize)
        self.currentWordCount = config.initialWordCount
    }

    public mutating func reset() {
        window.reset()
        currentWordCount = config.initialWordCount
    }

    public mutating func register(sample: ReadingPerformanceSample) -> Int {
        window.add(sample)
        let context = ReadingAdaptationContext(
            currentWordCount: currentWordCount,
            stats: window.stats,
            config: config
        )
        let proposed = strategy.proposeNextWordCount(context: context)
        currentWordCount = smoother.apply(
            current: currentWordCount,
            proposed: proposed,
            minValue: config.minWordsPerSegment,
            maxValue: config.maxWordsPerSegment
        )
        return currentWordCount
    }

    public var wordCount: Int {
        currentWordCount
    }
}
