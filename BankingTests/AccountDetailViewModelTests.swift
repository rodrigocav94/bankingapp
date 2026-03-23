//
//  AccountDetailViewModelTests.swift
//  BankingTests
//
//  Created by Rodrigo Cavalcanti on 3/22/26.
//

import XCTest
@testable import Banking

@MainActor
final class AccountDetailViewModelTests: XCTestCase {
    private var mockService: MockAPIService!
    private var sut: AccountDetailViewModel!

    override func setUp() {
        super.setUp()
        mockService = MockAPIService()
        sut = AccountDetailViewModel(accountId: "test-id", apiService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Init

    func testInitSetsDefaultDates() {
        let now = Date()
        let thirtyYearsAgo = Calendar.current.date(byAdding: .year, value: -30, to: now)!

        XCTAssertEqual(
            sut.fromDate.timeIntervalSinceReferenceDate,
            thirtyYearsAgo.timeIntervalSinceReferenceDate,
            accuracy: 1
        )
        XCTAssertEqual(
            sut.toDate.timeIntervalSinceReferenceDate,
            now.timeIntervalSinceReferenceDate,
            accuracy: 1
        )
    }

    func testInitStartsWithEmptyState() {
        XCTAssertNil(sut.detail)
        XCTAssertTrue(sut.transactions.isEmpty)
        XCTAssertFalse(sut.isLoadingDetail)
        XCTAssertFalse(sut.isLoadingMore)
        XCTAssertFalse(sut.didFailLoadingDetail)
        XCTAssertFalse(sut.didFailLoadingTransaction)
        XCTAssertFalse(sut.allTransactionsLoaded)
        XCTAssertFalse(sut.isDisplayingTitle)
        XCTAssertFalse(sut.displayingErrorAlert)
        XCTAssertFalse(sut.showingDateRangePicker)
    }

    // MARK: - loadDetail

    func testLoadDetailSuccess() async {
        let expected = AccountDetail(
            productName: "Savings Plus",
            openedDate: .now,
            branch: "Main St",
            beneficiaries: ["Alice"]
        )
        mockService.detailToReturn = expected

        await sut.loadDetail()

        XCTAssertEqual(sut.detail?.productName, "Savings Plus")
        XCTAssertEqual(sut.detail?.branch, "Main St")
        XCTAssertFalse(sut.isLoadingDetail)
        XCTAssertFalse(sut.didFailLoadingDetail)
    }

    func testLoadDetailFailureSetsFlag() async {
        mockService.errorToThrow = APIError.invalidURL

        await sut.loadDetail()

        XCTAssertNil(sut.detail)
        XCTAssertTrue(sut.didFailLoadingDetail)
        XCTAssertFalse(sut.isLoadingDetail)
        XCTAssertFalse(sut.displayingErrorAlert)
    }

    func testLoadDetailFailureWithAlertDisplaysAlert() async {
        mockService.errorToThrow = APIError.invalidURL

        await sut.loadDetail(displayingAlertWhentFails: true)

        XCTAssertTrue(sut.didFailLoadingDetail)
        XCTAssertTrue(sut.displayingErrorAlert)
    }

    func testLoadDetailFailureWithoutAlertDoesNotDisplayAlert() async {
        mockService.errorToThrow = APIError.invalidURL

        await sut.loadDetail(displayingAlertWhentFails: false)

        XCTAssertTrue(sut.didFailLoadingDetail)
        XCTAssertFalse(sut.displayingErrorAlert)
    }

    func testLoadDetailResetsFailureFlag() async {
        mockService.errorToThrow = APIError.invalidURL
        await sut.loadDetail()
        XCTAssertTrue(sut.didFailLoadingDetail)

        mockService.errorToThrow = nil
        await sut.loadDetail()

        XCTAssertFalse(sut.didFailLoadingDetail)
        XCTAssertNotNil(sut.detail)
    }

    // MARK: - loadTransactions

    func testLoadTransactionsSuccess() async {
        mockService.totalPages = 1

        await sut.loadTransactions(reset: true)

        XCTAssertEqual(sut.transactions.count, 3)
        XCTAssertTrue(sut.allTransactionsLoaded)
        XCTAssertFalse(sut.isLoadingMore)
        XCTAssertFalse(sut.didFailLoadingTransaction)
    }

    func testLoadTransactionsFailureSetsFlag() async {
        mockService.errorToThrow = APIError.invalidResponse

        await sut.loadTransactions(reset: true)

        XCTAssertTrue(sut.transactions.isEmpty)
        XCTAssertTrue(sut.didFailLoadingTransaction)
        XCTAssertFalse(sut.isLoadingMore)
    }

    func testLoadTransactionsFailureWithAlertDisplaysAlert() async {
        mockService.errorToThrow = APIError.invalidResponse

        await sut.loadTransactions(reset: true, displayingAlertWhentFails: true)

        XCTAssertTrue(sut.didFailLoadingTransaction)
        XCTAssertTrue(sut.displayingErrorAlert)
    }

    func testLoadTransactionsFailureWithoutAlertDoesNotDisplayAlert() async {
        mockService.errorToThrow = APIError.invalidResponse

        await sut.loadTransactions(reset: true, displayingAlertWhentFails: false)

        XCTAssertTrue(sut.didFailLoadingTransaction)
        XCTAssertFalse(sut.displayingErrorAlert)
    }

    func testLoadTransactionsResetClearsExistingData() async {
        await sut.loadTransactions(reset: true)
        XCTAssertFalse(sut.transactions.isEmpty)

        mockService.transactionsToReturn = []
        mockService.totalPages = 1

        await sut.loadTransactions(reset: true)

        XCTAssertTrue(sut.transactions.isEmpty)
    }

    func testLoadTransactionsSortsDescendingByDate() async {
        let now = Date()
        mockService.transactionsToReturn = [
            Transaction(id: "1", date: now.addingTimeInterval(-100), transactionAmount: "10", transactionType: "transfer", description: "Old", isDebit: false),
            Transaction(id: "2", date: now, transactionAmount: "20", transactionType: "transfer", description: "New", isDebit: false),
            Transaction(id: "3", date: now.addingTimeInterval(-50), transactionAmount: "30", transactionType: "transfer", description: "Mid", isDebit: true),
        ]
        mockService.totalPages = 1

        await sut.loadTransactions(reset: true)

        XCTAssertEqual(sut.transactions.count, 3)
        XCTAssertEqual(sut.transactions.first?.description, "New")
        XCTAssertEqual(sut.transactions.last?.description, "Old")
    }

    func testLoadTransactionsDeduplicates() async {
        let tx = Transaction(id: "same-id", date: .now, transactionAmount: "10", transactionType: "transfer", description: "Dup", isDebit: false)
        mockService.transactionsToReturn = [tx, tx]
        mockService.totalPages = 1

        await sut.loadTransactions(reset: true)

        XCTAssertEqual(sut.transactions.count, 1)
    }

    func testLoadTransactionsPagination() async {
        let page0Tx = Transaction(id: "p0", date: .now, transactionAmount: "10", transactionType: "transfer", description: nil, isDebit: false)
        let page1Tx = Transaction(id: "p1", date: .now.addingTimeInterval(-10), transactionAmount: "20", transactionType: "transfer", description: nil, isDebit: true)

        mockService.transactionsToReturn = [page0Tx]
        mockService.totalPages = 2

        await sut.loadTransactions(reset: true)
        XCTAssertEqual(sut.transactions.count, 1)
        XCTAssertFalse(sut.allTransactionsLoaded)

        mockService.transactionsToReturn = [page1Tx]
        await sut.loadTransactions()
        XCTAssertEqual(sut.transactions.count, 2)
        XCTAssertTrue(sut.allTransactionsLoaded)
    }

    func testLoadTransactionsDoesNothingWhenAllLoaded() async {
        mockService.totalPages = 1
        await sut.loadTransactions(reset: true)
        XCTAssertTrue(sut.allTransactionsLoaded)

        let countBefore = sut.transactions.count
        await sut.loadTransactions()
        XCTAssertEqual(sut.transactions.count, countBefore)
    }

    func testLoadTransactionsResetsFailureFlag() async {
        mockService.errorToThrow = APIError.invalidResponse
        await sut.loadTransactions(reset: true)
        XCTAssertTrue(sut.didFailLoadingTransaction)

        mockService.errorToThrow = nil
        await sut.loadTransactions(reset: true)

        XCTAssertFalse(sut.didFailLoadingTransaction)
    }

    // MARK: - reloadTransactionsIfDatesChanged

    func testReloadTransactionsIfDatesChangedReloadsWhenFromDateChanges() async {
        mockService.totalPages = 1
        await sut.loadTransactions(reset: true)
        let initialCount = sut.transactions.count

        let newTx = Transaction(id: "new-1", date: .now, transactionAmount: "99", transactionType: "payment", description: "New", isDebit: false)
        mockService.transactionsToReturn = [newTx]

        sut.fromDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        await sut.reloadTransactionsIfDatesChanged()

        XCTAssertEqual(sut.transactions.count, 1)
        XCTAssertNotEqual(sut.transactions.count, initialCount)
    }

    func testReloadTransactionsIfDatesChangedReloadsWhenToDateChanges() async {
        mockService.totalPages = 1
        await sut.loadTransactions(reset: true)

        let newTx = Transaction(id: "new-2", date: .now, transactionAmount: "50", transactionType: "payment", description: nil, isDebit: true)
        mockService.transactionsToReturn = [newTx]

        sut.toDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        await sut.reloadTransactionsIfDatesChanged()

        XCTAssertEqual(sut.transactions.count, 1)
    }

    func testReloadTransactionsIfDatesChangedDoesNothingWhenDatesUnchanged() async {
        mockService.totalPages = 1
        await sut.loadTransactions(reset: true)
        let initialTransactions = sut.transactions

        mockService.transactionsToReturn = []
        await sut.reloadTransactionsIfDatesChanged()

        XCTAssertEqual(sut.transactions, initialTransactions)
    }

    // MARK: - loadMoreIfNeeded

    func testLoadMoreIfNeededDoesNothingWhenAllLoaded() async {
        mockService.totalPages = 1
        await sut.loadTransactions(reset: true)
        XCTAssertTrue(sut.allTransactionsLoaded)

        let count = sut.transactions.count
        sut.loadMoreIfNeeded()

        // Give the Task a chance to run
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertEqual(sut.transactions.count, count)
    }

    func testLoadMoreIfNeededLoadsNextPage() async {
        let tx1 = Transaction(id: "first", date: .now, transactionAmount: "10", transactionType: "t", description: nil, isDebit: false)
        mockService.transactionsToReturn = [tx1]
        mockService.totalPages = 2

        await sut.loadTransactions(reset: true)
        XCTAssertFalse(sut.allTransactionsLoaded)

        let tx2 = Transaction(id: "second", date: .now.addingTimeInterval(-10), transactionAmount: "20", transactionType: "t", description: nil, isDebit: true)
        mockService.transactionsToReturn = [tx2]

        sut.loadMoreIfNeeded()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(sut.transactions.count, 2)
        XCTAssertTrue(sut.allTransactionsLoaded)
    }
}
