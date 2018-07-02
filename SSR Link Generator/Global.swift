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
  @objc optional func addToTemporaryList(key: String, array: [String])
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
func getTableArrayFromDefaults(tableLabel: String) -> [String] {
  
  var tableToShow: [String] {
    
    let defaults = UserDefaults.standard
    
    switch tableLabel {
    case "Protocol Options":
      return defaults.array(forKey: "Protocol Options") as! [String]
    case "Obfs Options":
      return defaults.array(forKey: "Obfs Options") as! [String]
    default:
      return defaults.array(forKey: "Encryption Options") as! [String]
    }
  }
  return tableToShow
}

class PlaceholderTextView: NSTextView {
  @objc var placeholderAttributedString: NSAttributedString?
}
