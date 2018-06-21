//
//  Global.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/06/21.
//  Copyright © 2018年 Lei Gao. All rights reserved.
//

import Cocoa


func createAlert(_ message: String) {
  let alert = NSAlert()
  alert.alertStyle = .critical
  alert.messageText = message
  alert.runModal()
}

func getTable(identifier: String) -> String {
  switch identifier {
  case "混淆":
    return "obfsOptions"
  case "协议":
    return "protocolOptions"
  default:
    return "encryptionMethods"
  }
}
