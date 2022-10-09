import Foundation

struct AgeStatistics: Identifiable {
    let category: String
    let total: Int
    let male: Int
    let female: Int
    var id: String { category }
}
