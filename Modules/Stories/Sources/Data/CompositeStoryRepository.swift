import Foundation

public actor CompositeStoryRepository: StoryRepository {
    private let localRepository: StoryRepository
    private let customRepository: CustomStoryRepository

    public init(localRepository: StoryRepository, customRepository: CustomStoryRepository) {
        self.localRepository = localRepository
        self.customRepository = customRepository
    }

    public func loadStories() async throws -> [Story] {
        var localStories: [Story] = []
        var customStories: [CustomStory] = []

        do {
            localStories = try await localRepository.loadStories()
        } catch {
            localStories = []
        }

        do {
            customStories = try await customRepository.loadStories()
        } catch {
            customStories = []
        }

        let combined = localStories + customStories.map(Story.init(customStory:))
        return combined.sorted {
            $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }
}
