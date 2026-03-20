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
    let balance, currencyCode, accountType: String
    let accountNickname: String?

    var displayName: String { accountNickname ?? String(accountNumber) }
}
