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

    init(account: Account) {
        self.account = account
        _viewModel = StateObject(
            wrappedValue: AccountDetailViewModel(
                accountId: account.id
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
                                await viewModel.loadDetail()
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
                if viewModel.didFailLoadingDetail {
                    ErrorView(
                        title: "Unable to Load Transactions",
                        description: "We are experiencing delays in retrieving your statement. Please try again in a few minutes.",
                        size: .small
                    ) {
                        Task {
                            await viewModel.loadTransactions(reset: true)
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
                            await viewModel.loadTransactions(reset: true)
                        }
                    }
                } else {
                    ForEach(viewModel.transactions) { transaction in
                        TransactionRow(transaction: transaction, currency: account.currencyCode)
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentTransaction: transaction)
                            }
                    }
                    if viewModel.isLoadingMore {
                        progressView
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
        }
        .task {
            await viewModel.loadDetail()
            await viewModel.loadTransactions(reset: true)
        }    }
    
    var progressView: some View {
        Color.clear
            .frame(height: 20)
            .overlay {
                ProgressView()
            }
    }
}

struct TransactionRow: View {
    let transaction: Transaction
    let currency: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description ?? transaction.transactionType)
                Text(transaction.date.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(transaction.transactionAmount.asLocalizedCurrency(code: currency))
                .bold()
        }
        .padding(.vertical, 4)
    }
}
