import SwiftUI

struct HistoryEntry: Identifiable {
    let id = UUID()
    let calculation: String
    let result: String
}


struct HistoryView: View {
    @Binding var history: [HistoryEntry]
    
    var body: some View {
        NavigationView {
            List(history.reversed()) { entry in
                VStack(alignment: .leading) {
                    Text(entry.calculation)
                        .font(.headline)
                    Text("= \(entry.result)")
                        .font(.subheadline)
                }
            }
            .navigationBarTitle(Text("History"), displayMode: .inline)
            .toolbar {
                Button("Close") {
                }
            }
        }
    }
}

