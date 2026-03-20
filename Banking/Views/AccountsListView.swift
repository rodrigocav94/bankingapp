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
    
    var body: some View {
        NavigationStack {
            List(viewModel.isLoading ? viewModel.placeholderAccounts : viewModel.accounts) { account in
                AccountRowSection(
                    account: account,
                    isFavorite: favoriteManager.isFavorited(id: account.id)
                )
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
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
            .navigationTitle("Accounts")
            .toolbar(viewModel.didFailLoading ? .hidden : .visible)
            .alert("Service Unreachable", isPresented: $viewModel.displayingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We're experiencing persistent connection issues. Please try again in a few minutes.")
            }
        }
        .task {
            await viewModel.loadAccounts()
        }
    }
}
