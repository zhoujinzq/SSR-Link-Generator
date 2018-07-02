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
    
    // Set currently working menu in arrayLabel
    arrayLabel.stringValue += tableLabel! + ":"
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue.lowercased()
    
    guard stringToAdd != "" else {
      createAlert("Please type in the value you want to add")
      return
    }
    
    // Check if value is existed in current array
    if currentArray.contains(stringToAdd) {
      createAlert("\(stringToAdd) is already in \(tableLabel!)")
      return
    }
    /*
     Check if user is adding a value which might existed in other menus.
     Since we have already checked the value with currentArray and bail if yes,
     here we are sure the code below will only check it with other array So we
     can skip the code to varify if we are checking with current or other arrays.
     */
    let modifiedList = SettingsVC().modifiedList
    
    // Compare with 'modifiedList' first
    for (key, array) in modifiedList {
      if array.contains(stringToAdd) {
        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = "\(stringToAdd) is already in \(key)，still add to \(tableLabel!)？"
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Add")
        alert.runModal()
        
        // If the value do exists in other array but the user still want to
        // add it to 'currentArray', we give them that option.
        alert.buttons[1].action = #selector(addAnyway)
        
        return
      }
    }
    
    // If user hasn't modified other menus, check value with userDefaults
    var containedInDefaults = ""
    let protocols = defaults.array(forKey: "Protocol Options") as! [String]
    let encryptions = defaults.array(forKey: "Encryption Options") as! [String]
    let obfs = defaults.array(forKey: "Obfs Options") as! [String]
    
    if protocols.contains(stringToAdd) && modifiedList["Protocol Options"] == nil {
      containedInDefaults = "Obfs Options"
    }
    
    if obfs.contains(stringToAdd) && modifiedList["Obfs Options"] == nil {
      containedInDefaults = "Obfs Options"
    }
    
    if encryptions.contains(stringToAdd) && modifiedList["Encryption Options"] == nil {
      containedInDefaults = "Encryption Options"
    }
    
    if containedInDefaults != "" {
      
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "\(stringToAdd) is already in \(containedInDefaults), still add to \(tableLabel!)？"
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Add")
      alert.runModal()
      alert.buttons[1].action = #selector(addAnyway)
//      dismiss(self)
      return
    }
    
    // If we are still here, add the string into 'currentArray'
    currentArray.append(stringToAdd)
    
    // Update 'modifiedList' in settingsVC
    delegate?.addToTemporaryList!(key: tableLabel!, array: currentArray)
    delegate?.loadTable(tableToShow: currentArray)
    
    dismiss(self)
  }
  
  @IBOutlet weak var arrayLabel: NSTextField!
  @IBOutlet weak var inputTextField: NSTextField!
  //  @IBOutlet weak var arrayLabel: NSTextField!
  
  var tableLabel: String?
  var currentArray = [String]()
  var delegate: ValueChanged?
  let defaults = UserDefaults.standard
  
  @objc func addAnyway() {
    
    let stringToAdd = inputTextField.stringValue.lowercased()
    currentArray.append(stringToAdd)
    print(currentArray)
    delegate?.addToTemporaryList!(key: tableLabel!, array: currentArray)
    delegate?.loadTable(tableToShow: SettingsVC().modifiedList[tableLabel!]!)
    print(currentArray)
//    delegate.mo
//    var newArray = array
//    newArray.append(string)
//    return newArray
  }
}
