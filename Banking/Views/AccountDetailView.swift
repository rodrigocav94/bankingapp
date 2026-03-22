//
//  AccountDetailView.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @StateObject private var viewModel: AccountDetailViewModel
    @ObservedObject var favoriteManager = FavoriteManager.shared

    init(account: Account, apiService: APIServiceProtocol = APIService()) {
        self.account = account
        _viewModel = StateObject(
            wrappedValue: AccountDetailViewModel(
                accountId: account.id,
                apiService: apiService
            )
        )
    }

    var body: some View {
        List {
            accountHeaderSection
            accountDetailsSection
            transactionsSection
        }
        .navigationTitle(viewModel.isDisplayingTitle ? account.displayName : "")
        .toolbar {
            ToolbarItem {
                favoriteButton
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                dateRangeButton
            }
        }
        .noConnectionAlert(isPresented: $viewModel.displayingErrorAlert)
        .sheet(isPresented: $viewModel.showingDateRangePicker, onDismiss: {
            Task {
                await viewModel.reloadTransactionsIfDatesChanged()
            }
        }) {
            DateRangePickerSheet(fromDate: $viewModel.fromDate, toDate: $viewModel.toDate)
        }
        .task {
            await viewModel.loadDetail()
            await viewModel.loadTransactions(reset: true)
        }
    }
}

// MARK: - Sections

private extension AccountDetailView {
    var accountHeaderSection: some View {
        AccountRowSection(account: account, isFavorite: false)
            .onAppear {
                viewModel.isDisplayingTitle = false
            }
            .onDisappear {
                viewModel.isDisplayingTitle = true
            }
    }

    var accountDetailsSection: some View {
        Section(
            header: Text("Account Details"),
            footer: detailRetryFooter
        ) {
            LabeledContent("Type", value: String(localized: account.accountType.title))
            LabeledContent("Balance", value: account.balance.asLocalizedCurrency(code: account.currencyCode))
            if let detail = viewModel.detail {
                detailRows(for: detail)
            } else if viewModel.isLoadingDetail {
                loadingIndicator
            }
        }
    }

    var transactionsSection: some View {
        Section("Recent Transactions") {
            if viewModel.didFailLoadingTransaction {
                transactionErrorView
            } else if viewModel.allTransactionsLoaded, viewModel.transactions.isEmpty {
                emptyTransactionsView
            } else {
                transactionsList
            }
        }
    }
}

// MARK: - Account Detail Subviews

private extension AccountDetailView {
    @ViewBuilder
    func detailRows(for detail: AccountDetail) -> some View {
        if let product = detail.productName {
            LabeledContent("Product", value: product)
        }
        if let opened = detail.openedDate {
            LabeledContent("Opened", value: opened.formatted())
        }
        if let branch = detail.branch {
            LabeledContent("Branch", value: branch)
        }
        if let beneficiaries = detail.beneficiaries, !beneficiaries.isEmpty {
            LabeledContent("Beneficiaries", value: beneficiaries.joined(separator: ", "))
        }
    }

    @ViewBuilder
    var detailRetryFooter: some View {
        if viewModel.didFailLoadingDetail {
            HStack {
                Text("We couldn't load more details for the selected account.")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button {
                    Task {
                        await viewModel.loadDetail(displayingAlertWhentFails: true)
                    }
                } label: {
                    Text("Retry")
                        .font(.callout)
                }
            }
        }
    }
}

// MARK: - Transaction Subviews

private extension AccountDetailView {
    var transactionErrorView: some View {
        ErrorView(
            title: "Unable to Load Transactions",
            description: "We are experiencing delays in retrieving your statement. Please try again in a few minutes.",
            size: .small
        ) {
            Task {
                await viewModel.loadTransactions(reset: true, displayingAlertWhentFails: true)
            }
        }
    }

    var emptyTransactionsView: some View {
        ErrorView(
            icon: .box,
            title: "No Transactions Found",
            description: "Try selecting a different time range.",
            size: .small
        ) {
            Task {
                await viewModel.loadTransactions(reset: true, displayingAlertWhentFails: true)
            }
        }
    }

    var transactionsList: some View {
        Group {
            ForEach(viewModel.transactions, id: \.self) { transaction in
                TransactionRow(transaction: transaction, currency: account.currencyCode)
            }
            if !viewModel.allTransactionsLoaded {
                loadingIndicator
                    .onAppear {
                        if !viewModel.transactions.isEmpty {
                            viewModel.loadMoreIfNeeded()
                        }
                    }
            }
        }
    }
}

// MARK: - Toolbar

private extension AccountDetailView {
    var favoriteButton: some View {
        Button {
            favoriteManager.toggleFavorite(accountId: account.id)
        } label: {
            Image(systemName: favoriteManager.favoriteAccountIds.contains(account.id) ? "star.fill" : "star")
        }
    }

    var dateRangeButton: some View {
        Button {
            viewModel.showingDateRangePicker = true
        } label: {
            Label("Select date range", systemImage: "line.3.horizontal.decrease")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .buttonStyle(.borderedProminent)
    }
}

// MARK: - Shared Components

private extension AccountDetailView {
    var loadingIndicator: some View {
        Color.clear
            .frame(height: 20)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    NavigationStack {
        AccountDetailView(account: .example(), apiService: MockAPIService())
    }
}
