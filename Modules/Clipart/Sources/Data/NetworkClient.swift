import Foundation

public struct NetworkResponse: Sendable {
    public let data: Data
    public let mimeType: String?

    public init(data: Data, mimeType: String?) {
        self.data = data
        self.mimeType = mimeType
    }
}

public protocol NetworkClient: Sendable {
    func fetch(_ url: URL) async throws -> NetworkResponse
}

public struct URLSessionNetworkClient: NetworkClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func fetch(_ url: URL) async throws -> NetworkResponse {
        let (data, response) = try await session.data(from: url)
        let mimeType = (response as? HTTPURLResponse)?.mimeType ?? response.mimeType
        return NetworkResponse(data: data, mimeType: mimeType)
    }
}
