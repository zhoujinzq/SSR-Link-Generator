//
//  MenusTable.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/16.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa


class MenusTable: NSObject, NSTableViewDelegate, NSTableViewDataSource {
  
  var tableToShow: [String]
  
  init(_ tableToShow: [String]) {
    self.tableToShow = tableToShow
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
