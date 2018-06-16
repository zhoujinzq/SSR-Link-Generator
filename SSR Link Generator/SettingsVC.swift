//
//  SettingsVC.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/06/10.
//  Copyright © 2018 Lei Gao. All rights reserved.
//

import Cocoa

protocol UserDefaultsChanged {
  func updateUI()
}

class SettingsVC: NSViewController {
  
  override func viewDidLoad() {
    
    super.viewDidLoad()
    populateMenus()
    loadDefaults()

  }
  
  @IBAction func addDropdownItem(_ sender: NSMenuItem) {
    let identifier = sender.identifier!.rawValue
    let view = NSView()
    
    menus.addItem(to: identifier, item: "")

  }
  
  @IBAction func saveSettingsClicked(_ sender: Any) {
    
    saveDefaults()
    delegate?.updateUI()

    dismiss(self)
  }
  
  
  @IBOutlet weak var startPort: NSTextField!
  @IBOutlet weak var group: NSTextField!
  @IBOutlet weak var serverName: NSTextField!
  @IBOutlet weak var obfsParameter: NSTextField!
  @IBOutlet weak var protocolParameter: NSTextField!
  @IBOutlet weak var protocolOptions: NSPopUpButton!
  @IBOutlet weak var encryptionMethods: NSPopUpButton!
  @IBOutlet weak var obfsOptions: NSPopUpButton!
  
  
  var menus = DropdownMenuItems()
  var delegate: UserDefaultsChanged?
  
}

extension SettingsVC {
  
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
    
  }
  
  func saveDefaults() {
    
    let defaults = UserDefaults.standard
    
    if let port = Int(startPort.stringValue) {
      
      defaults.set(String(port), forKey: "startPort")
      
    } else if startPort.stringValue == "" {
      
      defaults.set("", forKey: "startPort")
      
    } else {
      
      let alert = NSAlert()
      alert.messageText = "初始端口请输入数字"
      alert.alertStyle = .critical
      
      alert.runModal()
      
      return
    }
    
    defaults.set(serverName.stringValue, forKey: "serverName")
    defaults.set(group.stringValue, forKey: "group")
    defaults.set(obfsParameter.stringValue, forKey: "obfsParameter")
    defaults.set(protocolParameter.stringValue, forKey: "protocolParameter")
    defaults.set(obfsOptions.selectedItem?.title, forKey: "obfsOptions")
    defaults.set(protocolOptions.selectedItem?.title, forKey: "protocolOptions")
    defaults.set(encryptionMethods.selectedItem?.title,forKey: "encryptionMethods")
    
  }
  
  // Populate dropdown menu options from data model
  func populateMenus() {
    

    menus.encryptionMethods.forEach { encryptionMethods.addItem(withTitle: $0) }
    
    menus.obfsOpitons.forEach { obfsOptions.addItem(withTitle: $0) }
    
    menus.protocolOptions.forEach { protocolOptions.addItem(withTitle: $0) }
  }
  
  
}
