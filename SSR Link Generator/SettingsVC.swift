//
//  SettingsVC.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/10.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa

@objc protocol UserDefaultsChanged {
  func loadTable(label: String)
  @objc optional func addToTemporaryList(key: String, array: [String])
}


class SettingsVC: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadTable(label: tableLabel)
  }
  
  @IBAction func dropdownClicked(_ sender: NSPopUpButton) {
    tableLabel = sender.selectedItem!.title
    loadTable(label: tableLabel)
    tableView.reloadData()
  }
  
  @IBAction func saveSettingsClicked(_ sender: Any) {
    
    delegate?.loadTable(label: tableLabel)
    self.view.window?.performClose(nil)
  }
  
  @IBAction func removeTableItem(_ sender: Any) {
    
    guard tableView.numberOfRows > 1 else {
      createAlert("无法删除\(tableLabel)中的最后一个选项")
      return
    }
    
    guard tableView.selectedRow != -1 else {
      createAlert("请先选中要删除的值")
      return
    }
    
    let currentTable = getTable(identifier: tableLabel)
    var currentArray = defaults.array(forKey: currentTable)!
    currentArray.remove(at: tableView.selectedRow)
    defaults.set(currentArray, forKey: currentTable)
    loadTable(label: tableLabel)
  }
 
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    if segue.identifier == "addItem" {
      let addItemVC = segue.destinationController as! AddItemVC
      addItemVC.tableIdentifier = tableLabel
      addItemVC.delegate = self
    }
  }
  
  
  
  @IBOutlet weak var tableView: NSTableView!
  
  var menusTable: MenusTable?
  var delegate: UserDefaultsChanged?
  var tableLabel = "加密"
  let defaults = UserDefaults.standard

  var modifiedList = [String: [String]]()
  
}

extension SettingsVC: UserDefaultsChanged {
  
  func loadTable(label: String) {
    menusTable = MenusTable(label: label)
    tableView.dataSource = menusTable
    tableView.delegate = menusTable
    
  }
  
  func addToTemporaryList(key: String, array: [String]) {
		modifiedList.updateValue(array, forKey: key)
  }
}
