import Alamofire
import Combine
import Foundation

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
