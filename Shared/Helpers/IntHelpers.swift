//
//  IntHelpers.swift
//  St Jude
//
//  Created by Justin Hamilton on 9/13/24.
//

import Foundation

extension Int {
    var isNice: Bool {
        if(self == 420 || self == 69) {
            return true
        }
        
        let stringValue = String(self)
        
        do {
            let regex1 = try Regex("^(420)0*(69)?$")
            let regex2 = try Regex("^(69)0*(420)?$")
            
            if(stringValue.contains(regex1) || stringValue.contains(regex2)) {
                return true
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
        return false
    }
}
