//
//  FavoriteManager.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation
import Combine

class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    
    @Published var favoriteAccountIds: Set<String> = []
    private let key = "favoriteAccounts"

    private init() {
        load()
    }

    func toggleFavorite(accountId: String) {
        if favoriteAccountIds.contains(accountId) {
            favoriteAccountIds.remove(accountId)
        } else {
            favoriteAccountIds.insert(accountId)
        }
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(favoriteAccountIds), forKey: key)
    }

    private func load() {
        if let array = UserDefaults.standard.array(forKey: key) as? [String] {
            favoriteAccountIds = Set(array)
        }
    }
    
    func isFavorited(id: String) -> Bool {
        favoriteAccountIds.contains(id)
    }
}
