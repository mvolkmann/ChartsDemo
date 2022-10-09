import SwiftCSV
import SwiftUI

private enum Error: Swift.Error {
    case fileNotFound(name: String)
}

class ViewModel: ObservableObject {
    @Published var statistics: [AgeStatistics] = []

    // This is a singleton class.
    static let shared = ViewModel()

    private init() {
        do {
            // This data is from
            // https://data.census.gov/cedsci/table?tid=ACSST1Y2021.S0101.
            try loadCSV(fileName: "/us-census-age-sex-2021")
        } catch {
            print("error parsing CSV file:", error)
        }
    }

    private func loadCSV(fileName: String) throws {
        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: "csv"
        ) else {
            throw Error.fileNotFound(name: fileName)
        }

        let csv = try CSV<Named>(url: url)

        for row in csv.rows {
            // row is a Dictionary where keys and values are Strings.
            if let category = row["Age"],
               let total = row["Total"],
               let male = row["Male"],
               let female = row["Female"] {
                statistics.append(AgeStatistics(
                    category: category,
                    total: Int(total)!,
                    male: Int(male)!,
                    female: Int(female)!
                ))
            }
        }
    }
}
