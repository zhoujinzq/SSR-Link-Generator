//
//  ViewController.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/01/01.
//  Copyright © 2018 Lei Gao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBAction func generateLink(_ sender: Any) {
        resultText.stringValue = ""
        generateLink()
        
    }
    
    @IBOutlet weak var startPort: NSTextField!
    @IBOutlet weak var resultText: NSTextField!
    @IBOutlet weak var passwords: NSTextField!
    @IBOutlet weak var serverIP: NSTextField!
    @IBOutlet weak var serverName: NSTextField!
    
    func trimString(string: String) -> String {
        let newString = string.replacingOccurrences(of: "=", with: "")
        return newString
    }
    func generateLink() {
        var array = [String]()
        var numberCount = 0
        
        let strings = passwords.stringValue
        
        for item in strings.split(separator: "\r\n") {
            array.append(String(describing: item))
        }
        print(array)
        let ServerNameString = serverName.stringValue
        let encodedServerNameData = (ServerNameString).data(using: String.Encoding.ascii)
        let encodedServerNameString = encodedServerNameData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let trimmedServerName = trimString(string: encodedServerNameString)
        var startPort = Int(self.startPort.stringValue)!
        var finalString = ""
        for item in array {
            var encodedString = ""
            encodedString.append(serverIP.stringValue)
            encodedString.append(":")
            encodedString.append(String(startPort))
            encodedString.append(":auth_chain_a:none:plain:")
            let encodedPasswordData = (item).data(using: String.Encoding.ascii)
            let encodedPasswordString = encodedPasswordData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let trimmedPassword = trimString(string: encodedPasswordString)
            encodedString.append(trimmedPassword)
            encodedString.append("/?obfsparam=&remarks=")
            encodedString.append(trimmedServerName)
            encodedString.append("&group=")
            
            let stringData = (encodedString).data(using: String.Encoding.ascii)
            let string = stringData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let trimmedString = trimString(string: string).replacingOccurrences(of: "/", with: "_")
            
                
            finalString.append("ssr://")
            finalString.append(trimmedString)
            finalString.append("\r")
            numberCount += 1
            startPort += 1
            
            
            
            if numberCount >= array.count {
                resultText.stringValue = finalString
                
                break
            }
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

