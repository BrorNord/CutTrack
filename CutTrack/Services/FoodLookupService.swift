import Foundation

struct ScannedFood {
    let name: String
    let caloriesPer100g: Double
    let proteinPer100g: Double
    let carbsPer100g: Double
    let fatPer100g: Double
    let barcode: String
}

final class FoodLookupService {
    struct Response: Decodable {
        let status: Int
        let product: Product?
    }

    struct Product: Decodable {
        let product_name: String?
        let nutriments: Nutriments?
    }

    struct Nutriments: Decodable {
        let energy_kcal_100g: Double?
        let proteins_100g: Double?
        let carbohydrates_100g: Double?
        let fat_100g: Double?
    }

    func lookup(barcode: String) async throws -> ScannedFood? {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("CutTrack/1.0 (iOS)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        guard decoded.status == 1, let product = decoded.product else { return nil }

        return ScannedFood(
            name: product.product_name ?? "Scanned food",
            caloriesPer100g: product.nutriments?.energy_kcal_100g ?? 0,
            proteinPer100g: product.nutriments?.proteins_100g ?? 0,
            carbsPer100g: product.nutriments?.carbohydrates_100g ?? 0,
            fatPer100g: product.nutriments?.fat_100g ?? 0,
            barcode: barcode
        )
    }
}
