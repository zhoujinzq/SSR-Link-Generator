//
//  ViewController.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/01/01.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateMenus()
    
    /*
     This viewController is hard coded to load all 3 dropdown menus and other default values.
     So it ignores loadTable() function's parameter(used as dropdown menus' datasource).
     To fulfill function's requirement, a random array of strings is used here.
     */
    if defaults.integer(forKey: "autoFillOnNextRun") == 1 {
      loadTable(tableToShow: ["all"])
    }
    
  }
  
  override func viewWillDisappear() {
    
    // When auto fill on next run is turned on and app is about to be clsoed, save values to userDefaults
    if defaults.integer(forKey: "autoFillOnNextRun") == 1 {
      
      defaults.set(startPort.stringValue, forKey: "startPort")
      defaults.set(serverIP.stringValue, forKey: "serverIP")
      defaults.set(serverName.stringValue, forKey: "serverName")
      defaults.set(group.stringValue, forKey: "group")
      defaults.set(obfsParameter.stringValue, forKey: "obfsParameter")
      defaults.set(protocolParameter.stringValue, forKey: "protocolParameter")
      
      defaults.set(obfsOptions.titleOfSelectedItem, forKey: "selectedObfs")
      defaults.set(encryptionMethods.titleOfSelectedItem, forKey: "selectedEncryption")
      defaults.set(protocolOptions.titleOfSelectedItem, forKey: "selectedProtocol")
    }
  }
  
  @IBAction func generateLink(_ sender: Any) {
    
    // Clear result text first, so texts from last result won't get mixed with this one
    resultText.string = ""
    
    generateLink()
  }
  
  @IBAction func settingsMenuClicked(_ sender: Any) {
    performSegue(withIdentifier: "settings", sender: sender)
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
  @IBOutlet var passwords: NSTextView!
  @IBOutlet var resultText: NSTextView!
  
  let defaults = UserDefaults.standard
  
  // Encode string using base64 method
  func encodeString(_ string: String) -> String {
    
    let stringData = string.data(using: String.Encoding.ascii)
    let encodedString = stringData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    
    // To meet ssr link requirment, "=" marks are removed, and "/" marks are repalced with "_"
    var trimmedString = encodedString.replacingOccurrences(of: "=", with: "")
    trimmedString = encodedString.replacingOccurrences(of: "/", with: "_")
    return trimmedString
  }
  
  // Split passwords string into separate items, one per line
  func splitPasswords(_ passwords: String) -> [String] {
    
    var passwordsArray = [String]()
    
    // Line breaks in excel are \r\n, other text editors may vary
    if passwords.contains("\r\n") {
      
      passwords.split(separator: "\r\n").forEach {
        passwordsArray.append(String($0))
      }
      
    } else if passwords.contains("\r") {
      
      passwords.split(separator: "\r").forEach {
        passwordsArray.append(String($0))
      }
      
    } else if passwords.contains("\n") {
      
      passwords.split(separator: "\n").forEach {
        passwordsArray.append(String($0))
      }
      
      // If passwords field only contains one line
    } else {
      passwordsArray.append(passwords)
    }
    
    return passwordsArray
  }
  
  // Generate Links
  func generateLink() {
    
    // Conditions check
    guard serverIP.stringValue != "" else {
      createAlert("请输入服务器IP或域名")
      return
    }
    
    guard let startPort = Int(startPort.stringValue) else {
      createAlert("初始端口请输入数字")
      return
    }
    
    guard passwords.string != "" else {
      createAlert("请输入密码，每行一个")
      return
    }
    
    // For dispatchQueue to work, get out values from UI elements
    let passwordsString = passwords.string
    let selectedProtocolOption = protocolOptions.titleOfSelectedItem
    let selectedEncryption = encryptionMethods.titleOfSelectedItem
    let selectedObfs = obfsOptions.titleOfSelectedItem
    let obfsString = obfsParameter.stringValue
    let protocolString = protocolParameter.stringValue
    let remarkString = serverName.stringValue
    let groupString = group.stringValue
    let serverIPString = serverIP.stringValue
    
    // Doing the actual work, some string values in ssr link are base 64 encoded two times.
    DispatchQueue.global().async { [unowned self] in
      
      let passwordsArray = self.splitPasswords(passwordsString)
      
      var secondPart = (selectedProtocolOption)! + ":"
      secondPart += (selectedEncryption)! + ":"
      secondPart += (selectedObfs)! + ":"
      
      
      var thirdPart = "/?obfsparam="
      
      if obfsString != "" {
        thirdPart += self.encodeString(obfsString)
      }
      
      if protocolString != "" {
        thirdPart += "&protoparam="
        thirdPart += self.encodeString(protocolString)
      }
      
      if remarkString != "" {
        thirdPart += "&remarks="
        thirdPart += self.encodeString(remarkString)
      }
      
      if groupString != "" {
        thirdPart += "&group="
        thirdPart += self.encodeString(groupString)
      }
      
      var finalString = ""
      
      
      for (index, password) in passwordsArray.enumerated() {
        
        let string = serverIPString + ":" + String(startPort + index) + ":" + secondPart + self.encodeString(password) + thirdPart
        let trimmedString = self.encodeString(string)
        
        finalString.append("ssr://")
        finalString.append(trimmedString)
        finalString.append("\r")
      }
      
      DispatchQueue.main.async {
        self.resultText.string = finalString
      }
    }
  }
}

extension ViewController: ValueChanged {
  
  func loadTable(tableToShow: [String]) {
    
    serverIP.stringValue = defaults.string(forKey: "serverIP") ?? ""
    startPort.stringValue = defaults.string(forKey: "startPort") ?? ""
    serverName.stringValue = defaults.string(forKey: "serverName") ?? ""
    group.stringValue = defaults.string(forKey: "group") ?? ""
    obfsParameter.stringValue = defaults.string(forKey: "obfsParameter") ?? ""
    protocolParameter.stringValue = defaults.string(forKey: "protocolParameter") ?? ""
    
    // Select items in dropdown menus
    obfsOptions.selectItem(withTitle: defaults.string(forKey: "selectedObfs") ?? AppDelegate().obfsOptions.first!)
    protocolOptions.selectItem(withTitle: defaults.string(forKey: "selectedProtocol") ?? AppDelegate().protocolOptions.first!)
    encryptionMethods.selectItem(withTitle: defaults.string(forKey: "selectedEncryption") ?? AppDelegate().encryptionMethods.first!)
    
  }
  
  // Populate dropdown menu options from data model
  func populateMenus() {
    
    encryptionMethods.removeAllItems()
    obfsOptions.removeAllItems()
    protocolOptions.removeAllItems()
    // If those keys in userDefaults returns nil (say it's the 1st time app launches, we set
    // userDefaults in appDelegate, so this works anyway.
    defaults.array(forKey: "加密方式")?.forEach { encryptionMethods.addItem(withTitle: $0 as! String) }
    defaults.array(forKey: "混淆方式")?.forEach { obfsOptions.addItem(withTitle: $0 as! String) }
    defaults.array(forKey: "协议列表")?.forEach { protocolOptions.addItem(withTitle: $0 as! String) }
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
    /*
     In order to disable the minimize and resize button for settings view, we wrap its
     viewController in a window and set those behaviors in that window's attributes inspector
     */
    if segue.identifier == "settings" {
      let windowController = segue.destinationController as! NSWindowController
      let settingsVC = windowController.contentViewController as! SettingsVC
      settingsVC.delegate = self
    }
  }
}





