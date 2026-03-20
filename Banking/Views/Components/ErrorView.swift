//
//  ErrorView.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

struct ErrorView: View {
    var onRetry: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            Image(.alert)
                .accentArtstyle()
            VStack {
                Text("Houston, we have a problem!")
                    .font(.headline)
                Text("The connection fizzled out before we could load this page.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Button("Try Again") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color(UIColor.systemGroupedBackground)
        )
    }
}

#Preview {
    ErrorView {}
}
