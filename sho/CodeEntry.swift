//
//  CodeEntry.swift
//  sho
//
//  Created by Eugene Ryzhikov on 4/7/25.
//

import Foundation

class CodeEntry: Identifiable {
     public let id = UUID()
     public let serviceName: String
     public let userName: String
     public let secret: String
     public let generator: TOTPGenerator
    
    init(name: String, userId: String, secret: String) {
        self.serviceName = name
        self.userName = userId
        self.secret = secret
        self.generator = TOTPGenerator(secret: secret)
    }
    
    func generateCode() -> String {
        return generator.generateCode()
    }
    
 }



