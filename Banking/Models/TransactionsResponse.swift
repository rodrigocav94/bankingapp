//
//  TransactionsResponse.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct TransactionsResponse: Decodable {
    let transactions: [Transaction]
    let paging: Paging
    
    struct Paging: Codable {
        let pagesCount: Int
        let totalItems: Int
        let currentPage: Int
    }
}
