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
