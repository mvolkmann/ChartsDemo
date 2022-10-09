import SwiftCSV
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "pie"

    var body: some View {
        TabView(selection: $selectedTab) {
            BarChartDemo().tabItem {
                Label("Bar Chart", systemImage: "chart.bar")
            }
            .tag("bar")

            LineChartDemo().tabItem {
                Label("Line Chart", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag("line")

            PieChartDemo().tabItem {
                Label("Pie Chart", systemImage: "chart.pie")
            }
            .tag("pie")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
