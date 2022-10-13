import Charts
import SwiftUI

struct ScatterPlotDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    @State private var categoryToDataMap: [String: AgeStatistics] = [:]
    @State private var selectedData: AgeStatistics?

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

    var body: some View {
        Chart {
            ForEach(vm.statistics.indices, id: \.self) { index in
                let statistic = vm.statistics[index]
                let category = PlottableValue.value(
                    "Age",
                    statistic.category
                )
                let male = PlottableValue.value("Male", statistic.male)
                let female = PlottableValue.value("Male", statistic.female)

                PointMark(x: category, y: male)
                    .foregroundStyle(maleColor)

                PointMark(x: category, y: female)
                    .foregroundStyle(femaleColor)

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
        .padding(.top, 70)

        // Support tapping on the plot area to see data point details.
        .chartOverlay { proxy in chartOverlay(proxy: proxy) }

        .onAppear {
            for statistic in vm.statistics {
                categoryToDataMap[statistic.category] = statistic
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

struct ScatterPlotDemo_Previews: PreviewProvider {
    static var previews: some View {
        ScatterPlotDemo()
    }
}
