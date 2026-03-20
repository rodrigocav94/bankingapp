//
//  String+Extensions.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

extension String {
    func asLocalizedCurrency(code : String) -> String {
        if let doubleValue = Double(self) {
            return doubleValue.formatted(.currency(code: code))
        }
        
        return "\(self) \(code)"
    }
}
