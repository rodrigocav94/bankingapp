//
//  AccountRowSection.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

struct AccountRowSection: View {
    @Environment(\.redactionReasons) private var redactionReasons
    let account: Account
    let isFavorite: Bool
    
    private var accentGradient: some View {
        LinearGradient(
            stops: [
                .init(color: .accent.opacity(0.15), location: 0),
                .init(color: .clear, location: 0.5),
                .init(color: .clear, location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var illustrationBackground: some View {
        Image(account.accountType.illustration)
            .accentArtstyle()
            .offset(x: 60)
    }
    
    private var strokeOverlay: some View {
        RoundedRectangle(cornerRadius: 26)
            .stroke(.accent.gradient, lineWidth: 2)
            .opacity(0.65)
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                headerRow
                balanceText
            }
            .padding()
            .background(accentGradient)
            .background(alignment: .trailing) {
                if redactionReasons != .placeholder {
                    illustrationBackground
                }
            }
            .overlay(strokeOverlay)
            .frame(maxHeight: 163)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var headerRow: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.displayName)
                    .font(.title.weight(.semibold))
                    .italic()
                    .foregroundStyle(.accent.exposureAdjust(-1).gradient)
                Text(account.accountType.title)
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            if isFavorite {
                Image(systemName: "star.fill")
                    .font(.title3)
                    .fontWeight(.thin)
            }
        }
    }
    
    private var balanceText: some View {
        Text(account.balance.asLocalizedCurrency(code: account.currencyCode))
            .font(.system(size: 60, weight: .heavy, design: .default))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .foregroundStyle(.black.gradient)
    }
}

#Preview {
    List {
        AccountRowSection(account: .example(), isFavorite: true)
        AccountRowSection(account: .example(type: .savings), isFavorite: false)
        AccountRowSection(account: .example(type: .time), isFavorite: true)
        AccountRowSection(account: .example(type: .creditCard), isFavorite: false)
        AccountRowSection(account: .example(), isFavorite: false)
            .redacted(reason: .placeholder)
    }
}
