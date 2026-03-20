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
        VStack(spacing: 32) {
            Image(.alert)
                .accentArtstyle()
            VStack(spacing: 16) {
                Text("Houston, we have a problem!")
                    .font(.largeTitle.bold())
                Text("The connection fizzled out before we could load this page.")
                    .font(.title2)
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
