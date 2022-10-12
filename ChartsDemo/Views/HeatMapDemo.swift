import Charts
import SwiftUI

struct HeatMapDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    // MARK: - Properties

    private static let gradientColors: [Color] =
        [.blue, .green, .yellow, .orange, .red]

    private let squareSize = 10

    private let vm = ViewModel.shared

    var body: some View {
        Chart {
            ForEach(vm.statistics.indices, id: \.self) { index in
                let xVal = 0
                let yVal = index * squareSize
                let statistic = vm.statistics[index]
                let category = PlottableValue.value(
                    "Age",
                    statistic.category
                )

                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value("xStart", xVal),
                        xEnd: PlottableValue.value("xEnd", xVal + squareSize),
                        yStart: PlottableValue.value("yStart", yVal),
                        yEnd: PlottableValue.value("yEnd", yVal + squareSize)
                    )
                    .foregroundStyle(by: .value("Count", statistic.male))
                }
                Plot {
                    RectangleMark(
                        xStart: PlottableValue.value(
                            "xStart",
                            xVal + squareSize
                        ),
                        xEnd: PlottableValue.value(
                            "xEnd",
                            xVal + 2 * squareSize
                        ),
                        yStart: PlottableValue.value("yStart", yVal),
                        yEnd: PlottableValue.value("yEnd", yVal + squareSize)
                    )
                    .foregroundStyle(by: .value("Count", statistic.female))
                }
            }
        }
        .chartForegroundStyleScale(
            range: Gradient(colors: Self.gradientColors)
        )
        .chartYAxis {
            AxisMarks(position: .leading)
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
