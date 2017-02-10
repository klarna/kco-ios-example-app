import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var checkoutWebview: UIWebView!
    @IBOutlet weak var confirmationWebView: UIWebView!
    var checkout: KCOKlarnaCheckout?
    var snippetLoader: KCOSnippetLoader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkout = KCOKlarnaCheckout(viewController: self)
        checkout?.setWebView(checkoutWebview)
        snippetLoader = KCOSnippetLoader(webview: checkoutWebview)
        snippetLoader?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: NSNotification.Name.KCOSignal, object: nil)
        checkout?.notifyViewDidLoad()
        
        loadCheckoutUrl()
    }
    
    fileprivate func loadCheckoutUrl() {
        guard let url = URL(string: "https://www.klarnacheckout.com") else { return }
        let request = URLRequest(url: url)
        checkoutWebview.loadRequest(request)
    }
    
    func handleNotification(_ notification: Notification) {
        let name = notification.userInfo?[KCOSignalNameKey] as? String ?? ""
        let data = notification.userInfo?[KCOSignalDataKey] as? [AnyHashable: Any] ?? [:]
        
        if name == "complete" {
            if let dataDict = data[0] as? [String: AnyObject], let uriString = dataDict["uri"] as? String {
                handleCompletionUri(uriString)
            }
        }
    }
    
    fileprivate func handleCompletionUri(_ uriString: String) {
        if uriString != "" {
            if let url = URL(string: uriString) {
                let request = URLRequest(url: url)
                checkout?.setWebView(confirmationWebView)
                confirmationWebView.loadRequest(request)
            }
        }
    }
}

extension ViewController: KCOSnippetLoaderDelegate {
    func snippetLoader(snippetLoader: KCOSnippetLoader, loadedCheckout version: KCOCheckoutInfo) {
        //checkout?.setSnippet(version.snippet)
    }
}
