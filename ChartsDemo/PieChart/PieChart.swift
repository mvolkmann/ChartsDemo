import SwiftUI

// This is based on the implementation by Ahmed Mgua described at
// https://blckbirds.com/post/charts-in-swiftui-part-2-pie-chart/.
struct PieChart: View {
    @State private var currentValue = ""
    @State private var currentLabel = ""
    @State private var touchLocation: CGPoint = .init(x: -1, y: -1)

    var title: String
    var data: [ChartData]
    var separatorColor: Color
    var sliceColors: [Color] // assigned dynamically if empty
    var keyColumns: Int

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
            sliceColors.append(Color(
                red: Double.random(in: 0.2 ... 0.9),
                green: Double.random(in: 0.2 ... 0.9),
                blue: Double.random(in: 0.2 ... 0.9)
            ))
        }
    }

    private var key: some View {
        let rows = Int(ceil(Double(data.count) / Double(keyColumns)))
        return Grid(alignment: .leading) {
            ForEach(0 ..< rows, id: \.self) { rowIndex in
                GridRow {
                    ForEach(0 ..< keyColumns, id: \.self) { columnIndex in
                        HStack {
                            let index = rowIndex * keyColumns + columnIndex
                            sliceColors[index]
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 20)
                            Text(data[index].label)
                                .font(.caption)
                                .bold()
                        }
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

    var body: some View {
        VStack {
            Text(title)
                .bold()
                .font(.largeTitle)
            ZStack {
                GeometryReader { geometry in
                    ZStack {
                        ForEach(0 ..< self.data.count, id: \.self) { i in
                            PieSliceView(
                                center: CGPoint(
                                    x: geometry.frame(in: .local).midX,
                                    y: geometry.frame(in: .local).midY
                                ),
                                radius: geometry.frame(in: .local).width / 2,
                                startDegree: pieSlices[i].startDegree,
                                endDegree: pieSlices[i].endDegree,
                                isTouched: sliceIsTouched(
                                    index: i,
                                    inPie: geometry.frame(in: .local)
                                ),
                                backgroundColor: sliceColors[i],
                                separatorColor: separatorColor
                            )
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { position in
                                let pieSize = geometry.frame(in: .local)
                                touchLocation = position.location
                                updateCurrentValue(inPie: pieSize)
                            }
                            .onEnded { _ in
                                DispatchQueue.main
                                    .asyncAfter(deadline: .now() + 1) {
                                        withAnimation(Animation.easeOut) {
                                            resetValues()
                                        }
                                    }
                            }
                    )
                }
                .aspectRatio(contentMode: .fit)

                VStack {
                    if !currentLabel.isEmpty {
                        Text(currentLabel)
                            .font(.caption)
                            .bold()
                            .foregroundColor(.black)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(.white).shadow(radius: 3)
                            )
                    }

                    if !currentValue.isEmpty {
                        Text("\(currentValue)")
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

            key
        }
        .padding()
    }

    func angleAtTouchLocation(
        inPie pieSize: CGRect,
        touchLocation: CGPoint
    ) -> Double? {
        let dx = touchLocation.x - pieSize.midX
        let dy = touchLocation.y - pieSize.midY

        let distanceToCenter = (dx * dx + dy * dy).squareRoot()
        let radius = pieSize.width / 2
        guard distanceToCenter <= radius else { return nil }

        let angleAtTouchLocation = Double(atan2(dy, dx) * (180 / .pi))
        return angleAtTouchLocation >= 0 ? angleAtTouchLocation :
            angleAtTouchLocation + 360
    }

    func normalizedValue(index: Int, data: [ChartData]) -> Double {
        var total = 0.0
        data.forEach { data in
            total += data.value
        }
        return data[index].value / total
    }

    func updateCurrentValue(inPie pieSize: CGRect) {
        guard let angle = angleAtTouchLocation(
            inPie: pieSize,
            touchLocation: touchLocation
        ) else { return }
        let currentIndex = pieSlices
            .firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle
            }) ?? -1

        currentLabel = data[currentIndex].label
        currentValue = "\(data[currentIndex].value)"
    }

    func resetValues() {
        currentValue = ""
        currentLabel = ""
        touchLocation = .init(x: -1, y: -1)
    }

    func sliceIsTouched(index: Int, inPie pieSize: CGRect) -> Bool {
        guard let angle = angleAtTouchLocation(
            inPie: pieSize,
            touchLocation: touchLocation
        ) else { return false }
        return pieSlices
            .firstIndex(where: { $0.startDegree < angle && $0.endDegree > angle
            }) == index
    }
}
