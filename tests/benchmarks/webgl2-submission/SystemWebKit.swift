import AppKit
import WebKit

// Run the same benchmark page with the WebKit framework installed on this Mac.
func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
}

final class Benchmark: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
    let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
                          styleMask: .titled, backing: .buffered, defer: false)
    let capture: URL?

    init(url: URL, capture: URL?) {
        self.capture = capture
        super.init()
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        let controller = configuration.userContentController
        controller.add(self, name: "benchmark")
        let script = """
            const result = document.querySelector("#result");
            const report = () => {
              if (!result?.dataset.status) return;
              observer.disconnect();
              window.webkit.messageHandlers.benchmark.postMessage({
                status: result.dataset.status, text: result.textContent, png: window.benchmarkCapture ?? ""
              });
            };
            const observer = new MutationObserver(report);
            if (result) observer.observe(result, {attributes: true, childList: true, subtree: true});
            report();
            """
        controller.addUserScript(WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        let view = WKWebView(frame: window.contentView!.bounds, configuration: configuration)
        window.contentView = view
        window.title = "Galacean rendering benchmark"
        window.orderBack(nil)
        view.navigationDelegate = self
        view.load(URLRequest(url: url))
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let result = message.body as? [String: String], let text = result["text"] else {
            fail("Invalid benchmark result")
        }
        guard result["status"] == "complete" else { fail(text) }
        if let capture {
            guard let png = result["png"], !png.isEmpty, let bytes = Data(base64Encoded: png) else {
                fail("The benchmark returned an empty capture")
            }
            do { try bytes.write(to: capture, options: .atomic) } catch { fail(error.localizedDescription) }
        }
        print(text)
        exit(0)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        fail(error.localizedDescription)
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { fail("WebKit content process terminated") }
}

let args = CommandLine.arguments
guard (2...3).contains(args.count), var location = URLComponents(string: args[1]) else {
    fail("Usage: SystemWebKit <benchmark-url> [capture.png]")
}
let capture = args.count == 3 ? URL(fileURLWithPath: args[2]) : nil
if capture != nil { location.queryItems = (location.queryItems ?? []) + [URLQueryItem(name: "capture", value: "1")] }
guard let url = location.url else { fail("Invalid benchmark URL") }
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let benchmark = Benchmark(url: url, capture: capture)
DispatchQueue.main.asyncAfter(deadline: .now() + 180) { fail("Benchmark timed out") }
app.run()
