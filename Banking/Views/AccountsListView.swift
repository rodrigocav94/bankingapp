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
            Group {
                if viewModel.didFailLoading {
                    ErrorView {
                        Task { await viewModel.loadAccounts() }
                    }
                } else {
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
                }
            }
            .navigationTitle("Accounts")
        }
        .task {
            await viewModel.loadAccounts()
        }
    }
}
