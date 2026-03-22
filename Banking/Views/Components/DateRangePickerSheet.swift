//
//  DateRangePickerSheet.swift
//  Banking
//
//  Created by Rodrigo Cavalcanti on 22/03/26.
//

import SwiftUI

struct DateRangePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fromDate: Date
    @Binding var toDate: Date

    var body: some View {
        NavigationStack {
            Form {
                Section("Choose a start and end date to view your transaction history for a specific period.") {
                    DatePicker("From", selection: $fromDate, in: ...toDate, displayedComponents: .date)
                    
                    DatePicker("To", selection: $toDate, in: fromDate..., displayedComponents: .date)
                }
            }
            .navigationTitle("Select Date Range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .presentationDetents([.height(300)])
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            DateRangePickerSheet(fromDate: .constant(Date()), toDate: .constant(Date()))
        }
}
