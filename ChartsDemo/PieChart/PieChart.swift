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

        sliceColors = []
        for _ in 0 ..< data.count {
            sliceColors.append(randomColor())
        }
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
        data.enumerated().forEach { index, _ in
            let value = normalizedValue(index: index, data: self.data)
            if slices.isEmpty {
                slices.append((.init(startDegree: 0, endDegree: value * 360)))
            } else {
                slices.append(.init(
                    startDegree: slices.last!.endDegree,
                    endDegree: value * 360 + slices.last!.endDegree
                ))
            }
        }
        return slices
    }

    private var touchOverlay: some View {
        VStack {
            if !touchLabel.isEmpty {
                Text(touchLabel)
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white).shadow(radius: 3)
                    )
            }

            if !touchValue.isEmpty {
                Text("\(touchValue)")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.black)
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .foregroundColor(.white).shadow(radius: 3)
                    )
            }
        }
        .padding()
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

                touchOverlay
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
            where: { $0.startDegree < angle && $0.endDegree > angle }
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

    private func normalizedValue(index: Int, data: [ChartData]) -> Double {
        var total = 0.0
        data.forEach { data in
            total += data.value
        }
        return data[index].value / total
    }

    private func pieSliceViews(geometry: GeometryProxy) -> some View {
        ForEach(0 ..< data.count, id: \.self) { i in
            PieSliceView(
                center: CGPoint(
                    x: geometry.frame(in: .local).midX,
                    y: geometry.frame(in: .local).midY
                ),
                radius: geometry.frame(in: .local).width / 2,
                startDegree: pieSlices[i].startDegree,
                endDegree: pieSlices[i].endDegree,
                isTouched: isSliceTouched(
                    index: i,
                    inPie: geometry.frame(in: .local)
                ),
                backgroundColor: sliceColors[i],
                separatorColor: separatorColor
            )
        }
    }

    private func randomColor() -> Color {
        Color(
            red: randomNumber(),
            green: randomNumber(),
            blue: randomNumber()
        )
    }

    private func randomNumber() -> Double {
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

        guard let index = pieSlices.firstIndex(
            where: { $0.startDegree <= angle && angle <= $0.endDegree
            }
        ) else { return }

        let item = data[index]
        touchLabel = item.label

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let number = NSNumber(value: item.value)
        touchValue = formatter.string(from: number) ?? ""
    }
}
