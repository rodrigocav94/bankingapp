//
//  AccountDetailViewModel.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI
import Combine

@MainActor
class AccountDetailViewModel: ObservableObject {
    @Published var detail: AccountDetail?
    @Published var transactions: [Transaction] = []
    @Published var isLoadingDetail = false
    @Published var isLoadingMore = false
    @Published var didFailLoadingDetail: Bool = false
    @Published var didFailLoadingTransaction: Bool = false
    @Published var allTransactionsLoaded = false
    @Published var isDisplayingTitle = false
    @Published var displayingErrorAlert = false
    @Published var fromDate: Date
    @Published var toDate: Date

    private let apiService: APIService
    private let accountId: String
    private var currentPage = 0
    private var totalPages: Int?
    private let pageSize = 20
    private var lastLoadedFromDate: Date
    private var lastLoadedToDate: Date

    init(accountId: String, apiService: APIService = APIService()) {
        self.accountId = accountId
        self.apiService = apiService
        let now = Date()
        self.toDate = now
        let thirtyYearsAgo = Calendar.current.date(byAdding: .year, value: -30, to: now)!
        self.fromDate = thirtyYearsAgo
        self.lastLoadedFromDate = thirtyYearsAgo
        self.lastLoadedToDate = now
    }

    func loadDetail(displayingAlertWhentFails: Bool = false) async {
        isLoadingDetail = true
        didFailLoadingDetail = false
        do {
            detail = try await apiService.fetchAccountDetail(accountId: accountId)
        } catch {
            if displayingAlertWhentFails {
                displayingErrorAlert = true
            }
            didFailLoadingDetail = true
            print(error.localizedDescription)
        }
        isLoadingDetail = false
    }

    func loadTransactions(reset: Bool = false, displayingAlertWhentFails: Bool = false) async {
        if reset {
            currentPage = 0
            transactions = []
            allTransactionsLoaded = false
            totalPages = nil
        }
        guard !allTransactionsLoaded else { return }
        isLoadingMore = true
        didFailLoadingTransaction = false
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        
        let fromDate = formatter.string(from: fromDate)
        let toDate = formatter.string(from: toDate)
        
        do {
            let (newTransactions, paging) = try await apiService.fetchTransactions(
                accountId: accountId,
                page: currentPage,
                size: pageSize,
                fromDate: fromDate,
                toDate: toDate
            )
            var updatedTransactions = transactions
            updatedTransactions.append(contentsOf: newTransactions)
            updatedTransactions = Array(Set(updatedTransactions)).sorted(by: {$0.date > $1.date})
            transactions = updatedTransactions
            
            totalPages = paging.pagesCount
            currentPage += 1
            if currentPage >= paging.pagesCount {
                allTransactionsLoaded = true
            }
        } catch {
            if displayingAlertWhentFails {
                displayingErrorAlert = true
            }
            didFailLoadingTransaction = true
            print(error.localizedDescription)
        }
        isLoadingMore = false
    }

    func reloadTransactionsIfDatesChanged() async {
        guard fromDate != lastLoadedFromDate || toDate != lastLoadedToDate else { return }
        lastLoadedFromDate = fromDate
        lastLoadedToDate = toDate
        await loadTransactions(reset: true)
    }

    func loadMoreIfNeeded() {
        if isLoadingMore || allTransactionsLoaded {
            return
        }
        Task { await loadTransactions() }
    }
}
