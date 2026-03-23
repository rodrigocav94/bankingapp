//
//  AccountsListView.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

struct AccountsListView: View {
    @Namespace private var namespace
    @StateObject private var viewModel: AccountsListViewModel
    @StateObject private var favoriteManager = FavoriteManager.shared

    init(apiService: APIServiceProtocol = APIService()) {
        _viewModel = StateObject(wrappedValue: AccountsListViewModel(apiService: apiService))
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List((viewModel.isLoading) ? viewModel.placeholderAccounts : viewModel.accounts) { account in
                accountRow(for: account)
            }
            .listSectionSpacing(16)
            .refreshable {
                await viewModel.loadAccounts()
            }
            .overlay {
                if viewModel.didFailLoading {
                    ErrorView(
                        title: "Houston, we have a problem!",
                        description: "The connection fizzled out before we could load this page."
                    ) {
                        Task { await viewModel.loadAccounts() }
                    }
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationTitle("Select Account")
            .toolbar(viewModel.didFailLoading ? .hidden : .visible)
            .noConnectionAlert(isPresented: $viewModel.displayingErrorAlert)
            .navigationDestination(for: Account.self) { account in
                AccountDetailView(account: account, apiService: viewModel.apiService)
                    .navigationTransition(
                        .zoom(
                            sourceID: account.id,
                            in: namespace
                        )
                    )
            }
        }
        .task {
            await viewModel.loadAccounts()
        }
    }
    
    func accountRow(for account: Account) -> some View {
        AccountRowSection(
            account: account,
            isFavorite: favoriteManager.isFavorited(id: account.id)
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .onTapGesture {
            viewModel.didTap(account: account)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Goes to \(account.displayName) details")
        .accessibilityLabel("Account: \(account.displayName)")
        .matchedTransitionSource(id: account.id, in: namespace)
    }
}

#Preview {
    AccountsListView(apiService: MockAPIService())
}
