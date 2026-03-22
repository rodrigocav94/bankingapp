//
//  AccountsListViewModelTests.swift
//  BankingTests
//
//  Created by Rodrigo Cavalcanti on 3/22/26.
//

import XCTest
import SwiftUI
@testable import Banking

@MainActor
final class AccountsListViewModelTests: XCTestCase {
    private var mockService: MockAPIService!
    private var sut: AccountsListViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
        sut = AccountsListViewModel(apiService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInitStartsWithEmptyAccounts() {
        XCTAssertTrue(sut.accounts.isEmpty)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.didFailLoading)
        XCTAssertFalse(sut.displayingErrorAlert)
    }

    func testPlaceholderAccountsHasFiveItems() {
        XCTAssertEqual(sut.placeholderAccounts.count, 5)
    }

    // MARK: - loadAccounts

    func testLoadAccountsSuccess() async {
        let accounts = [
            Account(id: "1", accountNumber: 111, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: "Salary"),
            Account(id: "2", accountNumber: 222, balance: "200.00", currencyCode: "USD", accountType: .savings, accountNickname: nil),
        ]
        mockService.accountsToReturn = accounts

        await sut.loadAccounts()

        XCTAssertEqual(sut.accounts.count, 2)
        XCTAssertEqual(sut.accounts.first?.id, "1")
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.didFailLoading)
        XCTAssertFalse(sut.displayingErrorAlert)
    }

    func testLoadAccountsFailure() async {
        mockService.errorToThrow = APIError.invalidURL

        await sut.loadAccounts()

        XCTAssertTrue(sut.accounts.isEmpty)
        XCTAssertTrue(sut.didFailLoading)
        XCTAssertTrue(sut.displayingErrorAlert)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadAccountsResetsFailureOnRetry() async {
        mockService.errorToThrow = APIError.invalidURL
        await sut.loadAccounts()
        XCTAssertTrue(sut.didFailLoading)

        mockService.errorToThrow = nil
        mockService.accountsToReturn = [
            Account(id: "1", accountNumber: 111, balance: "50.00", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        ]

        await sut.loadAccounts()

        XCTAssertFalse(sut.didFailLoading)
        XCTAssertEqual(sut.accounts.count, 1)
    }

    func testLoadAccountsReplacesExistingAccounts() async {
        mockService.accountsToReturn = [
            Account(id: "1", accountNumber: 111, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        ]
        await sut.loadAccounts()
        XCTAssertEqual(sut.accounts.count, 1)

        mockService.accountsToReturn = [
            Account(id: "2", accountNumber: 222, balance: "200.00", currencyCode: "USD", accountType: .savings, accountNickname: nil),
            Account(id: "3", accountNumber: 333, balance: "300.00", currencyCode: "GBP", accountType: .time, accountNickname: nil),
        ]
        await sut.loadAccounts()

        XCTAssertEqual(sut.accounts.count, 2)
        XCTAssertEqual(sut.accounts.first?.id, "2")
    }

    // MARK: - didTap

    func testDidTapAppendsToPath() {
        let account = Account(id: "1", accountNumber: 111, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: "Test")

        sut.didTap(account: account)

        XCTAssertFalse(sut.path.isEmpty)
    }

    func testDidTapDoesNothingWhenLoading() async {
        // Simulate loading state
        mockService.accountsToReturn = []
        // Manually set state since loadAccounts is async
        sut.isLoading = true

        let account = Account(id: "1", accountNumber: 111, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        sut.didTap(account: account)

        XCTAssertTrue(sut.path.isEmpty)
    }

    func testDidTapDoesNothingWhenFailed() async {
        mockService.errorToThrow = APIError.invalidURL
        await sut.loadAccounts()

        let account = Account(id: "1", accountNumber: 111, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        sut.didTap(account: account)

        XCTAssertTrue(sut.path.isEmpty)
    }
}
