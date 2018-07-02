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
  func applicationWillFinishLaunching(_ notification: Notification) {
  }
  
  func applicationDidFinishLaunching(_ notification: Notification) {
    loadUserDefaults()

  }
  
  func loadUserDefaults() {

    // If userDefaults for 2 keys are both empty, then it's the first time app launches,
    // we pour arrays into userDefaults so mainVC can always read dropdown menu items from there
    if defaults.array(forKey: "Obfs Options") == nil && defaults.array(forKey: "Protocol Options") == nil {
      defaults.set(encryptionMethods, forKey: "Encryption Options")
      defaults.set(protocolOptions, forKey: "Protocol Options")
      defaults.set(obfsOptions, forKey: "Obfs Options")

      // By default, save users menu selections and texts, and auto fill them on next run is turned on.
      defaults.set(1, forKey: "autoFillOnNextRun")
    }
  }
  
  let defaults = UserDefaults.standard
  
  let encryptionMethods = ["none", "table", "rc4", "rc4-md5-6", "rc4-md5", "aes-128-cfb", "aes-192-cfb", "aes-256-cfb", "aes-128-ctr", "aes-192-ctr", "aes-256-ctr", "bf-cft", "camellia-128-cfb", "camellia-192-cfb", "camellia-256-cfb", "cast5-cfb", "des-cfb", "idea-cfb", "rc2-cfb", "seed-cfb", "salsa20", "chacha20", "chacha20-ietf"]
  let protocolOptions = ["auth_sha1_v2", "auth_sha1_v4", "auth_aes128_sha1", "auth_aes128_md5", "auth_chain_a", "auth_chain_b"]
  let obfsOptions = ["plain", "http_simple", "tls_simple", "http_post"]
  
}

