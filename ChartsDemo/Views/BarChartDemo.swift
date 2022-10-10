import Charts
import SwiftUI

struct BarChartDemo: View {
    // MARK: - State

    @Environment(\.colorScheme) var colorScheme

    @State private var categoryToTotalMap: [String: Int] = [:]
    @State private var selectedCategory = ""
    @State private var selectedTotal = 0

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

    var body: some View {
        Chart {
            ForEach(vm.statistics.indices, id: \.self) { index in
                let statistic = vm.statistics[index]

                BarMark(
                    x: .value("Age", statistic.category),
                    y: .value("Total", statistic.total)
                )

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
