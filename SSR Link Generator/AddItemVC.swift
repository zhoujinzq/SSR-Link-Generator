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
    
    arrayToModify = getTable(identifier: tableIdentifier!)
    arrayLabel.stringValue = tableIdentifier! + "菜单中的选项："
    
  }
  
  @IBAction func addString(_ sender: Any) {
    
    let stringToAdd = inputTextField.stringValue
    guard stringToAdd != "" else { return }
    
    var currentArray = defaults.array(forKey: arrayToModify)!
    currentArray.append(stringToAdd)
    
    defaults.set(currentArray, forKey: arrayToModify)
    delegate?.updateUI!()
    dismiss(self)
  }
  
  @IBOutlet weak var inputTextField: NSTextField!
  @IBOutlet weak var arrayLabel: NSTextField!
  
  var tableIdentifier: String?
  var arrayToModify = ""
  var delegate: UserDefaultsChanged?
  let defaults = UserDefaults.standard
}
