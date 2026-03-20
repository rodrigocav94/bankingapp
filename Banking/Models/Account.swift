//
//  Account.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct Account: Identifiable, Codable {
    let id: String
    let accountNumber: Int
    let balance, currencyCode: String
    let accountType: AccountType
    let accountNickname: String?
}

extension Account {
    var displayName: String { accountNickname ?? String(accountNumber) }
    static func example(type: AccountType = .current) -> Account {
        Account(
            id: UUID().uuidString,
            accountNumber: 12345,
            balance: "99.00",
            currencyCode: "EUR",
            accountType: type,
            accountNickname: "My Salary"
        )
    }
}
