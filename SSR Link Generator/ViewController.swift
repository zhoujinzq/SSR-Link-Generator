//
//  ViewController.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/01/01.
//  Copyright © 2018 Lei Gao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateMenus()
    loadDefaults()
  }

  @IBAction func generateLink(_ sender: Any) {
    resultText.string = ""
    generateLink()
    
  }
  
  @IBOutlet weak var generateLinkButton: NSButton!
  @IBOutlet weak var startPort: NSTextField!
  @IBOutlet weak var serverIP: NSTextField!
  @IBOutlet weak var serverName: NSTextField!
  @IBOutlet weak var obfsOptions: NSPopUpButton!
  @IBOutlet weak var obfsParameter: NSTextField!
  @IBOutlet weak var encryptionMethods: NSPopUpButton!
  @IBOutlet weak var protocolOptions: NSPopUpButton!
  @IBOutlet weak var protocolParameter: NSTextField!
  @IBOutlet weak var group: NSTextField!
  @IBOutlet var passwords: PlaceholderTextView!
  @IBOutlet var resultText: NSTextView!
  
  let menus = ConfigurationOptions()
  var delegate: SettingsVC?
  
  

  // Encode string using base64 method
  func encodeString(_ string: String) -> String {
    let stringData = string.data(using: String.Encoding.ascii)
    let encodedString = stringData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    let trimmedString = encodedString.replacingOccurrences(of: "=", with: "")
    return trimmedString
  }
  
  // Split passwords string into separate items, one per line
  func splitPasswords(_ passwords: String) -> [String] {
    
    var passwordsArray = [String]()
    
    if passwords.contains("\r\n") {
      
      for item in passwords.split(separator: "\r\n") {
        passwordsArray.append(String(describing: item))
      }
      
    } else if passwords.contains("\r") {
      
      for item in passwords.split(separator: "\r") {
        passwordsArray.append(String(describing: item))
      }
      
    } else if passwords.contains("\n") {
      
      for item in passwords.split(separator: "\n") {
        passwordsArray.append(String(describing: item))
      }

    } else {
      passwordsArray.append(passwords)
    }
    return passwordsArray
  }

  // Generate Links
  func generateLink() {
    
    // Conditions check
    guard serverIP.stringValue != "" else {
      makeAlert("请输入服务器IP或域名")
      return
    }
    
    guard let startPort = Int(self.startPort.stringValue) else {
      makeAlert("初始端口请输入数字")
      return
    }
    
    guard passwords.string != "" else {
      makeAlert("请输入密码，每行一个")
      return
    }
    
    // Doing the actual work
    let passwordsArray = splitPasswords(passwords.string)

    var secondPart = (protocolOptions.selectedItem?.title)! + ":"
    secondPart += (encryptionMethods.selectedItem?.title)! + ":"
    secondPart += (obfsOptions.selectedItem?.title)! + ":"
    
    
    var thirdPart = "/?obfsparam="
    
    if obfsParameter.stringValue != "" {
      thirdPart += encodeString(obfsParameter.stringValue)
    }
    
    if protocolParameter.stringValue != "" {
      thirdPart += "&protoparam="
      thirdPart += encodeString(protocolParameter.stringValue)
    }
    
    if serverName.stringValue != "" {
      thirdPart += "&remarks="
      thirdPart += encodeString(serverName.stringValue)
    }

    if group.stringValue != "" {
      thirdPart += "&group="
      thirdPart += encodeString(group.stringValue)
    }
    
    var finalString = ""

    for (index, value) in passwordsArray.enumerated() {
      
      let string = serverIP.stringValue + ":" + String(startPort + index) + ":" + secondPart + encodeString(value) + thirdPart
      let trimmedString = encodeString(string).replacingOccurrences(of: "/", with: "_")
      
      finalString.append("ssr://")
      finalString.append(trimmedString)
      finalString.append("\r")
    }
    
    resultText.string = finalString
  }
  
}

extension ViewController {
  
  func loadDefaults() {
    
    let defaults = UserDefaults.standard
    
    startPort.stringValue = defaults.string(forKey: "startPort") ?? ""
    serverName.stringValue = defaults.string(forKey: "serverName") ?? ""
    group.stringValue = defaults.string(forKey: "group") ?? ""
    obfsParameter.stringValue = defaults.string(forKey: "obfsParameter") ?? ""
    protocolParameter.stringValue = defaults.string(forKey: "protocolParameter") ?? ""
    
    obfsOptions.selectItem(withTitle: defaults.string(forKey: "obfsOptions") ?? menus.obfsOpitons.first!)
    protocolOptions.selectItem(withTitle: defaults.string(forKey: "protocolOptions") ?? menus.protocolOptions.first!)
    encryptionMethods.selectItem(withTitle: defaults.string(forKey: "encryptionMethods") ?? menus.encryptionMethods.first!)
    print("done")
  }
  
  
  // Populate dropdown menu options from data model
  func populateMenus() {
    menus.encryptionMethods.forEach { encryptionMethods.addItem(withTitle: $0) }
    
    menus.obfsOpitons.forEach { obfsOptions.addItem(withTitle: $0) }
    
    menus.protocolOptions.forEach { protocolOptions.addItem(withTitle: $0) }
  }
  
  func makeAlert(_ message: String) {
    let alert = NSAlert()
    
    alert.messageText = message
    alert.alertStyle = .critical
    
    alert.runModal()
  }
}


class PlaceholderTextView: NSTextView {
  @objc var placeholderAttributedString: NSAttributedString?
}
