import Foundation

public protocol ClipartImageCaching: Sendable {
    func data(for url: URL) async -> Data?
    func store(_ data: Data, for url: URL) async
}

public actor DefaultClipartImageCache: ClipartImageCaching {
    private let memoryCache = NSCache<NSURL, NSData>()
    private let diskStore: DiskImageStore

    public init(diskStore: DiskImageStore = DiskImageStore()) {
        self.diskStore = diskStore
        memoryCache.countLimit = 200
    }

    public func data(for url: URL) async -> Data? {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached as Data
        }
        if let diskData = await diskStore.readData(for: url) {
            memoryCache.setObject(diskData as NSData, forKey: url as NSURL)
            return diskData
        }
        return nil
    }

    public func store(_ data: Data, for url: URL) async {
        memoryCache.setObject(data as NSData, forKey: url as NSURL)
        await diskStore.write(data, for: url)
    }
}
