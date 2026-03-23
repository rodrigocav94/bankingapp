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
    static let example: Transaction = Transaction(
        id: UUID().uuidString,
        date: .now,
        transactionAmount: "478.51",
        transactionType: "intrabank",
        description: nil,
        isDebit: false
    )
    
    static let examples = [
        Transaction(id: "tx-1", date: ISO8601DateFormatter().date(from: "2026-03-20T10:00:00Z")!, transactionAmount: "150.00", transactionType: "transfer", description: "Grocery Store", isDebit: true),
        Transaction(id: "tx-2", date: ISO8601DateFormatter().date(from: "2026-03-19T14:30:00Z")!, transactionAmount: "2500.00", transactionType: "intrabank", description: "Salary Deposit", isDebit: false),
        Transaction(id: "tx-3", date: ISO8601DateFormatter().date(from: "2026-03-18T09:15:00Z")!, transactionAmount: "45.99", transactionType: "payment", description: "Electric Bill", isDebit: true),
    ]
}
