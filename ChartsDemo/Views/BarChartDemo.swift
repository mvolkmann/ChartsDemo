import Charts
import SwiftUI

struct BarChartDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    @State private var categoryToDataMap: [String: AgeStatistics] = [:]
    @State private var selectedData: AgeStatistics?
    @State private var show: [Bool] = []

    // MARK: - Properties

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
        // Adding a ScrollView breaks the ability to drag across the bars
        // and display an annotation above the current bar.
        // ScrollView(.horizontal) {
        Chart {
            ForEach(vm.statistics.indices, id: \.self) { index in
                let statistic = vm.statistics[index]
                let category = PlottableValue.value(
                    "Age",
                    statistic.category
                )

                let shouldShow = index < show.count && show[index] == true

                let maleValue = shouldShow ? statistic.male : 0
                BarMark(x: category, y: .value("Male", maleValue))
                    .foregroundStyle(by: .value("Gender", "Male"))
                // .position(by: .value("Gender", "Male"))

                let femaleValue = shouldShow ? statistic.female : 0
                BarMark(x: category, y: .value("Female", femaleValue))
                    .foregroundStyle(by: .value("Gender", "Female"))
                // .position(by: .value("Gender", "Female"))

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

        // Remove this to see category names below each bar.
        .chartXAxis(.hidden)

        .chartYAxis {
            let delta = 1_000_000
            AxisMarks(
                position: .leading, // moves y-axis from right to left side
                values: .stride(by: Double(delta))
            ) {
                let value = $0.as(Int.self)!
                AxisGridLine()
                AxisTick()
                // Formats y-axis labels to be a number of millions
                // followed by the letter M.
                AxisValueLabel {
                    Text(value == 0 ? "" : "\(value / delta)M")
                }
            }
        }

        .chartPlotStyle { plotArea in
            plotArea
                // Uncomment this when embedding Chart in a ScrollView.
                // .frame(width: 1000, height: 400)
                .background(.yellow.opacity(0.2))
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
            animateChart()
        }
    }

    // MARK: - Methods

    private func animateChart() {
        show = []
        for index in vm.statistics.indices {
            // Delay rendering each data point a bit longer than the previous one.
            DispatchQueue.main.asyncAfter(
                deadline: .now() + Double(index) * 0.05
            ) {
                let spring = 0.5
                withAnimation(.interactiveSpring(
                    response: spring,
                    dampingFraction: spring,
                    blendDuration: spring
                )) {
                    show.append(true)
                }
            }
        }
    }

    private func annotationPosition(_ index: Int) -> AnnotationPosition {
        let percent = Double(index) / Double(vm.statistics.count)
        return percent < 0.1 ? .topTrailing :
            percent > 0.95 ? .topLeading :
            .top
    }

    private func chartOverlay(proxy: ChartProxy) -> some View {
        GeometryReader { geometry in
            let areaX = geometry[proxy.plotAreaFrame].origin.x
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())

                /*
                 // Handle tap gestures.
                 .onTapGesture { value in
                     let x = value.x - areaX
                     if let category: String = proxy.value(atX: x) {
                         let data = categoryToDataMap[category]
                         print("got tap on", data)
                     }
                 }
                 */

                // Handle drag gestures.
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let x = value.location.x - areaX
                            if let category: String = proxy.value(atX: x) {
                                selectedData = categoryToDataMap[category]
                            }
                        }
                        .onEnded { _ in selectedData = nil }
                )
        }
    }
}
