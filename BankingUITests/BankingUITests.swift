//
//  BankingUITests.swift
//  BankingUITests
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import XCTest

@MainActor
final class BankingUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-useMockData", "-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Accounts List

    func testAccountsListDisplaysAllAccounts() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5), "First account name should be visible")
        XCTAssertTrue(app.staticTexts["Savings Goal"].exists, "Second account name should be visible")
        XCTAssertTrue(app.staticTexts["30003"].exists, "Third account should fall back to account number since it has no nickname")
    }

    func testAccountsListShowsNavigationTitle() throws {
        XCTAssertTrue(app.navigationBars["Select Account"].waitForExistence(timeout: 5))
    }

    func testAccountsListShowsAccountBalances() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))

        let balanceTexts = app.staticTexts.allElementsBoundByIndex.map { $0.label }
        let hasBalance = balanceTexts.contains { $0.contains("1,250") || $0.contains("1.250") }
        XCTAssertTrue(hasBalance, "Should display formatted balance for the first account")
    }

    func testAccountsListShowsAccountTypes() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Current"].exists, "Should display 'Current' account type")
        XCTAssertTrue(app.staticTexts["Savings"].exists, "Should display 'Savings' account type")
        XCTAssertTrue(app.staticTexts["Credit Card"].exists, "Should display 'Credit Card' account type")
    }

    // MARK: - Account Detail Navigation

    func testTapAccountNavigatesToDetail() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5), "Should show Account Details section")
    }

    func testAccountDetailShowsType() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Type"].exists, "Should show Type label")
        XCTAssertTrue(app.staticTexts["Current"].exists, "Should show account type value")
    }

    func testAccountDetailShowsBalance() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Balance"].exists, "Should show Balance label")
    }

    func testAccountDetailShowsProductName() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Product"].waitForExistence(timeout: 3), "Should show Product label")
        XCTAssertTrue(app.staticTexts["Product, Premium Checking"].exists, "Should show product name value")
    }

    func testAccountDetailShowsBranch() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Branch"].waitForExistence(timeout: 3), "Should show Branch label")
        XCTAssertTrue(app.staticTexts["Branch, Downtown Branch"].exists, "Should show branch value")
    }

    func testAccountDetailShowsBeneficiaries() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Beneficiaries"].waitForExistence(timeout: 3), "Should show Beneficiaries label")
        XCTAssertTrue(app.staticTexts["Beneficiaries, John Doe, Jane Doe"].exists, "Should show beneficiaries value")
    }

    // MARK: - Transactions

    func testAccountDetailShowsTransactionsSection() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Recent Transactions"].waitForExistence(timeout: 5), "Should show Recent Transactions section header")
    }

    func testAccountDetailShowsTransactionDescriptions() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Recent Transactions"].waitForExistence(timeout: 5))

        app.swipeUp()

        XCTAssertTrue(app.staticTexts["Grocery Store"].waitForExistence(timeout: 3), "Should show first transaction description")
        XCTAssertTrue(app.staticTexts["Salary Deposit"].exists, "Should show second transaction description")
        XCTAssertTrue(app.staticTexts["Electric Bill"].exists, "Should show third transaction description")
    }

    // MARK: - Favorite

    func testFavoriteButtonExistsInDetail() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        let starButton = app.buttons["favoriteButton"]
        XCTAssertTrue(starButton.waitForExistence(timeout: 3), "Should show favorite star button in toolbar")
    }

    func testTapFavoriteButtonToggles() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()
        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        let starButton = app.buttons["favoriteButton"]
        XCTAssertTrue(starButton.waitForExistence(timeout: 3))

        starButton.tap()
        let favoritedPredicate = NSPredicate(format: "label == 'Favorited'")
        expectation(for: favoritedPredicate, evaluatedWith: starButton, handler: nil)
        waitForExpectations(timeout: 3)

        starButton.tap()
        let notFavoritedPredicate = NSPredicate(format: "label == 'Not favorited'")
        expectation(for: notFavoritedPredicate, evaluatedWith: starButton, handler: nil)
        waitForExpectations(timeout: 3)

        XCTAssertTrue(starButton.exists)
    }

    // MARK: - Date Range Picker

    func testDateRangeButtonExistsInDetail() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        let dateRangeButton = app.buttons["Select date range"]
        XCTAssertTrue(dateRangeButton.waitForExistence(timeout: 3), "Should show date range button in toolbar")
    }

    func testDateRangeButtonOpensSheet() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        let dateRangeButton = app.buttons["Select date range"]
        XCTAssertTrue(dateRangeButton.waitForExistence(timeout: 3))
        dateRangeButton.tap()

        XCTAssertTrue(app.staticTexts["Select Date Range"].waitForExistence(timeout: 3), "Should show date range picker sheet title")
        XCTAssertTrue(app.staticTexts["From"].exists, "Should show From date picker")
        XCTAssertTrue(app.staticTexts["To"].exists, "Should show To date picker")
    }

    func testDateRangePickerHasDoneButton() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        app.buttons["Select date range"].tap()
        XCTAssertTrue(app.staticTexts["Select Date Range"].waitForExistence(timeout: 3))

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.exists, "Should show Done button")
    }

    func testDateRangePickerDismissesOnDone() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        app.buttons["Select date range"].tap()
        XCTAssertTrue(app.staticTexts["Select Date Range"].waitForExistence(timeout: 3))

        app.buttons["Done"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 3), "Should return to account detail after dismissing sheet")
    }

    // MARK: - Navigation Back

    func testBackNavigationFromDetail() throws {
        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5))
        app.staticTexts["My Salary"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))

        app.navigationBars.buttons.firstMatch.tap()

        XCTAssertTrue(app.staticTexts["My Salary"].waitForExistence(timeout: 5), "Should return to accounts list")
        XCTAssertTrue(app.staticTexts["Savings Goal"].exists)
    }

    // MARK: - Second Account Navigation

    func testNavigateToSecondAccount() throws {
        XCTAssertTrue(app.staticTexts["Savings Goal"].waitForExistence(timeout: 5))
        app.staticTexts["Savings Goal"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Savings"].exists, "Should show Savings type for second account")
    }

    func testNavigateToThirdAccountShowsAccountNumber() throws {
        XCTAssertTrue(app.staticTexts["30003"].waitForExistence(timeout: 5))
        app.staticTexts["30003"].tap()

        XCTAssertTrue(app.staticTexts["Account Details"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Credit Card"].exists, "Should show Credit Card type for third account")
    }

    // MARK: - Launch Performance

    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
