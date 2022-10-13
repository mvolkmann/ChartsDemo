import Charts
import SwiftUI

struct HeatMapDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Properties

    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]

    private let vm = ViewModel.shared

    var body: some View {
        Chart {
            ForEach(vm.statistics.indices, id: \.self) { index in
                let statistic = vm.statistics[index]
                mark(statistic: statistic, isMale: true)
                mark(statistic: statistic, isMale: false)
            }
        }

        .padding(.leading, 60) // leaves room for y-axis labels
        .padding(.trailing, 20)

        .chartForegroundStyleScale(
            range: Gradient(colors: Self.gradientColors)
        )

        .chartYAxis(.hidden)
        // This changes the rectangle heights so they
        // no longer cover the entire plot area.
        /*
         .chartYAxis {
             AxisMarks { _ in
                 AxisGridLine()
                 AxisTick()
                 // Oddly .trailing causes the labels to be
                 // displayed on the leading edge of the chart.
                 AxisValueLabel(anchor: .trailing)
             }
         }
         */

        .frame(height: 500)
    }

    // MARK: - Methods

    private func mark(
        statistic: AgeStatistics,
        isMale: Bool
    ) -> some ChartContent {
        let label = isMale ? "Male" : "Female"
        let value = isMale ? statistic.male : statistic.female
        return Plot {
            RectangleMark(
                // This approach loses the x-axis labels.
                /*
                 xStart: PlottableValue.value("xStart", 0),
                 xEnd: PlottableValue.value("xEnd", 1),
                 yStart: PlottableValue.value("yStart", index),
                 yEnd: PlottableValue.value("yEnd", index + 1)
                 */

                x: .value("Gender", label),
                y: .value("Category", statistic.category),
                width: .ratio(1),
                height: .ratio(1)
            )
            .foregroundStyle(by: .value("Count", value))
        }
        .accessibilityLabel("\(label) \(statistic.category)")
        .accessibilityValue("\(value)")
        .accessibilityHidden(false)
    }
}

struct HeatMapDemo_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapDemo()
    }
}
