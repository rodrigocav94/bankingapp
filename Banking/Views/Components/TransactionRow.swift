//
//  TransactionRow.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 22/03/26.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let currency: String

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description ?? transaction.transactionType)
                Text(transaction.date.formatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(transaction.transactionAmount.asLocalizedCurrency(code: currency))
                .bold()
        }
        .padding(.vertical, 4)
        .onAppear {
            print(transaction)
        }
    }
}

#Preview {
    TransactionRow(transaction: .example, currency: "EUR")
}
