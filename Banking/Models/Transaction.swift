//
//  Transaction.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    let id: String
    let date: Date
    let transactionAmount: String
    let transactionType: String
    let description: String?
    let isDebit: Bool
}

extension Transaction {
    static let example: Transaction = {
        Transaction(
            id: UUID().uuidString,
            date: .now,
            transactionAmount: "478.51",
            transactionType: "intrabank",
            description: nil,
            isDebit: false
        )
    }()
}
