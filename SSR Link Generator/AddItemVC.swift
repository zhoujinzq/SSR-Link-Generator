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
    
    arrayToAdd = getTable(identifier: tableIdentifier!)
    arrayLabel.stringValue = tableIdentifier!
    
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue
    guard stringToAdd != "" else {
      createAlert("请填写要添加的选项值")
      return
    }

    var currentArray = defaults.array(forKey: arrayToAdd) as! [String]
    
    if currentArray.contains(stringToAdd) {
      createAlert("\(tableIdentifier!)中已存在\(stringToAdd)，请勿重复添加")
      return
    }
    
    checkContains(stringToAdd)
    
		currentArray.append(stringToAdd)
    
    defaults.set(currentArray, forKey: arrayToAdd)
    delegate?.updateUI()
    dismiss(self)
  }
  
  @objc func addAnyway(_ string: String, array: [String]) -> [String] {
    
    var newArray = array
		newArray.append(string)
    return newArray
  }
  
  func checkContains(_ stringToAdd: String) {
    
    if AppDelegate().encryptionMethods.contains(stringToAdd) {
      
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "加密方式列表中已存在\(stringToAdd)，是否仍添加到\(tableIdentifier!)？"
      alert.addButton(withTitle: "取消")
      alert.addButton(withTitle: "仍然添加")
      alert.runModal()
      alert.buttons[1].action = #selector(addAnyway(_:array:))

      return
    }
    
    if AppDelegate().protocolOptions.contains(stringToAdd) {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "协议列表中已存在\(stringToAdd)，是否仍添加到\(tableIdentifier!)？"
      alert.addButton(withTitle: "取消")
      alert.addButton(withTitle: "仍然添加")
      alert.runModal()
      alert.buttons[1].action = #selector(addAnyway(_:array:))
      
      return
    }
    if AppDelegate().obfsOptions.contains(stringToAdd) {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "混淆方式列表中已存在\(stringToAdd)，是否仍添加到\(tableIdentifier!)？"
      alert.addButton(withTitle: "取消")
      alert.addButton(withTitle: "仍然添加")
      alert.runModal()
      alert.buttons[1].action = #selector(addAnyway(_:array:))
      return
    }

  }
  
  @IBOutlet weak var inputTextField: NSTextField!
  @IBOutlet weak var arrayLabel: NSTextField!
  
  var tableIdentifier: String?
  var arrayToAdd = ""
  var delegate: UserDefaultsChanged?
  let defaults = UserDefaults.standard
}
