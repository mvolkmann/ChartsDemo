import Charts
import SwiftUI

struct LineChartDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    @State private var categoryToDataMap: [String: AgeStatistics] = [:]
    @State private var selectedData: AgeStatistics?

    @State private var showArea = false
    @State private var showAverage = false
    @State private var showPoints = false

    // MARK: - Properties

    private let femaleColor = Color.red
    private let maleColor = Color.blue
    private let vm = ViewModel.shared

    private var annotation: some View {
        VStack {
            if let selectedData {
                Text(selectedData.category)
                Text("Male: \(selectedData.male)")
                Text("Female: \(selectedData.female)")
            }
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(annotationFill)
        }
        .foregroundColor(Color(.label))
    }

    private var annotationFill: some ShapeStyle {
        let fillColor: Color = colorScheme == .light ?
            .white : Color(.secondarySystemBackground)
        return fillColor.shadow(.drop(radius: 3))
    }

    private var femaleAverage: Double {
        let sum = vm.statistics.reduce(0) { $0 + $1.female }
        return Double(sum) / Double(vm.statistics.count - 1)
    }

    private var maleAverage: Double {
        let sum = vm.statistics.reduce(0) { $0 + $1.male }
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
                ForEach(vm.statistics.indices, id: \.self) { index in
                    let statistic = vm.statistics[index]
                    let category = PlottableValue.value(
                        "Age",
                        statistic.category
                    )
                    let male = PlottableValue.value("Male", statistic.male)
                    let female = PlottableValue.value("Male", statistic.female)

                    LineMark(x: category, y: male)
                        .foregroundStyle(by: .value("Male", "Male"))
                    // If each statistic object had a gender property
                    // and only held a value for that gender,
                    // the previous line would be replaced by this:
                    // .foregroundStyle(by: .value("Gender", statistic.gender))

                    LineMark(x: category, y: female)
                        .foregroundStyle(by: .value("Female", "Female"))

                    if showArea {
                        // Displaying multiple AreaMarks
                        // for the same x value is not supported.
                        AreaMark(x: category, y: male)
                            .foregroundStyle(
                                maleColor.opacity(0.3).gradient
                            )
                    }

                    if showPoints {
                        PointMark(x: category, y: male)
                            .foregroundStyle(maleColor)
                            .symbol(by: .value("Gender", "Male"))
                        PointMark(x: category, y: female)
                            .foregroundStyle(femaleColor)
                            .symbol(by: .value("Gender", "Female"))
                    }

                    if statistic.category == selectedData?.category {
                        RuleMark(x: category)
                            .annotation(position: annotationPosition(index)) {
                                annotation
                            }
                            // Display a red, dashed, vertical line.
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(dash: [10, 5]))
                    }
                }

                if showAverage {
                    RuleMark(y: .value("Male Average", maleAverage))
                        .foregroundStyle(maleColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
                        .annotation(position: .bottom, alignment: .leading) {
                            Text("Male Average").font(.caption)
                        }
                    RuleMark(y: .value("Female Average", femaleAverage))
                        .foregroundStyle(femaleColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
                        .annotation(position: .top, alignment: .leading) {
                            Text("Female Average").font(.caption)
                        }
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                let delta = 1_000_000
                AxisMarks(values: .stride(by: Double(delta))) {
                    let value = $0.as(Int.self)!
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        Text(value == 0 ? "" : "\(value / delta)M")
                    }
                }
            }
            .chartForegroundStyleScale([
                "Male": maleColor,
                "Female": femaleColor,
            ])

            // Leave room for RuleMark annotations.
            .padding(.horizontal, 20)
            .padding(.top, 55)

            // Support tapping on the plot area to see data point details.
            .chartOverlay { proxy in chartOverlay(proxy: proxy) }

            .onAppear {
                for statistic in vm.statistics {
                    categoryToDataMap[statistic.category] = statistic
                }
            }
        }
    }

    // MARK: - Methods

    private func annotationPosition(_ index: Int) -> AnnotationPosition {
        let percent = Double(index) / Double(vm.statistics.count)
        return percent < 0.1 ? .topTrailing :
            percent > 0.95 ? .topLeading :
            .top
    }

    private func chartOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let x = value.location.x -
                                geometry[proxy.plotAreaFrame].origin.x
                            if let category: String = proxy.value(atX: x) {
                                selectedData = categoryToDataMap[category]
                            }
                        }
                        .onEnded { _ in selectedData = nil }
                )
        }
    }
}
