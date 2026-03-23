//
//  ModelTests.swift
//  BankingTests
//
//  Created by Rodrigo Cavalcanti on 3/22/26.
//

import XCTest
@testable import Banking

@MainActor
final class ModelTests: XCTestCase {

    // MARK: - Account

    func testDisplayNameReturnsNicknameWhenPresent() {
        let account = Account(id: "1", accountNumber: 12345, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: "My Salary")
        XCTAssertEqual(account.displayName, "My Salary")
    }

    func testDisplayNameReturnsAccountNumberWhenNoNickname() {
        let account = Account(id: "1", accountNumber: 12345, balance: "100.00", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        XCTAssertEqual(account.displayName, "12345")
    }

    func testAccountExample() {
        let account = Account.example()
        XCTAssertEqual(account.accountNumber, 12345)
        XCTAssertEqual(account.balance, "99.00")
        XCTAssertEqual(account.currencyCode, "EUR")
        XCTAssertEqual(account.accountNickname, "My Salary")
    }

    func testAccountExampleWithSpecificType() {
        let account = Account.example(type: .creditCard)
        XCTAssertEqual(account.accountType, .creditCard)
    }

    func testAccountConformsToHashable() {
        let a = Account(id: "1", accountNumber: 111, balance: "10", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        let b = Account(id: "1", accountNumber: 111, balance: "10", currencyCode: "EUR", accountType: .current, accountNickname: nil)
        XCTAssertEqual(a, b)
    }

    // MARK: - AccountType

    func testAccountTypeRawValues() {
        XCTAssertEqual(AccountType.current.rawValue, "current")
        XCTAssertEqual(AccountType.savings.rawValue, "savings")
        XCTAssertEqual(AccountType.time.rawValue, "time")
        XCTAssertEqual(AccountType.creditCard.rawValue, "credit card")
    }

    func testAccountTypeCaseIterable() {
        XCTAssertEqual(AccountType.allCases.count, 4)
    }

    func testAccountTypeDecodingFromSnakeCase() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let json = Data(#""credit card""#.utf8)
        let type = try decoder.decode(AccountType.self, from: json)
        XCTAssertEqual(type, .creditCard)
    }

    // MARK: - Transaction

    func testTransactionExample() {
        let tx = Transaction.example
        XCTAssertEqual(tx.transactionAmount, "478.51")
        XCTAssertEqual(tx.transactionType, "intrabank")
        XCTAssertNil(tx.description)
        XCTAssertFalse(tx.isDebit)
    }

    func testTransactionConformsToHashable() {
        let date = Date.now
        let a = Transaction(id: "1", date: date, transactionAmount: "10", transactionType: "t", description: nil, isDebit: false)
        let b = Transaction(id: "1", date: date, transactionAmount: "10", transactionType: "t", description: nil, isDebit: false)
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    // MARK: - AccountDetail

    func testAccountDetailAllFieldsNil() {
        let detail = AccountDetail(productName: nil, openedDate: nil, branch: nil, beneficiaries: nil)
        XCTAssertNil(detail.productName)
        XCTAssertNil(detail.openedDate)
        XCTAssertNil(detail.branch)
        XCTAssertNil(detail.beneficiaries)
    }

    func testAccountDetailWithAllFields() {
        let date = Date()
        let detail = AccountDetail(productName: "Premium", openedDate: date, branch: "Main", beneficiaries: ["Alice", "Bob"])
        XCTAssertEqual(detail.productName, "Premium")
        XCTAssertEqual(detail.openedDate, date)
        XCTAssertEqual(detail.branch, "Main")
        XCTAssertEqual(detail.beneficiaries, ["Alice", "Bob"])
    }

    // MARK: - Account JSON Decoding

    func testAccountDecoding() throws {
        let json = """
        {
            "id": "abc",
            "account_number": 99999,
            "balance": "1234.56",
            "currency_code": "USD",
            "account_type": "savings",
            "account_nickname": "Vacation Fund"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let account = try decoder.decode(Account.self, from: json)
        XCTAssertEqual(account.id, "abc")
        XCTAssertEqual(account.accountNumber, 99999)
        XCTAssertEqual(account.balance, "1234.56")
        XCTAssertEqual(account.currencyCode, "USD")
        XCTAssertEqual(account.accountType, .savings)
        XCTAssertEqual(account.accountNickname, "Vacation Fund")
    }

    func testAccountDecodingWithNullNickname() throws {
        let json = """
        {
            "id": "abc",
            "account_number": 11111,
            "balance": "0.00",
            "currency_code": "EUR",
            "account_type": "current",
            "account_nickname": null
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let account = try decoder.decode(Account.self, from: json)
        XCTAssertNil(account.accountNickname)
        XCTAssertEqual(account.displayName, "11111")
    }

    // MARK: - TransactionsResponse Decoding

    func testTransactionsResponseDecoding() throws {
        let json = """
        {
            "transactions": [
                {
                    "id": "tx1",
                    "date": "2026-01-15T10:30:00Z",
                    "transaction_amount": "50.00",
                    "transaction_type": "transfer",
                    "description": "Coffee Shop",
                    "is_debit": true
                }
            ],
            "paging": {
                "pages_count": 3,
                "total_items": 50,
                "current_page": 0
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let response = try decoder.decode(TransactionsResponse.self, from: json)
        XCTAssertEqual(response.transactions.count, 1)
        XCTAssertEqual(response.transactions.first?.description, "Coffee Shop")
        XCTAssertTrue(response.transactions.first?.isDebit ?? false)
        XCTAssertEqual(response.paging.pagesCount, 3)
        XCTAssertEqual(response.paging.totalItems, 50)
        XCTAssertEqual(response.paging.currentPage, 0)
    }

    // MARK: - TransactionsRequest Encoding

    func testTransactionsRequestEncoding() throws {
        let request = TransactionsRequest(toDate: "2026-03-22T00:00:00Z", fromDate: "2026-01-01T00:00:00Z", nextPage: 2)

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try encoder.encode(request)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(dict["to_date"] as? String, "2026-03-22T00:00:00Z")
        XCTAssertEqual(dict["from_date"] as? String, "2026-01-01T00:00:00Z")
        XCTAssertEqual(dict["next_page"] as? Int, 2)
    }

    // MARK: - String Currency Extension

    func testAsLocalizedCurrencyWithValidNumber() {
        let result = "99.99".asLocalizedCurrency(code: "USD")
        XCTAssertTrue(result.contains("99"))
    }

    func testAsLocalizedCurrencyWithInvalidNumber() {
        let result = "not-a-number".asLocalizedCurrency(code: "EUR")
        XCTAssertEqual(result, "not-a-number EUR")
    }

    func testAsLocalizedCurrencyWithZero() {
        let result = "0".asLocalizedCurrency(code: "GBP")
        XCTAssertTrue(result.contains("0"))
    }

    func testAsLocalizedCurrencyWithNegativeNumber() {
        let result = "-50.00".asLocalizedCurrency(code: "USD")
        XCTAssertTrue(result.contains("50"))
    }
}
