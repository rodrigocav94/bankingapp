//
//  BankingTests.swift
//  BankingTests
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import XCTest
@testable import Banking
@MainActor
final class MockAPIServiceTests: XCTestCase {

    // MARK: - MockAPIService

    func testMockReturnsConfiguredAccounts() async throws {
        let mock = MockAPIService()
        let accounts = [
            Account(id: "1", accountNumber: 111, balance: "100", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        ]
        mock.accountsToReturn = accounts

        let result = try await mock.fetchAccounts()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func testMockReturnsConfiguredDetail() async throws {
        let mock = MockAPIService()
        let detail = AccountDetail(productName: "Test", openedDate: nil, branch: "HQ", beneficiaries: nil)
        mock.detailToReturn = detail

        let result = try await mock.fetchAccountDetail(accountId: "any")
        XCTAssertEqual(result.productName, "Test")
        XCTAssertEqual(result.branch, "HQ")
    }

    func testMockReturnsConfiguredTransactions() async throws {
        let mock = MockAPIService()
        let tx = Transaction(id: "tx1", date: .now, transactionAmount: "10", transactionType: "t", description: nil, isDebit: false)
        mock.transactionsToReturn = [tx]
        mock.totalPages = 3

        let (transactions, paging) = try await mock.fetchTransactions(accountId: "any", page: 0, size: 20, fromDate: "", toDate: "")
        XCTAssertEqual(transactions.count, 1)
        XCTAssertEqual(paging.pagesCount, 3)
        XCTAssertEqual(paging.currentPage, 0)
    }

    func testMockThrowsConfiguredError() async {
        let mock = MockAPIService()
        mock.errorToThrow = APIError.invalidURL

        do {
            _ = try await mock.fetchAccounts()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    func testMockThrowsOnFetchDetail() async {
        let mock = MockAPIService()
        mock.errorToThrow = APIError.invalidResponse

        do {
            _ = try await mock.fetchAccountDetail(accountId: "any")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }

    func testMockThrowsOnFetchTransactions() async {
        let mock = MockAPIService()
        mock.errorToThrow = APIError.decodingFailed(NSError(domain: "", code: 0))

        do {
            _ = try await mock.fetchTransactions(accountId: "any", page: 0, size: 20, fromDate: "", toDate: "")
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is APIError)
        }
    }
}
