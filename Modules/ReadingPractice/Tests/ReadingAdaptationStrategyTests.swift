import XCTest
@testable import ReadingPractice

final class ReadingAdaptationStrategyTests: XCTestCase {
    func testBaselineIncreasesWhenStableAndInTarget() {
        let config = ReadingAdaptationConfig(
            minWordsPerSegment: 1,
            maxWordsPerSegment: 5,
            initialWordCount: 2,
            targetWPMRange: 60...90,
            maxVarianceSeconds: 0.2,
            minComprehensionScore: 0.7,
            slidingWindowSize: 5,
            minSamplesBeforeIncrease: 2,
            maxStepChange: 1
        )
        let stats = ReadingPerformanceStats(
            averageWPM: 75,
            averageVarianceSeconds: 0.1,
            comprehensionAverage: 0.9,
            sampleCount: 3
        )
        let context = ReadingAdaptationContext(currentWordCount: 2, stats: stats, config: config)
        let strategy = BaselineAdaptiveStrategy()

        let next = strategy.proposeNextWordCount(context: context)
        XCTAssertEqual(next, 3)
    }

    func testBaselineDecreasesWhenInconsistent() {
        let config = ReadingAdaptationConfig(
            minWordsPerSegment: 1,
            maxWordsPerSegment: 5,
            initialWordCount: 3,
            targetWPMRange: 60...90,
            maxVarianceSeconds: 0.1,
            minComprehensionScore: 0.7,
            slidingWindowSize: 5,
            minSamplesBeforeIncrease: 2,
            maxStepChange: 1
        )
        let stats = ReadingPerformanceStats(
            averageWPM: 70,
            averageVarianceSeconds: 0.3,
            comprehensionAverage: 0.9,
            sampleCount: 3
        )
        let context = ReadingAdaptationContext(currentWordCount: 3, stats: stats, config: config)
        let strategy = BaselineAdaptiveStrategy()

        let next = strategy.proposeNextWordCount(context: context)
        XCTAssertEqual(next, 2)
    }

    func testFlowZoneDecreasesWhenWpmLow() {
        let config = ReadingAdaptationConfig(
            minWordsPerSegment: 1,
            maxWordsPerSegment: 5,
            initialWordCount: 3,
            targetWPMRange: 70...100,
            maxVarianceSeconds: 0.2,
            minComprehensionScore: 0.7,
            slidingWindowSize: 5,
            minSamplesBeforeIncrease: 2,
            maxStepChange: 1
        )
        let stats = ReadingPerformanceStats(
            averageWPM: 50,
            averageVarianceSeconds: 0.1,
            comprehensionAverage: 0.8,
            sampleCount: 3
        )
        let context = ReadingAdaptationContext(currentWordCount: 3, stats: stats, config: config)
        let strategy = FlowZoneAdaptiveStrategy()

        let next = strategy.proposeNextWordCount(context: context)
        XCTAssertEqual(next, 2)
    }

    func testSmootherClampsLargeJump() {
        let smoother = WordCountSmoother(maxStep: 1)
        let value = smoother.apply(current: 2, proposed: 5, minValue: 1, maxValue: 6)
        XCTAssertEqual(value, 3)
    }
}
