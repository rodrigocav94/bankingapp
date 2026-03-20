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

    private let apiService: APIService
    private let accountId: String
    private var currentPage = 0
    private var totalPages: Int?
    private let pageSize = 20
    private let fromDate: String
    private let toDate: String

    init(accountId: String, apiService: APIService = APIService()) {
        self.accountId = accountId
        self.apiService = apiService
        let now = Date()
        let tenYearsAgo = Calendar.current.date(byAdding: .year, value: -10, to: now)!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        self.fromDate = formatter.string(from: tenYearsAgo)
        self.toDate = formatter.string(from: now)
    }

    func loadDetail() async {
        isLoadingDetail = true
        didFailLoadingDetail = false
        do {
            detail = try await apiService.fetchAccountDetail(accountId: accountId)
        } catch {
            didFailLoadingDetail = true
            print(error.localizedDescription)
        }
        isLoadingDetail = false
    }

    func loadTransactions(reset: Bool = false) async {
        if reset {
            currentPage = 0
            transactions = []
            allTransactionsLoaded = false
            totalPages = nil
        }
        guard !allTransactionsLoaded else { return }
        isLoadingMore = true
        didFailLoadingTransaction = false
        do {
            let (newTransactions, paging) = try await apiService.fetchTransactions(
                accountId: accountId,
                page: currentPage,
                size: pageSize,
                fromDate: fromDate,
                toDate: toDate
            )
            transactions.append(contentsOf: newTransactions)
            totalPages = paging.pagesCount
            currentPage += 1
            if currentPage >= paging.pagesCount {
                allTransactionsLoaded = true
            }
        } catch {
            didFailLoadingTransaction = true
            print(error.localizedDescription)
        }
        isLoadingMore = false
    }

    func loadMoreIfNeeded(currentTransaction: Transaction?) {
        guard let current = currentTransaction,
              !isLoadingMore,
              !allTransactionsLoaded,
              let thresholdIndex = transactions.firstIndex(where: { $0.id == current.id }),
              thresholdIndex == transactions.index(transactions.endIndex, offsetBy: -5) else { return }
        Task { await loadTransactions() }
    }
}
