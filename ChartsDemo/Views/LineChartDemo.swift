import Charts
import SwiftUI

struct LineChartDemo: View {
    private let vm = ViewModel.shared

    var body: some View {
        Chart {
            ForEach(vm.statistics) { row in
                if row.category != "All" {
                    let x = PlottableValue.value("Age", row.category)
                    let y = PlottableValue.value("Total", row.total)
                    LineMark(x: x, y: y)
                    PointMark(x: x, y: y)
                }
            }
        }
        .chartXAxis(.hidden)
    }
}
