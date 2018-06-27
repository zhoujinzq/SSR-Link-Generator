//
//  AddItemVC.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/20.
//  Copyright © 2018年 Dunce. All rights reserved.
//

import Cocoa

class AddItemVC: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /*
     Make sure delegation works, otherwise bail. If nothing goes wrong here,
     we can force unwrap all those optionals below.
     */
    if let delegate = delegate {
      currentArray = delegate.getCurrentArray!()
    } else {
      dismiss(self)
    }
    
    // Set currently working menu in arrayLabel, showed in red color
    arrayLabel.stringValue = tableLabel!
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue
    
    guard stringToAdd != "" else {
      createAlert("请填写要添加的选项值")
      return
    }
    
    // Check if value is existed in current array
    if currentArray.contains(stringToAdd) {
      createAlert("\(tableLabel!)中已存在\(stringToAdd)，请勿重复添加")
      return
    }
    
    // Check if user is adding a value which might be belong to other menus
    checkFromOthers(stringToAdd)
    
    // If we are still here, add the string into 'currentArray'
    currentArray.append(stringToAdd)
    
    // Update 'modifiedList' in settingsVC
    delegate?.addToTemporaryList!(key: tableLabel!, array: currentArray)
    delegate?.loadTable(tableToShow: currentArray)
    
    dismiss(self)
  }
  
  @IBOutlet weak var inputTextField: NSTextField!
  @IBOutlet weak var arrayLabel: NSTextField!
  
  var tableLabel: String?
  var currentArray = [String]()
  var delegate: ValueChanged?
  let defaults = UserDefaults.standard
  
  /*
   When calling this function, we have already made sure it only checks whether
   the value exists in arrays of OTHER names, since currentArray is checked
   beforehand. So we can save a lot of if statments here in implementation.
   */
  func checkFromOthers(_ stringToAdd: String) {
    
    let modifiedList = SettingsVC().modifiedList
    let appDelegate = AppDelegate()
    
    // Compare with 'modifiedList' first
    for (key, array) in modifiedList {
      if array.contains(stringToAdd) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "\(key)列表中已存在\(stringToAdd)，是否仍添加到\(tableLabel!)？"
        alert.addButton(withTitle: "取消")
        alert.addButton(withTitle: "仍然添加")
        alert.runModal()
        
        // If the value do exists in other array but the user still want to
        // add it to 'currentArray', we give them that option.
        alert.buttons[1].action = #selector(addAnyway(_:array:))
        
        return
      }
    }
    
    // If user hasn't modified other menus, check value with userDefaults
    var containedInDefaults = ""
    
    if appDelegate.protocolOptions.contains(stringToAdd) && modifiedList["协议列表"] == nil {
      containedInDefaults = "协议列表"
    }
    
    if appDelegate.obfsOptions.contains(stringToAdd) && modifiedList["混淆方式"] == nil {
      containedInDefaults = "混淆方式"
    }
    
    if appDelegate.encryptionMethods.contains(stringToAdd) && modifiedList["加密方式"] == nil {
      containedInDefaults = "加密方式"
    }
    
    if containedInDefaults != "" {
      
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "\(containedInDefaults)列表中已存在\(stringToAdd)，是否仍添加到\(tableLabel!)？"
      alert.addButton(withTitle: "取消")
      alert.addButton(withTitle: "仍然添加")
      alert.runModal()
      alert.buttons[1].action = #selector(addAnyway(_:array:))
      
      return
    }
  }
  
  @objc func addAnyway(_ string: String, array: [String]) -> [String] {
    
    var newArray = array
    newArray.append(string)
    return newArray
  }
}
