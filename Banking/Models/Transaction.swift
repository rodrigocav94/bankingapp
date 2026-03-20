//
//  Transaction.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: String
    let date: Date
    let transactionAmount: String
    let transactionType: String
    let description: String?
    let isDebit: Bool
}
