//
//  SettingsVC.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/10.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa

@objc protocol UserDefaultsChanged {
  @objc optional func updateUI()
}


class SettingsVC: NSViewController{
  
  override func viewDidLoad() {
    super.viewDidLoad()

    loadTable()
  }
  
  @IBAction func dropdownClicked(_ sender: NSPopUpButton) {
    tableIdentifier = sender.selectedItem!.title
    loadTable()
    tableView.reloadData()
  }
  
  @IBAction func saveSettingsClicked(_ sender: Any) {
    
    delegate?.updateUI!()
    self.view.window?.performClose(nil)
  }
  
  @IBAction func removeTableItem(_ sender: Any) {
    
    guard tableView.numberOfRows > 1 else {
      createAlert("无法删除\(tableIdentifier)中的最后一个选项")
      return
    }
    
    guard tableView.selectedRow != -1 else {
      createAlert("请先选中要删除的值")
      return
    }

    let currentTable = getTable(identifier: tableIdentifier)
    var currentArray = defaults.array(forKey: currentTable)!
    currentArray.remove(at: tableView.selectedRow)
    defaults.set(currentArray, forKey: currentTable)
    updateUI()
  }
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    if segue.identifier == "addItem" {
      let addItemVC = segue.destinationController as! AddItemVC
			addItemVC.tableIdentifier = tableIdentifier
      addItemVC.delegate = self
    }
  }
  
  
  
  @IBOutlet weak var tableView: NSTableView!
  
  var menusTable: MenusTable?
  var delegate: UserDefaultsChanged?
  var tableIdentifier = "加密"
  let defaults = UserDefaults.standard
}

extension SettingsVC: UserDefaultsChanged {

  func updateUI() {
    loadTable()
  }
  
  func loadTable() {
    menusTable = MenusTable(identifier: tableIdentifier)
    tableView.dataSource = menusTable
    tableView.delegate = menusTable

  }
  
}
