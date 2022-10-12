import SwiftCSV
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = "scatter"

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

            ScatterPlotDemo().tabItem {
                Label("Scatter Plot", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag("scatter")

            HeatMapDemo().tabItem {
                Label("Heat Map", systemImage: "chart.line.uptrend.xyaxis")
            }
            .tag("heat")

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
