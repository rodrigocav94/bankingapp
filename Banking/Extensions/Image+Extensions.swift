//
//  Image+Extensions.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

extension Image {
    func accentArtstyle(size: Double = 280, squashable: Bool = false) -> some View {
        self
        .resizable()
        .scaledToFit()
        .frame(minHeight: squashable ? 0 : size, maxHeight: size)
        .background(.white)
        .overlay(Color.accent.blendMode(.screen))
        .mask {
            LinearGradient(
                stops: [
                    .init(color: .black, location: 0),
                    .init(color: .black, location: 0.3),
                    .init(color: .clear, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .blendMode(.multiply)
    }
}
