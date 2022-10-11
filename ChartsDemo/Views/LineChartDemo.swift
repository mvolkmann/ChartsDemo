import Charts
import SwiftUI

struct LineChartDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    @State private var categoryToTotalMap: [String: Int] = [:]
    @State private var selectedCategory = ""
    @State private var selectedTotal = 0

    @State private var showArea = false
    @State private var showAverage = false
    @State private var showPoints = false

    // MARK: - Properties

    private let vm = ViewModel.shared

    private var annotation: some View {
        VStack {
            Text(selectedCategory)
            Text("\(selectedTotal)")
        }
        .padding(5)
        .background {
            let fillColor: Color = colorScheme == .light ?
                .white : Color(.secondarySystemBackground)
            let myFill = fillColor.shadow(.drop(radius: 3))
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(myFill)
        }
        .foregroundColor(Color(.label))
    }

    private var average: Double {
        let sum = vm.statistics.reduce(0) { $0 + $1.total }
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
                    let x = PlottableValue.value("Age", statistic.category)
                    let y = PlottableValue.value("Total", statistic.total)
                    LineMark(x: x, y: y)

                    if showArea {
                        AreaMark(x: x, y: y)
                            .foregroundStyle(.yellow.opacity(0.5).gradient)
                    }

                    if showPoints {
                        PointMark(x: x, y: y)
                            .foregroundStyle(.purple)
                    }

                    if statistic.category == selectedCategory {
                        RuleMark(x: .value("Age", selectedCategory))
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
                    RuleMark(y: .value("Average", average))
                        .foregroundStyle(.red)
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
                for stat in vm.statistics {
                    categoryToTotalMap[stat.category] = stat.total
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
                                selectedCategory = category
                                selectedTotal =
                                    categoryToTotalMap[category] ?? 0
                            }
                        }
                        .onEnded { _ in selectedCategory = "" }
                )
        }
    }
}
