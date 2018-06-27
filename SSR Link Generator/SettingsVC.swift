//
//  SettingsVC.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/06/10.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa

class SettingsVC: NSViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    saveDefaultsCheckbox.state = defaults.integer(forKey: "autoFillOnNextRun") == 0 ? .off : .on
    
    loadTable(tableToShow: getTableArrayFromDefaults(tableLabel: tableLabel))
  }
  
  // Change table contents base on user selection
  @IBAction func dropdownClicked(_ sender: NSPopUpButton) {
    
    // 'tableLabel' is used elsewhere in this vc, so its value must reflect
    // which array is been selected and modifiedat accordingly at any moment
    tableLabel = sender.selectedItem!.title
    
    /*
     If the selected array has been modified but not yet saved, load the unsaved array
     as table's datasource, otherwise use the array in userDefaults as datasource
     */
    loadTable(tableToShow: getCurrentArray())
    
    tableView.reloadData()
  }
  
  @IBAction func removeTableItem(_ sender: Any) {
    
    // Deletion of last item in a menu is not allowed
    guard tableView.numberOfRows > 1 else {
      createAlert("无法删除\(tableLabel)中的最后一个选项")
      return
    }
    
    guard tableView.selectedRow != -1 else {
      createAlert("请先选中要删除的值")
      return
    }
    
    /*
     Get the array to be modified, set the 'currentArray' data from 'modifiedList' allows
     users to keep their unsaved modification and going from there.
     */
    var currentArray = getCurrentArray()
    
    currentArray.remove(at: tableView.selectedRow)
    modifiedList.updateValue(currentArray, forKey: tableLabel)
    
    // Load list from unsaved array
    loadTable(tableToShow: modifiedList[tableLabel]!)
  }
  
  @IBAction func saveSettingsClicked(_ sender: Any) {
    
		defaults.set(saveDefaultsCheckbox.state.rawValue, forKey: "autoFillOnNextRun")
    
    modifiedList.forEach { (key, value) in
      defaults.set(value, forKey: key)
    }
    
    // Clear dictionary since all changes have been saved to userDefaults
    modifiedList.removeAll(keepingCapacity: false)
    
    // Reload all dropdown menu items in main window
    delegate?.populateMenus!()
    
    self.view.window?.performClose(nil)
  }
  
  @IBOutlet weak var dropdownMenu: NSPopUpButton!
  @IBOutlet weak var tableView: NSTableView!
  @IBOutlet weak var saveDefaultsCheckbox: NSButtonCell!
  
  
  var menusTable: MenusTable?
  var delegate: ValueChanged?
  var tableLabel = "加密方式"
  let defaults = UserDefaults.standard
  
  // To track all modified but not saved dropdown menu items
  var modifiedList = [String: [String]]()
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "addItem" {
      let addItemVC = segue.destinationController as! AddItemVC
      addItemVC.tableLabel = tableLabel
      addItemVC.delegate = self
    }
    
  }
  
}

extension SettingsVC: ValueChanged {
  
  func loadTable(tableToShow: [String]) {
    
    menusTable = MenusTable(tableToShow)
    tableView.dataSource = menusTable
    tableView.delegate = menusTable
  }
  
  // Wrapped in a function so this can be called in AddItemVC as delegate method
  func addToTemporaryList(key: String, array: [String]) {
    modifiedList.updateValue(array, forKey: key)
  }
  
  // Wrapped in a function so this can be called in AddItemVC as delegate method
  func getCurrentArray() -> [String] {
    return (modifiedList[tableLabel] != nil) ? modifiedList[tableLabel]! : getTableArrayFromDefaults(tableLabel: tableLabel)
  }
}
