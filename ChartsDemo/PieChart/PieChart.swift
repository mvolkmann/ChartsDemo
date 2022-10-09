import SwiftUI

// This is based on the implementation by Ahmed Mgua described at
// https://blckbirds.com/post/charts-in-swiftui-part-2-pie-chart/.
struct PieChart: View {
    // MARK: - State

    @State private var touchLabel = ""
    @State private var touchLocation: CGPoint = .init(x: -1, y: -1)
    @State private var touchValue = ""

    // MARK: - Initializer

    init(
        title: String,
        data: [ChartData],
        separatorColor: Color = Color(UIColor.systemBackground),
        customSliceColors: [Color] = [],
        keyColumns: Int = 3
    ) {
        self.title = title
        self.data = data
        self.separatorColor = separatorColor
        self.keyColumns = keyColumns

        guard customSliceColors.isEmpty else {
            sliceColors = customSliceColors
            return
        }

        sliceColors = Self.randomColors(count: data.count)
    }

    // MARK: - Properties

    var title: String
    var data: [ChartData]
    var separatorColor: Color
    var sliceColors: [Color] // assigned dynamically if empty
    var keyColumns: Int

    private var key: some View {
        let rowCount = Int(ceil(Double(data.count) / Double(keyColumns)))
        return Grid(alignment: .leading) {
            ForEach(0 ..< rowCount, id: \.self) { rowIndex in
                GridRow {
                    ForEach(0 ..< keyColumns, id: \.self) { columnIndex in
                        keyItem(index: rowIndex + columnIndex * rowCount)
                    }
                }
            }
        }
        .padding(10)
        .border(.gray)
    }

    private var pieSlices: [PieSlice] {
        var slices = [PieSlice]()
        let total = data.reduce(0.0) { $0 + $1.value }
        var startDegrees = 0.0

        for index in 0 ..< data.count {
            let percent = data[index].value / total
            let endDegrees = startDegrees + 360 * percent
            slices.append(PieSlice(
                startDegrees: startDegrees,
                endDegrees: endDegrees
            ))
            startDegrees = endDegrees
        }

        return slices
    }

    private var touchOverlay: some View {
        VStack {
            Text(touchLabel).bold()
            Text("\(touchValue)")
        }
        .font(.callout)
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
                .shadow(radius: 5)
        )
    }

    var body: some View {
        VStack {
            Text(title).bold().font(.largeTitle)
            ZStack {
                GeometryReader { geometry in
                    pieSliceViews(geometry: geometry)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { position in
                                    let pieSize = geometry.frame(in: .local)
                                    touchLocation = position.location
                                    updateTouch(inPie: pieSize)
                                }
                                .onEnded { _ in
                                    DispatchQueue.main
                                        .asyncAfter(deadline: .now() + 1) {
                                            withAnimation(Animation.easeOut) {
                                                resetTouch()
                                            }
                                        }
                                }
                        )
                }
                .aspectRatio(contentMode: .fit)

                if !touchLabel.isEmpty, !touchValue.isEmpty {
                    touchOverlay
                }
            }

            key
        }
        .padding()
    }

    // MARK: - Methods

    private func angleAtTouch(
        inPie pieSize: CGRect,
        touch: CGPoint
    ) -> Double? {
        let dx = touch.x - pieSize.midX
        let dy = touch.y - pieSize.midY

        let distanceToCenter = (dx * dx + dy * dy).squareRoot()
        let radius = pieSize.width / 2
        guard distanceToCenter <= radius else { return nil }

        let angle = Double(atan2(dy, dx) * (180 / .pi))
        return angle >= 0 ? angle : angle + 360
    }

    private func isSliceTouched(index: Int, inPie pieSize: CGRect) -> Bool {
        guard let angle = angleAtTouch(
            inPie: pieSize,
            touch: touchLocation
        ) else { return false }

        return pieSlices.firstIndex(
            where: { $0.startDegrees < angle && $0.endDegrees > angle }
        ) == index
    }

    private func keyItem(index: Int) -> some View {
        HStack {
            if index < sliceColors.count, index < data.count {
                sliceColors[index]
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 20)
                Text(data[index].label)
                    .font(.caption)
                    .bold()
            }
        }
    }

    private func pieSliceViews(geometry: GeometryProxy) -> some View {
        ForEach(0 ..< data.count, id: \.self) { index in
            let pieSlice = pieSlices[index]
            PieSliceView(
                center: CGPoint(
                    x: geometry.frame(in: .local).midX,
                    y: geometry.frame(in: .local).midY
                ),
                radius: geometry.frame(in: .local).width / 2,
                startDegree: pieSlice.startDegrees,
                endDegree: pieSlice.endDegrees,
                isTouched: isSliceTouched(
                    index: index,
                    inPie: geometry.frame(in: .local)
                ),
                backgroundColor: sliceColors[index],
                separatorColor: separatorColor
            )
        }
    }

    private static func randomColor() -> Color {
        Color(
            red: Self.randomNumber(),
            green: Self.randomNumber(),
            blue: Self.randomNumber()
        )
    }

    private static func randomColors(count: Int) -> [Color] {
        (0 ..< count).map { _ in Self.randomColor() }
    }

    private static func randomNumber() -> Double {
        Double.random(in: 0.2 ... 0.9)
    }

    private func resetTouch() {
        touchValue = ""
        touchLabel = ""
        touchLocation = .init(x: -1, y: -1)
    }

    private func updateTouch(inPie pieSize: CGRect) {
        guard let angle = angleAtTouch(
            inPie: pieSize,
            touch: touchLocation
        ) else { return }

        guard let index = pieSlices.firstIndex(where: {
            $0.startDegrees <= angle && angle <= $0.endDegrees
        }) else { return }

        let item = data[index]
        touchLabel = item.label

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(value: item.value)
        touchValue = formatter.string(from: number) ?? ""
    }
}
