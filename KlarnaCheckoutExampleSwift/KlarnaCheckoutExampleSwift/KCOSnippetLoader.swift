import Foundation
import JavaScriptCore

protocol KCOSnippetLoaderDelegate: class {
    func snippetLoader(snippetLoader: KCOSnippetLoader, loadedCheckout version: KCOCheckoutInfo)
}

@objc protocol JavascriptProtocol: JSExport {
    func postMessage(_ message: String)
}

struct KCOCheckoutInfo {
    var snippet: String
    var url: URL
}

class KCOSnippetLoader: NSObject, JavascriptProtocol {
    
    private struct Constants {
        static let JavascriptContextKeyHandshake: NSString = "KCO_HANDSHAKE"
        static let HandshakeJSONKeyAction = "action"
        static let HandshakeJSONActionValueHandshake = "handshake"
        static let HandshakeJSONKeySnippet = "snippet"
    }
    
    private var webview: UIWebView
    private var webviewContext: JSContext?
    weak var delegate: KCOSnippetLoaderDelegate?
    
    init(webview: UIWebView) {
        self.webview = webview
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateContext), name: NSNotification.Name(rawValue: "KCOJavaScriptContextCreateNotification"), object: nil)
    }
    
    func didCreateContext(notification: NSNotification) {
        guard let jsContext = notification.userInfo?["KCOJavaScriptContextKey"] as? JSContext else {
            return
        }
        
        let cookieName = "kco_snippet_webview_\(self.webview.hash)"
        
        DispatchQueue.main.async(execute: { [weak self] in
            let _ = self?.webview.stringByEvaluatingJavaScript(from: "var \(cookieName) = '\(cookieName)'")
            
            if jsContext.objectForKeyedSubscript(cookieName).toString() == cookieName {
                self?.configureJSContext(jsContext: jsContext)
            }
        })
    }
    
    private func configureJSContext(jsContext: JSContext) {
        jsContext.setObject(self, forKeyedSubscript: Constants.JavascriptContextKeyHandshake)
    }
    
    func postMessage(_ message: String) {
        guard let data = message.data(using: .utf8), let handshake = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
            return
        }
        
        guard let handshakeAction = handshake?[Constants.HandshakeJSONKeyAction] as? String else {
            return
        }
        
        if handshakeAction == Constants.HandshakeJSONActionValueHandshake {
            guard let currentURLString = self.webview.stringByEvaluatingJavaScript(from: "window.location.href"),
                let currentURL = URL(string: currentURLString),
                let snippet = handshake?[Constants.HandshakeJSONKeySnippet] as? String else {
                return
            }
            let checkoutInfo = KCOCheckoutInfo(snippet: snippet, url: currentURL)
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                self?.delegate?.snippetLoader(snippetLoader: strongSelf, loadedCheckout: checkoutInfo)
            }
        }
    }
}
