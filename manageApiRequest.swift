import Alamofire
import Combine
import Foundation

//creating the json struct, and having the same names as in the json cause its mandatory, because then it wouldnt have the correct formats

//creating productlist struct for json
struct ProductList: Codable {
    let products: [Product]
}

//product struct which uses more struct because the way the json is
struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let unit: String
    let imageUrl: String
    let pricesOfChainStores: [Stores]
}

//store struct if a product is in more than one store
struct Stores: Identifiable, Codable {
    let id: String
    let name: String
    let prices: [Price]
}

//price struct because the json has an array for the prices
struct Price: Codable {
    //unit price
    let unitAmount: Double
    //actual price
    let amount: Int
}

class APIService: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var queryString: String = ""
    
    func fetchProducts() {
        
        //url and query param for sending api request
        let url = "https://arfigyelo.gvh.hu/api/search?q=" + queryString + "&limit=24&offset=0&order=relevance"
        
        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    
                    let decoder = JSONDecoder()
                    let productList = try decoder.decode(ProductList.self, from: data)
                                        
                    DispatchQueue.main.async {
                        self.products = productList.products
                    }
                    
                } catch {
                    print("JSON dekódolási hiba: \(error)")
                }
            case .failure(let error):
                print("Hálózati hiba: \(error)")
            }
        }
    }
    
}
