//
//  ViewController.swift
//  WebPay
//
//  Created by ifenghui on 2020/6/12.
//  Copyright © 2020 ifenghuI. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    var appWillBecomeActiveWebReloadUrlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let _ = navigationAction.request.url?.absoluteString else {
            return
        }
        
        
        guard let urlStr = navigationAction.request.url?.absoluteString.removingPercentEncoding else {
            return
        }
        
        guard let _ = navigationAction.request.url?.host else {
            decisionHandler(.allow)
            return
        }
        
        
        let request = navigationAction.request;
        
        if navigationAction.navigationType == WKNavigationType.backForward {
            // 返回不做以下处理
            decisionHandler(.allow)
            return
        }
        
        if (!(navigationAction.navigationType == WKNavigationType.backForward || navigationAction.navigationType == WKNavigationType.reload)) {
            let pre_string = "https://wx.tenpay.com/cgi-bin/mmpayweb-bin/checkmweb"
            if request.url?.absoluteString.hasPrefix(pre_string) ?? false {
                
                let par = WebPayTool.params(of: navigationAction.request.url)
                let params: NSMutableDictionary = NSMutableDictionary(dictionary:par);
                
                if var allKeys = params.allKeys as? [String] {
                    let ktx_app_name = "openWebResult.vistastory.com://KTX_paycallback/"
                    
                    let return_new_value = WebPayTool.urlDecodedString(ktx_app_name);
                    let returnKey = "redirect_url"
                    if (allKeys.contains { (item: String) -> Bool in
                        return item == returnKey
                    }) {
                        // 有对应的回调地址
                        let return_old_value = params[returnKey] as? String
                        let isOpenOther = return_old_value == return_new_value
                        if !isOpenOther {
                            // 保存回调地址
                            self.appWillBecomeActiveWebReloadUrlString = WebPayTool.urlDecodedString(return_old_value ?? "")
                            params[returnKey] = return_new_value;
                            allKeys.append(returnKey);
                            var newURLStr = NSString(format: "%@", pre_string)
                            for key in allKeys {
                                if let value = params[key] {
                                    newURLStr = NSString(format: "%@", newURLStr).urlAddCompnent(forValue: value as! String, key: key) as NSString
                                }
                            }
                            
                            if let newUrl = URL(string: newURLStr as String) {
                                decisionHandler(.cancel)
                                var newRequest = URLRequest.init(url: newUrl)
                                newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
                                webView.load(newRequest)
                                
                                return;
                            }
                        }
                    }
                }
            } else {
                if let url = request.url {
                    let urlString = url.absoluteString
                    
                    if urlString.hasPrefix("https://openapi.alipay.com/gateway.do") {
                        if let aliUrl = URL(string: urlString) {
                            let returnReloadKey = "return_url"
                            let par = WebPayTool.params(of: aliUrl)
                            let params: NSMutableDictionary = NSMutableDictionary(dictionary:par);
                            let return_old_value = params[returnReloadKey] as? String
                            let redirct = WebPayTool.urlDecodedString(return_old_value ?? "")
                            self.appWillBecomeActiveWebReloadUrlString = redirct
                        }
                    }
                }
                
                if let urlString = navigationAction.request.url?.absoluteString {
                    if urlString.contains("alipay://") || urlString.contains("alipays://"){
                        if urlString.contains("fromAppUrlScheme") {
                            decisionHandler(.cancel)
                            WebPayTool.handleWebUrl(urlString)
                            return
                        }
                    }
                }
            }
        }
        
        if HandlerSchema.isAppSchema(urlStr: urlStr) || navigationAction.request.url?.host == "itunes.apple.com" {
            decisionHandler(.cancel)
            guard let urlStrEncode = HandlerSchema.fetchSchemaWithOriSchema(oriSchema: urlStr) else {
                return
            }
            
            guard let url = URL(string: urlStrEncode) else { return }
            UIApplication.shared.openURL(url)
            return
        }
        
        decisionHandler(.allow)
    }
}

class HandlerSchema {
    static func isAppSchema(urlStr: String?) -> Bool {
        guard let urlStr = urlStr else { return false }
        let urlStrLower = urlStr.lowercased()
        if urlStrLower.hasPrefix("http://") || urlStrLower.hasPrefix("https://")
            || urlStrLower.hasPrefix("ftp://") || urlStr.hasPrefix("about:blank")
            || urlStr.hasPrefix("file://") {
            return false
        }
        return true
    }
    
    static func fetchSchemaWithOriSchema(oriSchema: String?) -> String? {
        guard let oriSchema = oriSchema else { return nil }
        let encodeSchema = oriSchema.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodeSchema
    }
}




