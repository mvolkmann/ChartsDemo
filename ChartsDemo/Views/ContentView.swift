import SwiftUI

struct ContentView: View {
    // TODO: Try getting data from the Census API at
    // TODO: https://www.census.gov/programs-surveys/sbo/technical-documentation/api.html
    var body: some View {
        TabView {
            BarChart().tabItem {
                Label("Bar Chart", systemImage: "chart.bar")
            }
            LineChart().tabItem {
                Label("Line Chart", systemImage: "chart.line.uptrend.xyaxis")
            }
            PieChart().tabItem {
                Label("Pie Chart", systemImage: "chart.pie")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
