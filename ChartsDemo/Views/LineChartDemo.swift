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

    private static let femaleColor = Color.red
    private static let maleColor = Color.blue
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
                    LineMark(x: category, y: female)
                        .foregroundStyle(by: .value("Female", "Female"))

                    if showArea {
                        // Displaying multiple AreaMarks
                        // for the same x value is not supported.
                        AreaMark(x: category, y: male)
                            .foregroundStyle(
                                Self.maleColor.opacity(0.3)
                                    .gradient
                            )
                    }

                    if showPoints {
                        PointMark(x: category, y: male)
                            .foregroundStyle(Self.maleColor)
                        PointMark(x: category, y: female)
                            .foregroundStyle(Self.femaleColor)
                    }

                    if let data = selectedData,
                       statistic.category == data.category {
                        RuleMark(x: category)
                            .annotation(
                                position: annotationPosition(index)
                            ) {
                                annotation
                            }
                            .foregroundStyle(.red)
                            .lineStyle(.init(
                                lineWidth: 1,
                                dash: [10],
                                dashPhase: 5
                            ))
                    }
                }

                if showAverage {
                    RuleMark(y: .value("Male Average", maleAverage))
                        .foregroundStyle(Self.maleColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
                    RuleMark(y: .value("Female Average", femaleAverage))
                        .foregroundStyle(Self.femaleColor)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [10]))
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
        GeometryReader { _ in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let location = value.location
                            if let category: String =
                                proxy.value(atX: location.x) {
                                selectedData = categoryToDataMap[category]
                            }
                        }
                        .onEnded { _ in selectedData = nil }
                )
        }
    }
}
