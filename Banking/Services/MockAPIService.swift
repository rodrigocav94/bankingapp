//
//  MockAPIService.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/22/26.
//

import Foundation

class MockAPIService: APIServiceProtocol {
    var accountsToReturn: [Account] = []
    var detailToReturn: AccountDetail = AccountDetail(
        productName: "Premium Checking",
        openedDate: Calendar.current.date(byAdding: .year, value: -2, to: .now),
        branch: "Downtown Branch",
        beneficiaries: ["John Doe", "Jane Doe"]
    )
    var transactionsToReturn: [Transaction] = (0..<5).map { i in
        Transaction(
            id: UUID().uuidString,
            date: Calendar.current.date(byAdding: .day, value: -i, to: .now)!,
            transactionAmount: "\(Double.random(in: 10...500))",
            transactionType: ["intrabank", "transfer", "payment"][i % 3],
            description: ["Grocery Store", "Electric Bill", "Salary", "Restaurant", "Online Purchase"][i],
            isDebit: i % 2 == 0
        )
    }
    var errorToThrow: Error?
    var totalPages: Int = 1

    func fetchAccounts() async throws -> [Account] {
        if let error = errorToThrow { throw error }
        return accountsToReturn
    }

    func fetchAccountDetail(accountId: String) async throws -> AccountDetail {
        if let error = errorToThrow { throw error }
        return detailToReturn
    }

    func fetchTransactions(accountId: String, page: Int, size: Int, fromDate: String, toDate: String) async throws -> ([Transaction], TransactionsResponse.Paging) {
        if let error = errorToThrow { throw error }
        let paging = TransactionsResponse.Paging(
            pagesCount: totalPages,
            totalItems: transactionsToReturn.count,
            currentPage: page
        )
        return (transactionsToReturn, paging)
    }
}
