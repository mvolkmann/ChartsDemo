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
                let foo = print("index = \(index)")
                let statistic = vm.statistics[index]

                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value("xStart", 0),
                        xEnd: PlottableValue.value("xEnd", 1),
                        yStart: PlottableValue.value("yStart", index),
                        yEnd: PlottableValue.value("yEnd", index + 1)
                    )
                    .foregroundStyle(by: .value("Count", statistic.male))
                }
                // .accessibilityLabel("Male \(statistic.category)")
                // .accessibilityValue("\(statistic.male)")
                // .accessibilityHidden(false)

                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value("xStart", 1),
                        xEnd: PlottableValue.value("xEnd", 2),
                        yStart: PlottableValue.value("yStart", index),
                        yEnd: PlottableValue.value("yEnd", index + 1)
                    )
                    .foregroundStyle(by: .value("Count", statistic.female))
                }
                // .accessibilityLabel("Female \(statistic.category)")
                // .accessibilityValue("\(statistic.female)")
                // .accessibilityHidden(false)
            }
        }
        .chartForegroundStyleScale(
            range: Gradient(colors: Self.gradientColors)
        )
        .chartXAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel(centered: true) {
                    Text(
                        value.index == 0 ? "Male" :
                            value.index == 1 ? "Female" :
                            ""
                    )
                }
            }
        }
        .chartYAxis {
            // let delta = 1_000_000
            // AxisMarks(values: .stride(by: Double(delta))) { _ in
            // We have 18 categories and rows of RectangleMarks.
            // Why don't we get 18 values here?  We only get 5!
            AxisMarks { value in
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    let foo = print("value =", value)
                    // Text(value == 0 ? "" : "\(value / delta)M")
                    Text("\(value.index)")
                }
            }
        }
        .frame(height: 500)
    }

    // MARK: - Methods
}

struct HeatMapDemo_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapDemo()
    }
}
