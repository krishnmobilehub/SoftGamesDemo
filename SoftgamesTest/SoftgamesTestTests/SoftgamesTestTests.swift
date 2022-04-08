//
//  SoftgamesTestTests.swift
//  SoftgamesTestTests
//

import XCTest
import WebKit

class SoftgamesTestTests: XCTestCase {
    
    let webView = WKWebView()
    var webViewExpectation: XCTestExpectation!
    
    func testName() throws {
        checkParameter(withKey: "Name", value: "First Last", endResult: "First Last")
    }
    
    func testAge() throws {
        checkParameter(withKey: "Age", value: "1996-11-30", endResult: "25")
    }
    
    func checkParameter(withKey key:String, value:String, endResult result:String) {
        webView.navigationDelegate = self
        if let url = Bundle.main.url(forResource: "task", withExtension: "html") {
            let stringURL = "\(url)?\(key)=\(value)"
            if let newURL = URL(string: stringURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) {
                let request = URLRequest(url: newURL)
                webView.load(request)
            }
        }
        webViewExpectation = expectation(description: "")
        wait(for: [webViewExpectation], timeout: 100)
        webView.evaluateJavaScript("document.getElementsByClassName('row')[0].querySelector('span').innerHTML") { (jsResult, error) in
            guard let value = jsResult as? String else {
                debugPrint(error as Any)
                return
            }
            XCTAssertEqual(value, result)
        }
    }
}
extension SoftgamesTestTests: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewExpectation.fulfill()
    }
}
