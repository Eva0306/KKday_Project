//
//  HTTPRequestManager.swift
//  DiscountArea
//
//  Created by J oyce on 2024/8/23.
//

import Foundation

protocol HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet data: Any)
    func manager(_ manager: HTTPRequestManager, didGetProductList productList: [String])
    func didReceiveProductData(_ manager: HTTPRequestManager, products: [DiscountArea.ProductData])
    func manager(_ manager: HTTPRequestManager, didFailWith error: Error)
}

class HTTPRequestManager {

    var delegate: HTTPRequestManagerDelegate?
    var productList = [String]()

    // tag：國家（十三個之中的一個）；sort：類別
    func fetchPageData(tag: Int, sort: Int) {
        guard let url = URL(string: "https://aw-api.creziv.com/pages") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic Z3Vhbmh1YTp3YW5n", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.manager(self, didFailWith: error)
                    print(error)
                }
            }

            if let data {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {

                    
                    let pageData = try decoder.decode(ResponsePageData.self, from: data)

                    // 可以取到 blog 
                    let categories = pageData.data.data.categories[0].config[0].detail.guides
                    print("CCCC\(categories)")

                    // 取台灣資料，有 tab
                    if tag == 0 {
                        self.productList = pageData.data.data.categories[0].config[2].detail.tabs?[1].products.map{ $0.productUrlId } ?? []

                    } else if tag == 3 || tag == 8 || tag == 12 {
                        // 這三個地區的格式沒有 index 2 或是 index 2 格式對不起來
                        self.productList = pageData.data.data.categories[tag].config[1].detail.products?.map{ $0.productUrlId } ?? []
                    }
                    else {
                        // 取其他國家資料，沒有 tab
                        self.productList = pageData.data.data.categories[tag].config[sort].detail.products?.map{ $0.productUrlId } ?? []
                    }
//                    print(self.productList)

                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didGet: pageData)
                        print("========\n\(pageData)\n=======")
                        self.delegate?.manager(self, didGetProductList: self.productList)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didFailWith: error)
                        print("Decoding error: \(error)")
                    }
                }
            }
        }
        task.resume()
    }

    func fetchProductData(productList: [String]) {
        guard let url = URL(string: "https://aw-api.creziv.com/search") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic Z3Vhbmh1YTp3YW5n", forHTTPHeaderField: "Authorization")

        let json: [String: Any] = [
            "product_id": productList
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        } catch {
            print("Error: cannot create JSON from post data")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: server error")
                return
            }

            if let data = data {

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                do {

                    let productData = try decoder.decode(ResponseProductData.self, from: data)
                    DispatchQueue.main.async {
                        self.delegate?.didReceiveProductData(self, products: productData.data)
                        print("========\n\(productData)\n=======")
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didFailWith: error)
                        print("Decoding error: \(error)")
                    }
                }
            }
        }
        task.resume()
    }
}
