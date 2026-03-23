//
//  Account.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct Account: Identifiable, Codable, Hashable {
    let id: String
    let accountNumber: Int
    let balance, currencyCode: String
    let accountType: AccountType
    let accountNickname: String?
}

extension Account {
    var displayName: String { accountNickname ?? String(accountNumber) }
    static func example(type: AccountType = AccountType.allCases.randomElement()!) -> Account {
        Account(
            id: UUID().uuidString,
            accountNumber: 12345,
            balance: "99.00",
            currencyCode: "EUR",
            accountType: type,
            accountNickname: "My Salary"
        )
    }
    static let examples: [Account] = [
        Account(id: "acc-1", accountNumber: 10001, balance: "1250.75", currencyCode: "EUR", accountType: .current, accountNickname: "My Salary"),
        Account(id: "acc-2", accountNumber: 20002, balance: "5430.00", currencyCode: "EUR", accountType: .savings, accountNickname: "Savings Goal"),
        Account(id: "acc-3", accountNumber: 30003, balance: "320.50", currencyCode: "EUR", accountType: .creditCard, accountNickname: nil),
    ]
}
