//
//  BrowserViewController.swift
//  FashionStore
//
//  Created by Carlos Jimenez on 2021-04-12.
//  Copyright © 2021 Klarna. All rights reserved.
//

import UIKit
import WebKit
import KlarnaCheckoutSDK

class BrowserViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var contentView: UIView!

    var webView: WKWebView?
    var checkout: KCOKlarnaCheckout?

    var currentURL: String = "https://www.klarna.com/demo"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "iOS SDK Sample App"

        loadNavigationHeader()
        loadWebView()
        loadKlarnaCheckout()

        loadURL(currentURL)
    }

    func loadNavigationHeader() {
        urlTextField.delegate = self

    }

    func loadWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.websiteDataStore = .nonPersistent()
        
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.scrollView.bounces = false

        self.contentView.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 0).isActive = true
        webView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: 0).isActive = true
        webView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive = true
        webView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive = true

        self.webView = webView
    }

    func loadKlarnaCheckout() {
        if let klarnaCheckout = KCOKlarnaCheckout(
            viewController: self,
            return: URL(string: "fashionstore://")) {
            klarnaCheckout.setWebView(webView)

            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleKlarnaCheckout),
                name: NSNotification.Name.KCOSignal,
                object: nil
            )

            klarnaCheckout.notifyViewDidLoad()
            self.checkout = klarnaCheckout
        }
    }

    func loadURL(_ url: String) {
        currentURL = url
        if !currentURL.starts(with: "http://") && !currentURL.starts(with: "https://") {
            currentURL = "http://\(currentURL)"
        }
        if let url: URL = URL(string: currentURL) {
            let urlRequest: URLRequest = URLRequest(url: url)
            self.webView?.load(urlRequest)
            urlTextField.text = currentURL
        }
    }

    @IBAction func goButtonClicked(_ sender: Any) {
        urlTextField.resignFirstResponder()
        loadURL(urlTextField.text ?? "")
    }

    @objc func handleKlarnaCheckout(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let name = userInfo[KCOSignalNameKey] as? String,
              let data = userInfo[KCOSignalDataKey] as? NSDictionary,
              name == "complete",
              let uri = data["uri"] as? String,
              let url = URL(string: uri) else {
            return
        }

        webView?.load(URLRequest(url: url))
    }


}

extension BrowserViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlTextField.resignFirstResponder()
        loadURL(urlTextField.text ?? "")
        return true
    }
}
