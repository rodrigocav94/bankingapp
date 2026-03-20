//
//  AccountType.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

enum AccountType: String, Codable {
    case current, savings, time
    case creditCard = "credit card"
    
    var illustration: ImageResource {
        switch self {
        case .current:
                .coin
        case .savings:
                .pig
        case .time:
                .clock
        case .creditCard:
                .card
        }
    }
    
    var title: LocalizedStringResource {
        LocalizedStringResource(stringLiteral: self.rawValue.capitalized)
    }
}
