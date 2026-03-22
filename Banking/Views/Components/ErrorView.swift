//
//  ErrorView.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

extension ErrorView {
    enum Size {
        case large, small
        
        var imageSize: CGFloat {
            switch self {
            case .large:
                280
            case .small:
                140
            }
        }
        
        var titleFont: Font {
            switch self {
            case .large:
                    .largeTitle.bold()
            case .small:
                    .headline
            }
        }
        
        var descriptionFont: Font {
            switch self {
            case .large:
                    .title2
            case .small:
                    .subheadline
            }
        }
        
        var itemSpacing: Double {
            switch self {
            case .large:
                32
            case .small:
                16
            }
        }
        
        var textSpacing: Double {
            switch self {
            case .large:
                16
            case .small:
                8
            }
        }
    }
}

struct ErrorView: View {
    var icon: ImageResource = .alert
    var title: LocalizedStringResource
    var description: LocalizedStringResource
    var size: Size = .large
    var onRetry: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: size.itemSpacing) {
            Image(icon)
                .accentArtstyle(size: size.imageSize, squashable: true)
            VStack(spacing: size.textSpacing) {
                Text(title)
                    .font(size.titleFont)
                Text(description)
                    .font(size.descriptionFont)
                    .foregroundStyle(.secondary)
            }
            .layoutPriority(1)
            if let onRetry {
                Button("Try Again") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            if size == .large {
                Color(UIColor.systemGroupedBackground)
            }
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

#Preview {
    ErrorView(
        title: "Houston, we have a problem!",
        description: "The connection fizzled out before we could load this page."
    ) {
        
    }
}

#Preview {
    ErrorView(
        icon: .box,
        title: "Houston, we have a problem!",
        description: "The connection fizzled out before we could load this page.",
        size: .small
    )
}
