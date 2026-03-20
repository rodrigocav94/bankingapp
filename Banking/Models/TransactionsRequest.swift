//
//  TransactionsRequest.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct TransactionsRequest: Codable {
    let toDate: String
    let fromDate: String
    let nextPage: Int
}
