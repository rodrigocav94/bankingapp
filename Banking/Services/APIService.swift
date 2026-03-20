//
//  APIService.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}

class APIService {
    private let baseURL = "http://ktor-env.eba-asssfhm8.eu-west-1.elasticbeanstalk.com"
    private let session = URLSession.shared
    private let authHeader: String
    let decoder: JSONDecoder

    init() {
        let loginString = "Advantage:mobileAssignment"
        let loginData = Data(loginString.utf8)
        let base64LoginString = loginData.base64EncodedString()
        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        authHeader = "Basic \(base64LoginString)"
    }

    func fetchAccounts() async throws -> [Account] {
        guard let url = URL(string: "\(baseURL)/accounts") else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: request)
        
        let accounts = try decoder.decode([Account].self, from: data)
        return accounts
    }

    func fetchAccountDetail(accountId: String) async throws -> AccountDetail {
        guard let url = URL(string: "\(baseURL)/account/details/\(accountId)") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await session.data(for: request)
        
        let detail = try decoder.decode(AccountDetail.self, from: data)
        return detail
    }

    func fetchTransactions(accountId: String, page: Int, size: Int, fromDate: String, toDate: String) async throws -> ([Transaction], TransactionsResponse.Paging) {
        guard let url = URL(string: "\(baseURL)/account/transactions/\(accountId)") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")

        let body = TransactionsRequest(toDate: toDate, fromDate: fromDate, nextPage: page)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        let (data, _) = try await session.data(for: request)
        
        let response = try decoder.decode(TransactionsResponse.self, from: data)
        return (response.transactions, response.paging)
    }
}
