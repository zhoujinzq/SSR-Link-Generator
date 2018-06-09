//
//  ConfigurationOptions.swift
//  SSR Link Generator
//
//  Created by Lei Gao on 2018/06/07.
//  Copyright © 2018 Lei Gao. All rights reserved.
//

import Cocoa

class ConfigurationOptions: NSObject {
  
  var encryptionMethods = ["none", "table", "rc4", "rc4-md5-6", "rc4-md5", "aes-128-cfb", "aes-192-cfb", "aes-256-cfb", "aes-128-ctr", "aes-192-ctr", "aes-256-ctr", "bf-cft", "camellia-128-cfb", "camellia-192-cfb", "camellia-256-cfb", "cast5-cfb", "des-cfb", "idea-cfb", "rc2-cfb", "seed-cfb", "salsa20", "chacha20", "chacha20-ietf"]
  
  var protocolOptions = ["auth_sha1_v2", "auth_sha1_v4", "auth_aes128_sha1", "auth_aes128_md5", "auth_chain_a", "auth_chain_b"]
  
  var obfsOpitons = ["plain", "http_simple", "tls_simple", "http_post"]
}

