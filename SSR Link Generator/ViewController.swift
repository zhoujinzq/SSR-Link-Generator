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
    startPort.stringValue = "9001"
    
  }

  @IBAction func generateLink(_ sender: Any) {
    resultText.stringValue = ""
    generateLink()
    
  }
  
  @IBOutlet weak var startPort: NSTextField!
  @IBOutlet weak var resultText: NSTextField!
  @IBOutlet weak var passwords: NSTextField!
  @IBOutlet weak var serverIP: NSTextField!
  @IBOutlet weak var serverName: NSTextField!
  @IBOutlet weak var obfsOptions: NSPopUpButton!
  @IBOutlet weak var obfsParameter: NSTextField!
  @IBOutlet weak var encryptionMethods: NSPopUpButton!
  @IBOutlet weak var protocolOptions: NSPopUpButton!
  @IBOutlet weak var protocolParameter: NSTextField!
  @IBOutlet weak var group: NSTextField!
  
  
  func populateMenus() {
    menus.encryptionMethods.forEach { encryptionMethods.addItem(withTitle: $0) }
    
    menus.obfsOpitons.forEach { obfsOptions.addItem(withTitle: $0) }
    
    menus.protocolOptions.forEach { protocolOptions.addItem(withTitle: $0) }
  }
  
  func encodeString(_ string: String) -> String {
    let stringData = string.data(using: String.Encoding.ascii)
    let encodedString = stringData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    let trimmedString = encodedString.replacingOccurrences(of: "=", with: "")
    return trimmedString
  }
  
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

  
  func generateLink() {
    
    var finalString = ""
    var passwordsCount = 0

    // Conditions check
    guard serverIP.stringValue != "" else {
      let alert = NSAlert()
      alert.messageText = "请输入服务器IP或域名"
      alert.alertStyle = .critical
      alert.runModal()
      
      return
    }
    
    guard var startPort = Int(self.startPort.stringValue) else {
      let alert = NSAlert()
      alert.messageText = "初始端口请输入数字"
      alert.alertStyle = .critical
      alert.runModal()
      
      return
    }
    
    guard passwords.stringValue != "" else {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "请输入密码，可直接复制粘贴"
      alert.runModal()
      
      return
    }
    
    let passwordsArray = splitPasswords(passwords.stringValue)
    
    for item in passwordsArray {
      var string = ""
      
      string.append(serverIP.stringValue + ":")
      
      string.append(String(startPort) + ":")
      string.append((protocolOptions.selectedItem?.title)! + ":")
      string.append((encryptionMethods.selectedItem?.title)! + ":")
      string.append((obfsOptions.selectedItem?.title)! + ":")
      
      let trimmedPassword = encodeString(item)
      string.append(trimmedPassword)
      
      string.append("/?obfsparam=")
      
      if obfsParameter.stringValue != "" || obfsOptions.selectedItem?.title != "plain" {
        let trimmedObfsString = encodeString(obfsParameter.stringValue)
        string.append(trimmedObfsString)
      }
      
      if protocolParameter.stringValue != "" {
        let trimmedObfsString = encodeString(protocolParameter.stringValue)
        string.append("&protoparam=")
        string.append(trimmedObfsString)
      }
      
      if serverName.stringValue != "" {
        let trimmedServerName = encodeString(serverName.stringValue)
        string.append("&remarks=")
        string.append(trimmedServerName)
      }
      
      if group.stringValue != "" {
        let trimmedGroup = encodeString(group.stringValue)
        string.append("&group=")
        string.append(trimmedGroup)
      }
      
      var trimmedString = encodeString(string)
      trimmedString = trimmedString.replacingOccurrences(of: "/", with: "_")
      
      finalString.append("ssr://")
      finalString.append(trimmedString)
      finalString.append("\r")
      passwordsCount += 1
      startPort += 1
      
      if passwordsCount >= passwordsArray.count {
        resultText.stringValue = finalString

        break
      }
      
    }
  }
  
  let menus = ConfigurationOptions()
}

