import Charts
import SwiftUI

struct BarChart: View {
    private let vm = ViewModel.shared

    var body: some View {
        Chart {
            ForEach(vm.statistics) { row in
                if row.category != "All" {
                    BarMark(
                        x: .value("Age", row.category),
                        y: .value("Total", row.total)
                    )
                }
            }
        }
    }
}
