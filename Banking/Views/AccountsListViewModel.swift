//
//  AccountsListViewModel.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI
import Combine

@MainActor
class AccountsListViewModel: ObservableObject {
    let placeholderAccounts: [Account] = [Int](repeating: 1, count: 5).map {_ in .example()}
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var didFailLoading: Bool = false
    @Published var displayingErrorAlert: Bool = false

    private let apiService = APIService()

    func loadAccounts() async {
        isLoading = true
        didFailLoading = false
        do {
            accounts = try await apiService.fetchAccounts()
        } catch {
            print(error.localizedDescription)
            didFailLoading = true
            displayingErrorAlert = true
        }
        isLoading = false
    }
}
