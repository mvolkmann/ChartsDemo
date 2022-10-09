import SwiftUI

struct PieChartDemo: View {
    private let vm = ViewModel.shared

    private var sliceData: [ChartData] {
        var data: [ChartData] = []
        for row in vm.statistics {
            if row.category != "All" {
                data.append(ChartData(
                    label: row.category,
                    value: Double(row.total)
                ))
            }
        }
        return data
    }

    var body: some View {
        // Swift Charts does not support pie charts.
        // This uses a custom view.
        PieChart(
            title: "MyPieChart",
            data: sliceData,
            keyColumns: 3
        )
    }
}
