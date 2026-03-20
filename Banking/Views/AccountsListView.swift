//
//  AccountsListView.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

struct AccountsListView: View {
    @StateObject private var viewModel = AccountsListViewModel()
    @StateObject private var favoriteManager = FavoriteManager.shared
    fileprivate var usingPlaceholder: Bool = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List((viewModel.isLoading || usingPlaceholder) ? viewModel.placeholderAccounts : viewModel.accounts) { account in
                accountRow(for: account)
            }
            .listSectionSpacing(16)
            .refreshable {
                await viewModel.loadAccounts()
            }
            .overlay {
                if viewModel.didFailLoading {
                    ErrorView {
                        Task { await viewModel.loadAccounts() }
                    }
                }
            }
            .navigationTitle("Select Account")
            .toolbar(viewModel.didFailLoading ? .hidden : .visible)
            .alert("Service Unreachable", isPresented: $viewModel.displayingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We're experiencing persistent connection issues. Please try again in a few minutes.")
            }
            .navigationDestination(for: Account.self) { account in
                EmptyView()
            }
        }
        .task {
            if !usingPlaceholder {
                await viewModel.loadAccounts()
            }
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
    }
}

#Preview {
    AccountsListView(usingPlaceholder: true)
}
