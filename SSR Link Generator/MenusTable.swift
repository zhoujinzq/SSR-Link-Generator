//
//  MenusTable.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/16.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa


class MenusTable: NSObject, NSTableViewDelegate, NSTableViewDataSource {
  
  var identifier: String
  
  init(identifier: String) {
    self.identifier = identifier
  }
  
  var tableToShow: [String] {
    
    let defaults = UserDefaults.standard
    
    switch identifier {
    case "协议":
      return defaults.array(forKey: "protocolOptions") as! [String]
    case "混淆":
      return defaults.array(forKey: "obfsOptions") as! [String]
    default:
      return defaults.array(forKey: "encryptionMethods") as! [String]
    }
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return tableToShow.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "test"), owner: self) as? NSTableCellView
    
    cell?.textField?.stringValue = tableToShow[row]
    return cell
  }

}
