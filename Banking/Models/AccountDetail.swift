//
//  AccountDetail.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

struct AccountDetail: Codable {
    let productName: String?
    let openedDate: Date?
    let branch: String?
    let beneficiaries: [String]?
}

extension AccountDetail {
    static let example = AccountDetail(
        productName: "Premium Checking",
        openedDate: ISO8601DateFormatter().date(from: "2024-01-15T00:00:00Z"),
        branch: "Downtown Branch",
        beneficiaries: ["John Doe", "Jane Doe"]
    )
}
