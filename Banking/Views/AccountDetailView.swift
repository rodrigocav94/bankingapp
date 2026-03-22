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

    init(account: Account, apiService: APIService = APIService()) {
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
            AccountRowSection(account: account, isFavorite: false)
                .onAppear {
                    viewModel.isDisplayingTitle = false
                }
                .onDisappear {
                    viewModel.isDisplayingTitle = true
                }
            
            Section(
                header: Text("Account Details"),
                footer: HStack {
                    if viewModel.didFailLoadingDetail {
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
                }) {
                    LabeledContent("Type", value: String(localized: account.accountType.title))
                    LabeledContent("Balance", value: account.balance.asLocalizedCurrency(code: account.currencyCode))
                    if let detail = viewModel.detail {
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
                    } else if viewModel.isLoadingDetail {
                        progressView
                    }
                }
            
            Section("Recent Transactions") {
                if viewModel.didFailLoadingTransaction {
                    ErrorView(
                        title: "Unable to Load Transactions",
                        description: "We are experiencing delays in retrieving your statement. Please try again in a few minutes.",
                        size: .small
                    ) {
                        Task {
                            await viewModel.loadTransactions(reset: true, displayingAlertWhentFails: true)
                        }
                    }
                } else if viewModel.allTransactionsLoaded, viewModel.transactions.isEmpty {
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
                } else {
                    ForEach(viewModel.transactions, id: \.self) { transaction in
                        TransactionRow(transaction: transaction, currency: account.currencyCode)
                    }
                    if !viewModel.allTransactionsLoaded {
                        progressView
                            .onAppear {
                                if !viewModel.transactions.isEmpty {
                                    viewModel.loadMoreIfNeeded()
                                }
                            }
                    }
                }
            }
        }
        .navigationTitle(viewModel.isDisplayingTitle ? account.displayName : "")
        .toolbar {
            ToolbarItem {
                Button {
                    favoriteManager.toggleFavorite(accountId: account.id)
                } label: {
                    Image(systemName: favoriteManager.favoriteAccountIds.contains(account.id) ? "star.fill" : "star")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button {
                    viewModel.showingDateRangePicker = true
                } label: {
                    Label("Select date range", systemImage: "line.3.horizontal.decrease")
                }
                .buttonStyle(.borderedProminent)
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
    
    var progressView: some View {
        Color.clear
            .frame(height: 20)
            .overlay {
                ProgressView()
            }
    }
}

#Preview {
    NavigationStack {
        AccountDetailView(account: .example(), apiService: APIService())
    }
}
