import SwiftCSV
import SwiftUI

enum Error: Swift.Error {
    case fileNotFound(name: String)
}

struct ContentView: View {
    // TODO: Try getting data from the Census API at
    // TODO: https://www.census.gov/data/developers/data-sets/census-microdata-api.html
    // TODO: Also test use of the Instruments tool to example HTTP traffic.
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
        .task {
            do {
                let name = "/us-census-age-sex-2021"
                guard let url = Bundle.main.url(
                    forResource: name,
                    withExtension: "csv"
                ) else {
                    throw Error.fileNotFound(name: name)
                }
                let csv: CSV = try CSV<Named>(url: url)
                print("csv =", csv)
            } catch {
                print("error parsing CSV file:", error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
