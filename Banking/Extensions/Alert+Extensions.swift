//
//  Alert+Extensions.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 3/20/26.
//

import SwiftUI

extension View {
    func noConnectionAlert(isPresented: Binding<Bool>) -> some View {
        self
        .alert("Service Unreachable", isPresented: isPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("We're experiencing persistent connection issues. Please try again in a few minutes.")
        }
    }
}
