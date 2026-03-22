//
//  FavoriteManagerTests.swift
//  BankingTests
//
//  Created by Rodrigo Cavalcanti on 3/22/26.
//

import XCTest
@testable import Banking

final class FavoriteManagerTests: XCTestCase {
    private let testKey = "favoriteAccounts"

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        super.tearDown()
    }

    // MARK: - Toggle & Query

    func testToggleFavoriteAddsAccount() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = []

        manager.toggleFavorite(accountId: "acc-1")

        XCTAssertTrue(manager.isFavorited(id: "acc-1"))
        XCTAssertTrue(manager.favoriteAccountIds.contains("acc-1"))
    }

    func testToggleFavoriteRemovesAccount() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = ["acc-1"]

        manager.toggleFavorite(accountId: "acc-1")

        XCTAssertFalse(manager.isFavorited(id: "acc-1"))
        XCTAssertFalse(manager.favoriteAccountIds.contains("acc-1"))
    }

    func testToggleFavoriteTwiceRestoresOriginalState() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = []

        manager.toggleFavorite(accountId: "acc-2")
        manager.toggleFavorite(accountId: "acc-2")

        XCTAssertFalse(manager.isFavorited(id: "acc-2"))
    }

    func testIsFavoritedReturnsFalseForUnknownId() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = []

        XCTAssertFalse(manager.isFavorited(id: "unknown"))
    }

    func testMultipleFavorites() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = []

        manager.toggleFavorite(accountId: "acc-1")
        manager.toggleFavorite(accountId: "acc-2")
        manager.toggleFavorite(accountId: "acc-3")

        XCTAssertTrue(manager.isFavorited(id: "acc-1"))
        XCTAssertTrue(manager.isFavorited(id: "acc-2"))
        XCTAssertTrue(manager.isFavorited(id: "acc-3"))
        XCTAssertEqual(manager.favoriteAccountIds.count, 3)
    }

    func testTogglePersistsToUserDefaults() {
        let manager = FavoriteManager.shared
        manager.favoriteAccountIds = []

        manager.toggleFavorite(accountId: "persisted-1")

        let saved = UserDefaults.standard.array(forKey: testKey) as? [String] ?? []
        XCTAssertTrue(saved.contains("persisted-1"))
    }
}
