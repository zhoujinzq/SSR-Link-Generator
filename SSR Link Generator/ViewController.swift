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
    
    passwords.placeholderAttributedString = NSAttributedString(string: passPlaceHolder, attributes: attrs)
    resultText.placeholderAttributedString = NSAttributedString(string: resultPlaceHolder, attributes: attrs)
    populateMenus()
    
    /*
     This viewController is hard coded to load all 3 dropdown menus and other textFields.
     So it ignores loadTable() function's parameter(used as a single dropdown menu's datasource).
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
  @IBOutlet var passwords: PlaceholderTextView!
  @IBOutlet var resultText: PlaceholderTextView!
  
  let defaults = UserDefaults.standard
  let attrs = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: NSColor.gray]
  let passPlaceHolder = "输入密码" + "\r" + "每行一个" + "\r" + "可直接复制粘贴"
  let resultPlaceHolder = """
        点击生成后会按照所选设置\r
        快速批量生成与密码数量相等的账号链接\r
        每行一个，可直接粘贴回excel等文档\r
        \r
        只要求服务器中端口连号\r
        \r
        例如初始端口设置10000，密码栏导入10行，则生成从10000到10010的账号链接
        """
  
  // Encode string using base64 method
  func encodeString(_ string: String) -> String {
    
    /*
     Swift 4.2 might have changed how closures work, if change below implementations to:
     1. create the string as a variable and keep modify its value until it's as what we want
     2. return that variable
		 Then it's gonna act weird when called in async closures, so, bunch of constants are used here.
 		*/
    let stringData = string.data(using: String.Encoding.ascii)
    let encodedString = stringData!.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    let replaceEqual = encodedString.replacingOccurrences(of: "=", with: "")
    let replaceSlash = replaceEqual.replacingOccurrences(of: "/", with: "_")
    return replaceSlash
    
  }
  
  // Split passwords string into separate items, one per line
  func splitPasswords(_ passwords: String) -> [String] {
    
    var passwordsArray = [String]()
    
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
      
    } else {
      // If passwords field only have one line
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
    
    guard let startPort = Int(self.startPort.stringValue) else {
      createAlert("初始端口请输入数字")
      return
    }
    
    guard passwords.string != "" else {
      createAlert("请输入密码，每行一个")
      return
    }
    
    // Can't access UI elements in background thread, so we have to get out their values
    let serverIPString = serverIP.stringValue
    let passwordsString = passwords.string
    let selectedProtocol = protocolOptions.titleOfSelectedItem!
    let selectedEncryption = encryptionMethods.titleOfSelectedItem!
    let selectedObfs = obfsOptions.titleOfSelectedItem!
    let obfsString = obfsParameter.stringValue
    let protocolString = protocolParameter.stringValue
    let remarkString = serverName.stringValue
    let groupString = group.stringValue
    
    // Doing the actual work
    DispatchQueue.global().async {
      
      let passwordsArray = self.splitPasswords(passwordsString)
      
      var secondPart = selectedProtocol + ":"
      secondPart += selectedEncryption + ":"
      secondPart += selectedObfs + ":"
      
      
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
      
      for (index, value) in passwordsArray.enumerated() {
        
        let string = serverIPString + ":" + String(startPort + index) + ":" + secondPart + self.encodeString(value) + thirdPart
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
  
  // Populate dropdown menu options from userDefaults
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





