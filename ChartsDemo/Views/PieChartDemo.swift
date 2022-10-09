import SwiftUI

struct PieChartDemo: View {
    var body: some View {
        // Swift Charts does not support pie charts.
        // This uses a custom view.
        PieChart(
            title: "MyPieChart",
            data: chartDataSet,
            separatorColor: Color(UIColor.systemBackground)
            // accentColors: Self.pieColors
        )
    }
}
