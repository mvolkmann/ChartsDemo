import Charts
import SwiftUI

struct BarChart: View {
    private let vm = ViewModel.shared

    var body: some View {
        /*
        Chart {
            BarMark(x: .value("Name", "Mark"), y: .value("Score", 19))
            BarMark(x: .value("Name", "Tami"), y: .value("Score", 21))
        }
        */
        Chart {
            ForEach(vm.statistics) { row in
                if row.category != "All" {
                    BarMark(
                        x: .value("Age", row.category),
                        y: .value("Total", row.total)
                    )
                }
            }
        }
    }
}

struct BarChart_Previews: PreviewProvider {
    static var previews: some View {
        BarChart()
    }
}
