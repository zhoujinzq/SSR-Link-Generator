//
//  AppDelegate.swift
//  SSR Link Generator
//
//  Created by Dunce on 2018/01/01.
//  Copyright © 2018 Dunce. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    loadUserDefaults()
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }
  
  let encryptionMethods = ["none", "table", "rc4", "rc4-md5-6", "rc4-md5", "aes-128-cfb", "aes-192-cfb", "aes-256-cfb", "aes-128-ctr", "aes-192-ctr", "aes-256-ctr", "bf-cft", "camellia-128-cfb", "camellia-192-cfb", "camellia-256-cfb", "cast5-cfb", "des-cfb", "idea-cfb", "rc2-cfb", "seed-cfb", "salsa20", "chacha20", "chacha20-ietf"]
  let protocolOptions = ["auth_sha1_v2", "auth_sha1_v4", "auth_aes128_sha1", "auth_aes128_md5", "auth_chain_a", "auth_chain_b"]
  let obfsOptions = ["plain", "http_simple", "tls_simple", "http_post"]

  func loadUserDefaults() {
    let defaults = UserDefaults.standard
    
    if defaults.array(forKey: "obfsOptions") == nil {
      defaults.set(encryptionMethods, forKey: "encryptionMethods")
      defaults.set(protocolOptions, forKey: "protocolOptions")
      defaults.set(obfsOptions, forKey: "obfsOptions")
    }
  }
}

