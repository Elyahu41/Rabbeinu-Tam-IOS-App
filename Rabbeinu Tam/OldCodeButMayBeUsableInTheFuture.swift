//
//  OldCodeButMayBeUsableInTheFuture.swift
//  Rabbeinu Tam
//
//  Created by Elyahu on 1/15/23.
//

import Foundation

/*

let _acceptableCharacters = "0123456789."

@IBOutlet weak var webView: WKWebView!
@IBAction func getFromOnline(_ sender: Any) {
    webView.isHidden = false
    webView.load(URLRequest(url: URL(string: "https://bit.ly/3rhS55b")! as URL) as URLRequest)
    webView.navigationDelegate = self
    let alert = UIAlertController(title: "How to get info from chaitables.com", message: "(I recommend you visit the website first.) \n\n Choose your area and on the next page all you need to do is to fill out steps 1 and 2, and click the button on the bottom of the page to calculate the tables. \n\n Just make sure your search radius is big enough and the app will do the rest.", preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK!", style: .default) { (UIAlertAction) -> Void in
    }
    alert.addAction(alertAction)
    present(alert, animated: true)
    {
        () -> Void in
    }
}
@IBAction func cancelButton(_ sender: Any) {
    self.dismiss(animated: true)
}
@IBOutlet weak var textfield: UITextField!
@IBAction func onReturn() {
    let text = textfield.text ?? ""
    if (!text.isEmpty) {
        if CharacterSet(charactersIn: _acceptableCharacters).isSuperset(of: CharacterSet(charactersIn: text)) {
            NotificationCenter.default.post(name: NSNotification.Name("text"), object: text)
            self.dismiss(animated: true)
        } else {
            let alert = UIAlertController(title: "Invalid input", message: "Please only enter numbers and decimals! For example: 30.0", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK!", style: .default) { (UIAlertAction) -> Void in
            }
            alert.addAction(alertAction)
            present(alert, animated: true)
            {
                () -> Void in
            }
        }
    } else if webView.isHidden {
        let alert = UIAlertController(title: "Error", message: "Input cannot be empty!", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK!", style: .default) { (UIAlertAction) -> Void in
        }
        alert.addAction(alertAction)
        present(alert, animated: true)
        {
            () -> Void in
        }
    }
}

override func viewDidLoad() {
    super.viewDidLoad()
    self.textfield.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
}

func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    if (webView.url?.absoluteString.starts(with: "http://chaitables.com/cgi-bin/") == true) {
        let url = URL(string:assertCorrectURL(url: webView.url!.absoluteString))!
        do {
            let html = try String(contentsOf: url)
            let subString = html[html.index(of: ", height:")!..<html.index(of: "m</font></p>")!]
            let elevation = subString.replacingOccurrences(of: ", height:", with: "")
            NotificationCenter.default.post(name: NSNotification.Name("text"), object: elevation)
            self.dismiss(animated: true)
        } catch {
            print(error)
        }
    }
}

func assertCorrectURL(url: String) -> String {
    var url = url
    if (url.contains("&cgi_types=0")) {
         url = url.replacingOccurrences(of: "&cgi_types=0", with: "&cgi_types=5");
     } else if (url.contains("&cgi_types=1")) {
         url = url.replacingOccurrences(of: "&cgi_types=1", with: "&cgi_types=5");
     } else if (url.contains("&cgi_types=2")) {
         url = url.replacingOccurrences(of: "&cgi_types=2", with: "&cgi_types=5");
     } else if (url.contains("&cgi_types=3")) {
         url = url.replacingOccurrences(of: "&cgi_types=3", with: "&cgi_types=5");
     } else if (url.contains("&cgi_types=4")) {
         url = url.replacingOccurrences(of: "&cgi_types=4", with: "&cgi_types=5");
     } else if (url.contains("&cgi_types=-1")) {
         url = url.replacingOccurrences(of: "&cgi_types=-1", with: "&cgi_types=5");
     }
    return url
}

@objc func keyboardWillShow(notification: NSNotification) {
    if webView.isHidden {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    if self.view.frame.origin.y == 0 {
                        self.view.frame.origin.y -= keyboardSize.height
                    }
                }
    }
}

@objc func keyboardWillHide(notification: NSNotification) {
    if webView.isHidden {
        if self.view.frame.origin.y != 0 {
                    self.view.frame.origin.y = 0
                }
    }
}
}

import Foundation

extension StringProtocol {
func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.lowerBound
}
func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
    range(of: string, options: options)?.upperBound
}
func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
    ranges(of: string, options: options).map(\.lowerBound)
}
func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
    var result: [Range<Index>] = []
    var startIndex = self.startIndex
    while startIndex < endIndex,
        let range = self[startIndex...]
            .range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
    }
    return result
}
}
 */
