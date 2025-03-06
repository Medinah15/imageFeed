//
//  WebViewViewController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 20.02.25.
//

import UIKit
@preconcurrency import WebKit

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let accessKey = AccessKey
    static let secretKey = SecretKey
    static let redirectURI = RedirectURI 
    static let accessScope = AccessScope 
}


protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var webView: WKWebView!
    
    @IBOutlet private var progressView: UIProgressView!

    weak var delegate: WebViewViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        loadAuthView()
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("❌ Ошибка: не удалось создать URLComponents")
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "response_type", value:  "code"),
            URLQueryItem(name: "scope", value: AccessScope)
        ]
        
        guard let url = urlComponents.url else {
            print("❌ Ошибка: не удалось создать URL из URLComponents")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // NOTE: Since the class is marked as `final` we don't need to pass a context.
        // In case of inhertiance context must not be nil.
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
         let baseURL = URL(string: "https://unsplash.com")!
         let url = URL(
             string: "/oauth/token"
             + "?client_id=\(AccessKey)"         // Используем знак ?, чтобы начать перечисление
             + "&client_secret= \(SecretKey)"    // Используем &&, чтобы добавить дополнительные па
             + "&redirect_uri= \(RedirectURI)"
             + "&code=\(code)"
             + "&grant_type=authorization_code",
             relativeTo:  DefaultBaseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
         )!
        var request = URLRequest(url: url)
         request.httpMethod = "POST"
         return request
     }
}
    
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
         if let code = code(from: navigationAction) { //1
             delegate?.webViewViewController(self, didAuthenticateWithCode: code)                   //2
                decisionHandler(.cancel) //3
          } else {
                decisionHandler(.allow) //4
            }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,                         //1
            let urlComponents = URLComponents(string: url.absoluteString),  //2
            urlComponents.path == "/oauth/authorize/native",                //3
            let items = urlComponents.queryItems,                           //4
            let codeItem = items.first(where: { $0.name == "code" })        //5
        {
            return codeItem.value                                           //6
        } else {
            return nil
        }
    }
}

