

import Foundation

//MARK: - Page Data
struct ResponsePageData: Codable {
    let code: String
    let errmsg: String?
    let data: ResponsePageData2
}

struct ResponsePageData2: Codable {
    let code: String
    let errmsg: String?
    let data: PageData
}

struct PageData: Codable {
    let dealPageOid: Int
    let name: String
    let market: String
    let platform: String
    let startTime: String
    let endTime: String
    let categories: [Category]
    let title: String?
    let ctaUrl: String?
    let layout: String?
    let ctaText: String?
    let subtitle: String?
}

struct Category: Codable {
    let dealPageCategoryOid: Int
    let name: String
    let sort: Int
    let config: [Config]
}

struct Config: Codable {
    let sort: Int
    let type: String
    let detail: Detail
}

struct Detail: Codable {
    let tabs: [Tab]?
    let title: String?
    let ctaUrl: String?
    let layout: String?
    let ctaText: String?
    let endTime: String?
    let subtitle: String?
    let startTime: String?
    let products: [Product]?
    let merchantCoupons: [MerchantCoupon]?
    let guides: [Guide]?
}

struct Tab: Codable {
    let name: String
    let products: [Product]
}

struct Product: Codable {
    let name: String?
    let label: String?
    let productUrlId: String
}

struct Guide: Codable {
    let title: String
    let imageUrl: String
    let link: String
    let isShowVideoPlayIcon: Bool
}


struct MerchantCoupon: Codable {
    let desc: String
    let title: String
    let endTime: String
    let imageUrl: String
    let startTime: String
    let logoImageUrl: String
}

//MARK: - Product Data
struct ResponseProductData: Codable {
    let code: String
    let data: [ProductData]
    let errmsg: String?
}

struct ProductData: Codable {
    let currency: String
    let discount: Float
    let id: String
    let imgUrl: String
    let name: String
    let originPrice: String
    let price: String
    let ratingCount: Int
    let ratingStar: Double
}


// -----------------------------
let jsonString = """
{
"merchant_coupons": [
                                    {
                                        "desc": "免稅 10% (8%) + 店內商品 5% off（部分商品除外）",
                                        "title": "SPORTS DEPO",
                                        "end_time": "2024-06-30 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012014538_Ay8p8/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012014231_RvgqO/png"
                                    },
                                    {
                                        "desc": "免稅 10% (8%) + 店內商品 5% off（部分商品除外）",
                                        "title": "GOLF5",
                                        "end_time": "2024-06-30 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012021914_GxRce/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012020748_bXREI/png"
                                    },
                                    {
                                        "desc": "免稅 10% (8%) + 店內商品 5% off（部分商品除外）",
                                        "title": "Alpen Outdoors",
                                        "end_time": "2024-06-30 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012023200_N2iBZ/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012023044_8SMII/png"
                                    },
                                    {
                                        "desc": "免稅 10% (8%) + 店內商品 5% off（部分商品除外）",
                                        "title": "Alpen TOKYO",
                                        "end_time": "2024-06-30 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012023200_N2iBZ/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012023723_Tc6np/png"
                                    },
                                    {
                                        "desc": "10% 免稅 + 折扣 7%、5%、3% OFF",
                                        "title": "Bic Camera",
                                        "end_time": "2023-12-31 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025119_tadiI/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025641_jjPXP/jpg"
                                    },
                                    {
                                        "desc": "10% 免稅 + 7% 折扣",
                                        "title": "EDION",
                                        "end_time": "2023-12-31 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025413_omNay/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025322_YS2lg/jpg"
                                    },
                                    {
                                        "desc": "10% 免稅 + 8% 折扣",
                                        "title": "LAOX",
                                        "end_time": "2024-05-31 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025850_pN9Dg/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012025842_LkEku/png"
                                    },
                                    {
                                        "desc": "10% 免稅 + 7%、5%、3% 折扣",
                                        "title": "松本清",
                                        "end_time": "2024-03-21 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012030217_uIEIJ/jpg",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231012030208_TiGJ4/jpg"
                                    },
                                    {
                                        "desc": "免稅 10% + 最高折扣 7% OFF",
                                        "title": "COSMOS",
                                        "end_time": "2023-12-31 00:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231024053646_Bq9o0/png",
                                        "start_time": "2023-10-12 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20231024053430_Rt7c2/jpg"
                                    },
                                    {
                                        "desc": "免稅10% + 折扣 7%、5%、3%",
                                        "title": "Tsuruha Drugstore",
                                        "end_time": "2024-12-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402025700_dKOeS/jpg",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402025613_26MPP/png"
                                    },
                                    {
                                        "desc": "免稅10% + 折扣 5%",
                                        "title": "東京生活館",
                                        "end_time": "2024-12-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402031849_C2Flw/jpg",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402031723_F0kLh/jpg"
                                    },
                                    {
                                        "desc": "折扣 10%",
                                        "title": "ZERO HALLIBURTON",
                                        "end_time": "2024-12-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402032900_GLG5r/png",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402032820_AysvY/png"
                                    },
                                    {
                                        "desc": "折扣 10%",
                                        "title": "ace.",
                                        "end_time": "2024-12-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402032933_BgOs4/png",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402032905_11ASr/png"
                                    },
                                    {
                                        "desc": "折扣 10%",
                                        "title": "PROTECA",
                                        "end_time": "2024-12-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402033003_5TiYI/png",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402032939_aWYen/png"
                                    },
                                    {
                                        "desc": "折扣 5%",
                                        "title": "新宿小田急百貨店",
                                        "end_time": "2025-03-31 16:00:00",
                                        "image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402033024_7otPB/png",
                                        "start_time": "2024-04-02 00:00:00",
                                        "logo_image_url": "https://image.kkday.com/v2/image/get/s1.kkday.com/campaign_3058/20240402033008_jaZVw/jpg"
                                    }
                                ]
}
"""

func decodeMerchantCoupons(from jsonString: String) -> [MerchantCoupon]? {
    if let jsonData = jsonString.data(using: .utf8) {
        do {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            let merchantCoupons = try jsonDecoder.decode([String: [MerchantCoupon]].self, from: jsonData)
            return merchantCoupons["merchant_coupons"]
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    return nil
}
