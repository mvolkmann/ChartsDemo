import Charts
import SwiftUI

struct LineChart: View {
    private let vm = ViewModel.shared

    var body: some View {
        Chart {
            ForEach(vm.statistics) { row in
                if row.category != "All" {
                    LineMark(
                        x: .value("Age", row.category),
                        y: .value("Total", row.total)
                    )
                }
            }
        }
    }
}
