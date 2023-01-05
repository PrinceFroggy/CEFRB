//
//  ViewController.swift
//  CEFRB
//
//  Created by Andrew Solesa on 2020-10-16.
//

import Cocoa

class ViewController: NSViewController, NSComboBoxDelegate
{
    @IBOutlet weak var userNameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var forumComboBox: NSComboBox!
    @IBOutlet weak var threadsTextField: NSTextField!
    @IBOutlet weak var subjectTextField: NSTextField!
    @IBOutlet weak var messageTextField: NSTextField!
    @IBOutlet weak var spamButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    var isSpamming = false
    var spamTimer: Timer?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        preferredContentSize = view.frame.size
        
        self.forumComboBox.delegate = self
        self.progressBar.isIndeterminate = false
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear()
    {
        self.userNameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        self.forumComboBox.resignFirstResponder()
        self.threadsTextField.resignFirstResponder()
        self.spamButton.resignFirstResponder()
        self.view.window?.makeFirstResponder(self)
    }
    
    override var representedObject: Any?
    {
        didSet
        {
        // Update the view, if already loaded.
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification)
    {
        self.view.window?.makeFirstResponder(self)
    }
    
    @IBAction func spammingButtonClick(_ sender: NSButton)
    {
        if !self.userNameTextField.stringValue.isEmpty && !self.passwordTextField.stringValue.isEmpty && !self.forumComboBox.stringValue.isEmpty && !self.threadsTextField.stringValue.isEmpty && !self.subjectTextField.stringValue.isEmpty && !self.messageTextField.stringValue.isEmpty
        {
            if (!self.isSpamming)
            {
                self.isSpamming = true
                
                self.spamButton.title = "Stop Spamming"
                
                self.cheatEngineForumCookies()
                { (result) in

                    self.cheatEngineForumLogin(cookies: result)
                    { (result) in

                        self.progressBar.maxValue = Double(self.threadsTextField.stringValue)!
                        self.spamTimer = Timer.scheduledTimer(withTimeInterval: 25.0, repeats: true)
                        { timer in
                            
                            self.cheatEngineForumPost(cookies: result)
                            
                            self.progressBar.increment(by: 1)
                            
                            if self.progressBar.doubleValue == self.progressBar.maxValue
                            {
                                self.isSpamming = false
                                self.spamTimer!.invalidate()
                                self.progressBar.doubleValue = 0
                                
                                self.spamButton.title = "Start Spamming"
                            }
                        }
                        
                        self.spamTimer!.fire()
                    }
                }
            }
            else
            {
                self.isSpamming = false
                self.spamTimer!.invalidate()
                self.progressBar.doubleValue = 0
                
                self.spamButton.title = "Start Spamming"
            }
        }
    }
    
    func cheatEngineForumCookies(completion: @escaping ([String : String]) -> Void)
    {
        let request = WebApiRequest()
        
        request.httpMethod = "GET"
        
        let headers =
        [
            "Accept": "*/*",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive"
        ]

        request.httpHeaders = headers
        
        request.sendRequest(toUrlPath: "https://forum.cheatengine.org/", completion:
        { (result: String, headers: [String : String]) in
            
            var cookieArray = [String : String]()
            
            let cookieJar = HTTPCookieStorage.shared
            
            for cookie in cookieJar.cookies!
            {
                if cookie.name == "phpbb2mysql_data" || cookie.name == "phpbb2mysql_sid"
                {
                    cookieArray[cookie.name] = "\(cookie.value)"
                }
            }
            
            completion(cookieArray)
        })
    }
    
    func cheatEngineForumLogin(cookies: [String : String], completion: @escaping ([String : String]) -> Void)
    {
        let request = WebApiRequest()
        
        let phpbb2mysqldata = cookies["phpbb2mysql_data"]
        let phpbb2mysqlsid = cookies["phpbb2mysql_sid"]
        
        request.httpMethod = "POST"
        
        let body = HTTPUtils.formUrlencode([
            "username": self.userNameTextField.stringValue,
            "password": self.passwordTextField.stringValue,
            "redirect": "",
            "login": "Log+in"
        ])
        
        let headers =
        [
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "max-age=0",
            "Origin": "https://forum.cheatengine.org",
            "Referer": "https://forum.cheatengine.org/index.php",
            "upgrade-insecure-requests": "1",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
            "Cookie": "phpbb2mysql_data=\(phpbb2mysqldata!); phpbb2mysql_sid=\(phpbb2mysqlsid!);",
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-Length": String(body.data(using: .utf8)!.count)
        ]
        
        request.httpHeaders = headers
        
        request.httpBody = body.data(using: .utf8)
        
        request.sendRequest(toUrlPath: "https://forum.cheatengine.org/login.php", completion:
        { (result: String, headers: [String : String]) in
            
            completion(cookies)
        })
    }
    
    func cheatEngineForumPost(cookies: [String : String])
    {
        let request = WebApiRequest()
        
        let phpbb2mysqldata = cookies["phpbb2mysql_data"]
        let phpbb2mysqlsid = cookies["phpbb2mysql_sid"]
        var phpbb2mysql_t: String?
        var f: String?
        
        switch(self.forumComboBox.stringValue)
        {
        case "Random Spam":
            phpbb2mysql_t = "a%3A2%3A%7Bi%3A620391%3Bi%3A1672893381%3Bi%3A620392%3Bi%3A1672893443%3B%7D"
            f = "16"
            break
            
        case "Horse Excrement":
            phpbb2mysql_t = "a%3A1%3A%7Bi%3A615711%3Bi%3A1602890020%3B%7D"
            f = "131"
            break
            
        default:
            break
        }
        
        request.httpMethod = "POST"
        
        let boundaryRandomValue = Date().ticks
        
        var bodyData = Data()
        
        let threadVariables:[String:String] =
            [
                "subject":self.subjectTextField.stringValue,
                "addbbcodefontcolor":"#444444",
                "addbbcodefontsize":"0",
                "helpbox":"Close all open bbCode tags",
                "message":self.messageTextField.stringValue,
                "attach_sig":"on",
                "add_attachment_body":"0",
                "posted_attachments_body":"0",
                "fileupload":"(binary)",
                "filecomment":"",
                "poll_title":"",
                "add_poll_option_text":"",
                "poll_length":"",
                "mode":"newtopic",
                "sid":phpbb2mysqlsid!,
                "f":f!,
                "post":"Submit"
            ]
        
        let boundary = "------WebKitFormBoundary\(boundaryRandomValue)"
        let header = "\(boundary)\r\n"
        let footer = "\(boundary)--\r\n"
        
        for (key, value) in threadVariables
        {
            bodyData.append(header.data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\n".data(using: .utf8)!)
            bodyData.append(value.data(using: .utf8)!)
            bodyData.append("\n".data(using: .utf8)!)
        }
        
        bodyData.append(footer.data(using: .utf8)!)
        
        request.httpBody = bodyData
        
        let headers =
        [
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3",
            "Accept-Language": "en-US,en;q=0.9",
            "Cache-Control": "max-age=0",
            "Origin": "https://forum.cheatengine.org",
            "Referer": "https://forum.cheatengine.org/posting.php?mode=newtopic&f=131",
            "upgrade-insecure-requests": "1",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36",
            "Cookie": "phpbb2mysql_t=\(phpbb2mysql_t!); phpbb2mysql_data=\(phpbb2mysqldata!); phpbb2mysql_sid=\(phpbb2mysqlsid!);",
            "Content-Type": "multipart/form-data; boundary=----WebKitFormBoundary\(boundaryRandomValue)",
            "Content-Length": String(bodyData.count)
        ]
        
        request.httpHeaders = headers
        
        request.sendRequest(toUrlPath: "https://forum.cheatengine.org/posting.php", completion:
        { (result: String, headers: [String : String]) in
            
        })
    }
}

extension String
{
    static let formUrlencodedAllowedCharacters =
        CharacterSet(charactersIn: "0123456789" +
            "abcdefghijklmnopqrstuvwxyz" +
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
            "-._* ")

    public func formUrlencoded() -> String
    {
        let encoded = addingPercentEncoding(withAllowedCharacters: String.formUrlencodedAllowedCharacters)
        return encoded?.replacingOccurrences(of: " ", with: "+") ?? ""
    }
}

class HTTPUtils
{
    public class func formUrlencode(_ values: [String: String]) -> String
    {
        return values.map
        { key, value in
            return "\(key.formUrlencoded())=\(value.formUrlencoded())"
        }.joined(separator: "&")
    }
}

extension Date
{
    var ticks: UInt64
    {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

//GOOMBA :)

