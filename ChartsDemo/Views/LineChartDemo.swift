import Charts
import SwiftUI

struct LineChartDemo: View {
    @State private var showArea = false
    @State private var showAverage = false
    @State private var showPoints = false

    private let vm = ViewModel.shared

    private var average: Double {
        let sum = vm.statistics.reduce(0) { acc, item in
            guard item.category != "All" else { return acc }
            return acc + item.total
        }
        return Double(sum) / Double(vm.statistics.count - 1)
    }

    var body: some View {
        VStack {
            VStack {
                Toggle("Show Area", isOn: $showArea)
                Toggle("Show Points", isOn: $showPoints)
                Toggle("Show Average Line", isOn: $showAverage)
            }
            .padding()

            Chart {
                ForEach(vm.statistics) { row in
                    if row.category != "All" {
                        let x = PlottableValue.value("Age", row.category)
                        let y = PlottableValue.value("Total", row.total)
                        LineMark(x: x, y: y)
                        if showArea {
                            AreaMark(x: x, y: y)
                                .foregroundStyle(.yellow.opacity(0.5).gradient)
                        }
                        if showPoints {
                            PointMark(x: x, y: y)
                                .foregroundStyle(.purple)
                        }
                    }
                }

                if showAverage {
                    RuleMark(y: .value("Average", average))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
                }
            }
            .chartXAxis(.hidden)
        }
    }
}
