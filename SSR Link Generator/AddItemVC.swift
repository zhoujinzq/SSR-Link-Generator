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
    arrayLabel.stringValue += 	listNames![currentListNumber!] + ":"
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue.lowercased()
    
    guard stringToAdd != "" else {
      createAlert(NSLocalizedString("Please type in the value you want to add", comment: "Please type in the value you want to add"))
      return
    }
    
    // Check if value is existed in current array
    if currentArray.contains(stringToAdd) {
      
      let formatString = NSLocalizedString("%d is already in %d", comment: "alert message")
      createAlert(String.localizedStringWithFormat(formatString, stringToAdd, listNames![currentListNumber!]))
      return
    }
    /*
     Check if user is adding a value which might existed in other menus, in case
     they are making a mistake unintentionally and give them an alert.
     Since we have already checked the value with currentArray and bail if yes,
     here we are sure the code below will only check it with other arrays, so we
     can skip the code to find other 2 arrays rather than checking with all arrays.
     */
    if let arrayNumber = checkWithArrays(stringToAdd) {
      let alert = NSAlert()
      alert.alertStyle = .critical
      let formatString = NSLocalizedString("%d is already in %d, still add to %d?", comment: "already in another array")
      let arrayLabel = listNames![arrayNumber]
      
      alert.messageText = String.localizedStringWithFormat(formatString, stringToAdd, arrayLabel, listNames![currentListNumber!])
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
      // If none of the above situation happens, we add the string into currentArray and update modifedList
      addItem(stringToAdd, to: currentArray)
    }
    
  }
  
  func checkWithArrays(_ stringToAdd: String) -> Int? {
    
    // Compare with 'modifiedList' first
    for (key, array) in modifiedList! {
      if array.contains(stringToAdd) {
        let number = Int(key)!
        return number
      }
    }
    
    // If user hasn't modified other menus, check value with userDefaults
    let encryptions = defaults.array(forKey: "0") as! [String]
    let protocols = defaults.array(forKey: "1") as! [String]
    let obfs = defaults.array(forKey: "2") as! [String]
    
    if encryptions.contains(stringToAdd) && modifiedList?["0"] == nil {
      return 0
    }
    
    if protocols.contains(stringToAdd) && modifiedList?["1"] == nil {
      return 1
    }
    
    if obfs.contains(stringToAdd) && modifiedList?["2"] == nil {
      return 2
    }
    
    return nil
  }
  
  func addItem(_ string: String, to array: [String]) {
    
    var newArray = array
    newArray.append(string)
    delegate?.addToTemporaryList!(number: currentListNumber!, array: newArray)
    delegate?.loadTable(tableToShow: newArray)
    dismiss(self)
  }
  
  @IBOutlet weak var arrayLabel: NSTextField!
  @IBOutlet weak var inputTextField: NSTextField!
  
  var currentListNumber: Int?
  var listNames: [String]?
  var modifiedList: [String: [String]]?
  var currentArray = [String]()
  var delegate: ValueChanged?
  let defaults = UserDefaults.standard
  
}
