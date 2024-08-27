import Foundation

protocol HTTPRequestManagerDelegate {
    func manager(_ manager: HTTPRequestManager, didGet pageData: ResponsePageData)
    func manager(_ manager: HTTPRequestManager, didGet productData: ResponseProductData)
    func manager(_ manager: HTTPRequestManager, didFailWith error: Error)
}

class HTTPRequestManager {
    
    var delegate: HTTPRequestManagerDelegate?
    var productList = [String]()
    
    func fetchPageData() {
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
                    DispatchQueue.main.async {
                        self.delegate?.manager(self, didGet: pageData)
                        //print("========\n\(pageData)\n=======")
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
                        self.delegate?.manager(self, didGet: productData)
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

func decodeConfig(from jsonString: String, completion: @escaping ([Config]?) -> Void) {
    if let jsonData = jsonString.data(using: .utf8) {
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let config = try jsonDecoder.decode([String: [Config]].self, from: jsonData)
            completion(config["config"])
        } catch {
            print("Error decoding JSON: \(error)")
            completion(nil)
        }
    } else {
        completion(nil)
    }
}

let jsonString = """
{"config": [
                    {
                        "sort": 1,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "韓國限時買一送一🔥",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "",
                            "products": [
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "138205"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "2914"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "3416"
                                }
                            ],
                            "subtitle": "",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 2,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "韓國春天玩法推薦✨",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "2024-02-29 16:00:00",
                            "products": [
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "154294"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "18835"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "143877"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "22950"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "140484"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "23941"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "141062"
                                }
                            ],
                            "subtitle": "輸「KRTOUR95」享95折",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 3,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "優惠商品⚡",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "",
                            "products": [
                                {
                                    "name": "Wild Wild <AFTER PARTY> 猛男秀門票",
                                    "label": "",
                                    "product_url_id": "119270"
                                },
                                {
                                    "name": "韓國特色表演｜首爾/濟州 NANTA 亂打秀門票",
                                    "label": "",
                                    "product_url_id": "2358"
                                },
                                {
                                    "name": "韓國人氣表演｜首爾 塗鴉秀 Painters 門票",
                                    "label": "",
                                    "product_url_id": "11905"
                                },
                                {
                                    "name": "首爾景福宮韓服體驗｜韓服男 Hanboknam 韓服租借體驗",
                                    "label": "",
                                    "product_url_id": "12256"
                                },
                                {
                                    "name": "COEX 水族館門票",
                                    "label": "",
                                    "product_url_id": "14947"
                                },
                                {
                                    "name": "釜山 X the Sky 門票（海雲台 L 市天文台）",
                                    "label": "",
                                    "product_url_id": "105514"
                                },
                                {
                                    "name": "清潭洞 VOID by PARK CHUL 美容室 髮型+化妝體驗",
                                    "label": "",
                                    "product_url_id": "143376"
                                },
                                {
                                    "name": "首爾宜必思尚品首爾龍山大使酒店住宿",
                                    "label": "",
                                    "product_url_id": "142180"
                                }
                            ],
                            "subtitle": "",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 4,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "歡迎來到濟州島✨",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "",
                            "products": [
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "3592"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "13862"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "139862"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "103703"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "21597"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "39658"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "155716"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "21646"
                                }
                            ],
                            "subtitle": "輸入「GOTOJEJU」享93折⚡️",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 5,
                        "type": "PRODUCT",
                        "detail": {
                            "tabs": [
                                {
                                    "name": "🛎",
                                    "products": [
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "35936"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "11893"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "165385"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "165181"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "144143"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "100160"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "11186"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "6522"
                                        }
                                    ]
                                },
                                {
                                    "name": "🎫",
                                    "products": [
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "116704"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "20721"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "159278"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "31250"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "9367"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "2948"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "37561"
                                        }
                                    ]
                                },
                                {
                                    "name": "🌸⛰ JEJU/Gangwon",
                                    "products": [
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "164626"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "164404"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "164329"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "162004"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "162000"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "162008"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "132856"
                                        },
                                        {
                                            "name": "",
                                            "label": "",
                                            "product_url_id": "124299"
                                        }
                                    ]
                                }
                            ],
                            "title": "🛑 KKday Special Offer 🛑",
                            "cta_url": "",
                            "layout": "TAB_GRID",
                            "cta_text": "",
                            "end_time": "",
                            "subtitle": "",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 6,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "韓國包車優惠🚗",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "",
                            "products": [
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "139520"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "132560"
                                }
                            ],
                            "subtitle": "",
                            "start_time": ""
                        }
                    },
                    {
                        "sort": 7,
                        "type": "MERCHANT_COUPON",
                        "detail": {
                            "title": "立即領取購物折扣券！",
                            "subtitle": "購物狂歡不容錯過，馬上領取、立刻兌換優惠碼！",
                            "merchant_coupons": [
                                {
                                    "desc": "免費升級會員，滿額即贈現金折扣券",
                                    "title": "韓國樂天免稅店折扣券",
                                    "end_time": "2023-10-15 16:00:00",
                                    "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20230926021400_lhCdk/jpg",
                                    "start_time": "2023-09-26 00:00:00",
                                    "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20230926021255_BOoRj/png"
                                },
                                {
                                    "desc": "購物滿額最高可折扣120,000韓幣",
                                    "title": "韓國新羅免稅店",
                                    "end_time": "2024-07-31 16:00:00",
                                    "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012031507_3cWd2/png",
                                    "start_time": "2023-10-12 00:00:00",
                                    "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012031501_rSxIG/png"
                                }
                            ]
                        }
                    },
                    {
                        "sort": 8,
                        "type": "PRODUCT",
                        "detail": {
                            "title": "免費購物折扣券",
                            "cta_url": "",
                            "layout": "ROW",
                            "cta_text": "",
                            "end_time": "",
                            "products": [
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "145380"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "138057"
                                },
                                {
                                    "name": "",
                                    "label": "",
                                    "product_url_id": "135682"
                                }
                            ],
                            "subtitle": "",
                            "start_time": "2023-11-27 00:00:00"
                        }
                    }
                ]
            }
"""
