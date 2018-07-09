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
    
    /*
      Set tableView's datasource according to dropdown menu's indexOfSelectedItem, which by default will return 0 when
      index is out of range. So when this view load, tableview always shows the encryption methods array, and change
      accordingly to user action later on.
     */
    let tableItemsToLoad = getTableArrayFromDefaults(menu: dropdownMenu)
    loadTable(tableToShow: tableItemsToLoad)
    
    // TableName is used in some UI elements and alert messages, tableNumber is used to update modifiedList and also
    // in addItemVC, so everytime those 2 values changed, we update the values.
    tableName = dropdownMenu.titleOfSelectedItem!
    tableNumber = dropdownMenu.indexOfSelectedItem
  }
  
  // Change table contents base on user selection
  @IBAction func dropdownClicked(_ sender: NSPopUpButton) {
    
		// Update the two values
    tableNumber = sender.indexOfSelectedItem
    tableName = sender.titleOfSelectedItem!
    
    /*
     If the selected array has been modified but not yet saved, set the unsaved array
     as table's datasource, otherwise use the array in userDefaults as datasource
     */
    loadTable(tableToShow: getCurrentArray())
    
    tableView.reloadData()
  }
  
  @IBAction func removeTableItem(_ sender: Any) {
    
    // Deletion of last item in a menu is not allowed
    guard tableView.numberOfRows > 1 else {
      
      let formatString = NSLocalizedString("Unable to delete last item in %d", comment: "Disallow user to delete the last item in an array")
      createAlert(String.localizedStringWithFormat(formatString, tableName))
      return
    }
    
    guard tableView.selectedRow != -1 else {
      
      createAlert(NSLocalizedString("Please select the value you want to delete", comment: "Please select the value you want to delete"))
      return
    }
    
    /*
     Get the array to be modified, set the 'currentArray' data from 'modifiedList' allows
     users to keep their unsaved modification and going from there.
     */
    var currentArray = getCurrentArray()
    
    currentArray.remove(at: tableView.selectedRow)
    modifiedList.updateValue(currentArray, forKey: String(tableNumber))
    
    // Load list from unsaved array
    loadTable(tableToShow: modifiedList[String(tableNumber)]!)
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
  var tableNumber = -1
  var tableName = ""
  let defaults = UserDefaults.standard
  
  // To hold all modified but not saved array data
  var modifiedList = [String: [String]]()
  
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "addItem" {
      
      let addItemVC = segue.destinationController as! AddItemVC
      addItemVC.currentListNumber = tableNumber

      // Create an array for all "names" for arrays, used in alert message in addItemVC in case something goes wrong
      // Multi language support makes it hard to get the name in addItemVC itself
      var names = [String]()
      dropdownMenu.itemArray.forEach { names.append($0.title) }
      addItemVC.listNames = names
      
      addItemVC.modifiedList = modifiedList
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
  func addToTemporaryList(number: Int, array: [String]) {
    modifiedList.updateValue(array, forKey: String(number))
  }
  
  // Wrapped in a function so this can be called in AddItemVC as delegate method
  func getCurrentArray() -> [String] {
    return (modifiedList[String(tableNumber)] != nil) ? modifiedList[String(tableNumber)]! : getTableArrayFromDefaults(menu: dropdownMenu)
  }
}
