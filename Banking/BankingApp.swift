//
//  BankingApp.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

@main
struct BankingApp: App {
    private let apiService: APIServiceProtocol

    init() {
        if ProcessInfo.processInfo.arguments.contains("-useMockData") {
            apiService = MockAPIService()
        } else {
            apiService = APIService()
        }
    }

    var body: some Scene {
        WindowGroup {
            AccountsListView(apiService: apiService)
        }
    }
}
