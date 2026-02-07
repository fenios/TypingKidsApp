import Foundation

public protocol StoryRepository {
    func loadStories() throws -> [Story]
}

public enum StoryRepositoryError: Error, LocalizedError {
    case resourceNotFound
    case decodingFailed

    public var errorDescription: String? {
        switch self {
        case .resourceNotFound: return "Stories resource not found."
        case .decodingFailed: return "Failed to decode stories."
        }
    }
}

public struct LocalStoryRepository: StoryRepository {
    private let bundle: Bundle

    public init(bundle: Bundle = .storiesModule) {
        self.bundle = bundle
    }

    public func loadStories() throws -> [Story] {
        guard let url = bundle.url(forResource: "stories", withExtension: "json") else {
            throw StoryRepositoryError.resourceNotFound
        }
        let data = try Data(contentsOf: url)
        guard let stories = try? JSONDecoder().decode([Story].self, from: data) else {
            throw StoryRepositoryError.decodingFailed
        }
        return stories
    }
}

private final class BundleToken {}

public extension Bundle {
    static var storiesModule: Bundle {
        Bundle(for: BundleToken.self)
    }
}
