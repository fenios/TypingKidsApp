import Foundation
import AppKit
import WebKit

@MainActor
public final class SVGRenderer: NSObject, SVGRendering {
    public override init() {}

    public func render(svgData: Data, targetSize: CGSize) async throws -> NSImage {
        guard let svgString = String(data: svgData, encoding: .utf8) else {
            throw ClipartImageError.svgRenderFailed
        }

        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <style>
            html, body { margin: 0; padding: 0; background: transparent; }
            svg { width: 100%; height: 100%; }
        </style>
        </head>
        <body>
        \(svgString)
        </body>
        </html>
        """

        let webView = WKWebView(frame: CGRect(origin: .zero, size: targetSize))
        webView.setValue(false, forKey: "drawsBackground")

        let delegate = WebViewLoadDelegate()
        webView.navigationDelegate = delegate
        webView.loadHTMLString(html, baseURL: nil)

        try await delegate.waitForLoad()

        let configuration = WKSnapshotConfiguration()
        configuration.snapshotWidth = NSNumber(value: Double(targetSize.width))
        let image = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<NSImage, Error>) in
            webView.takeSnapshot(with: configuration) { image, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let image {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: ClipartImageError.svgRenderFailed)
                }
            }
        }
        return image
    }
}

@MainActor
private final class WebViewLoadDelegate: NSObject, WKNavigationDelegate {
    private var continuation: CheckedContinuation<Void, Error>?

    func waitForLoad() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        continuation?.resume()
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
