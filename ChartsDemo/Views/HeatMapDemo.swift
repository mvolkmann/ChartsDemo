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
                let xVal = 0
                let yVal = index
                let statistic = vm.statistics[index]
                let category = PlottableValue.value(
                    "Age",
                    statistic.category
                )

                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value("xStart", xVal),
                        xEnd: PlottableValue.value("xEnd", xVal + 1),
                        yStart: PlottableValue.value("yStart", yVal),
                        yEnd: PlottableValue.value("yEnd", yVal + 1)
                    )
                    .foregroundStyle(by: .value("Count", statistic.male))
                }
                // .accessibilityLabel("Male \(statistic.category)")
                // .accessibilityValue("\(statistic.male)")
                // .accessibilityHidden(false)

                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value("xStart", xVal + 1),
                        xEnd: PlottableValue.value("xEnd", xVal + 2),
                        yStart: PlottableValue.value("yStart", yVal),
                        yEnd: PlottableValue.value("yEnd", yVal + 1)
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
        /*
         .chartYAxis {
              let delta = 1_000_000
              AxisMarks(values: .stride(by: Double(delta))) {
                  let value = $0.as(Int.self)!
                  let foo = print("value = \(value)")
                  AxisGridLine()
                  AxisTick()
                  AxisValueLabel {
                      Text(value == 0 ? "" : "\(value / delta)M")
                  }
              }
         }
              */
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
        .frame(height: 500)
    }

    // MARK: - Methods
}

struct HeatMapDemo_Previews: PreviewProvider {
    static var previews: some View {
        HeatMapDemo()
    }
}
