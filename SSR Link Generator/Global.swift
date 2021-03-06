//
//  Global.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/06/21.
//  Copyright © 2018年 Lei Gao. All rights reserved.
//

import Cocoa

@objc protocol ValueChanged {
  
  func loadTable(tableToShow: [String])
  @objc optional func addToTemporaryList(number: Int, array: [String])
  @objc optional func getCurrentArray() -> [String]
  @objc optional func populateMenus()
  
}

func createAlert(_ message: String) {
  
  let alert = NSAlert()
  alert.alertStyle = .critical
  alert.messageText = message
  alert.runModal()
}

// Returns an array according to its label
func getTableArrayFromDefaults(menu: NSPopUpButton) -> [String] {
  
  var tableToShow: [String] {
    
    let defaults = UserDefaults.standard
    
    switch menu.indexOfSelectedItem {
      
    case 1:
      return defaults.array(forKey: "1") as! [String]
    case 2:
      return defaults.array(forKey: "2") as! [String]
    default:
      return defaults.array(forKey: "0") as! [String]
    }
    
  }
  
  return tableToShow
}

class PlaceholderTextView: NSTextView {
  
  @objc var placeholderAttributedString: NSAttributedString?
  
}
