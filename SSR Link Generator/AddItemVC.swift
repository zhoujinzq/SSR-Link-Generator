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
     we can safely force unwrap all those optionals below.
     */
    if let delegate = delegate {
      currentArray = delegate.getCurrentArray!()
    } else {
      dismiss(self)
    }
    
    // Append name of the currently editing menu in UI element
    arrayLabel.stringValue += tableName! + ":"
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue.lowercased()
    
    guard stringToAdd != "" else {
      createAlert(NSLocalizedString("Please type in the value you want to add", comment: "Please type in the value you want to add"))
      return
    }
    
    // Check if value is existed in current array
    if currentArray.contains(stringToAdd) {
      //      createAlert(NSLocalizedString("\(stringToAdd) is already in \(tableName!)", comment: "\(stringToAdd) is already in \(tableName!)"))
      
      let formatString = NSLocalizedString("%d is already in ", comment: "alert message")
      createAlert(String.localizedStringWithFormat(formatString, tableName!))
      return
    }
    /*
     Check if user is adding a value which might existed in other menus, in case
     they are making a mistake unintentionally and give them an alert.
     Since we have already checked the value with currentArray and bail if yes,
     here we are sure the code below will only check it with other arrays, so we
     can skip the code to find other 2 arrays rather than checking with all arrays.
     */
    if let arrayLabel = checkWithArrays(stringToAdd, with: currentArray) {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = NSLocalizedString("\(stringToAdd) is already in \(arrayLabel)，still add to \(tableName!)？", comment: "\(stringToAdd) is already in \(arrayLabel)，still add to \(tableName!)？")
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Add")
      // Set keyboard shortcut for Cancel button to be ESC, and enter for Add button
      alert.buttons[0].keyEquivalent = "\u{1b}"
      alert.buttons[1].keyEquivalent = "\r"
      
      alert.beginSheetModal(for: self.view.window!, completionHandler: { [ unowned self ] button in
        // If the value do exists in other array but the user still want to
        // add it to 'currentArray', we give them that option.
        if button == NSApplication.ModalResponse.alertSecondButtonReturn {
          self.addItem(stringToAdd, to: self.currentArray)
        }
      })
    } else {
      // If none of the above situation happens, we simply add the string into currentArray
      addItem(stringToAdd, to: currentArray)
    }
    
  }
  
  func checkWithArrays(_ stringToAdd: String, with array: [String]) -> String? {
    
    let modifiedList = SettingsVC().modifiedList
    
    // Compare with 'modifiedList' first
    for (key, array) in modifiedList {
      if array.contains(stringToAdd) {
        return key
      }
    }
    
    // If user hasn't modified other menus, check value with userDefaults
    let encryptions = defaults.array(forKey: "0") as! [String]
    
    let protocols = defaults.array(forKey: "1") as! [String]
    let obfs = defaults.array(forKey: "2") as! [String]
    
    if protocols.contains(stringToAdd) {
      return "Protocol Options"
    }
    
    if obfs.contains(stringToAdd) && modifiedList["Obfs Options"] == nil {
      return "Obfs Options"
    }
    
    if encryptions.contains(stringToAdd) && modifiedList["Encryption Options"] == nil {
      return "Encryption Options"
    }
    
    return nil
  }
  
  func addItem(_ string: String, to array: [String]) {
    
    var newArray = array
    newArray.append(string)
    delegate?.addToTemporaryList!(number: tableNumber!, array: newArray)
    delegate?.loadTable(tableToShow: newArray)
    dismiss(self)
  }
  
  @IBOutlet weak var arrayLabel: NSTextField!
  @IBOutlet weak var inputTextField: NSTextField!
  
  var tableNumber: Int?
  var tableName: String?
  var currentArray = [String]()
  var delegate: ValueChanged?
  let defaults = UserDefaults.standard
  
}
