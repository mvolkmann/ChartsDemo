import SwiftUI

struct PieSliceView: View {
    var center: CGPoint
    var radius: CGFloat
    var startDegree: Double
    var endDegree: Double
    var isTouched: Bool
    var backgroundColor: Color
    var separatorColor: Color

    var path: Path {
        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: Angle(degrees: startDegree),
            endAngle: Angle(degrees: endDegree),
            clockwise: false
        )
        path.addLine(to: center)
        path.closeSubpath()
        return path
    }

    var body: some View {
        let scale = isTouched ? 1.05 : 1
        path
            .fill(backgroundColor)
            .overlay(path.stroke(separatorColor, lineWidth: 2))
            .scaleEffect(scale)
            .animation(.spring(), value: scale)
    }
}
