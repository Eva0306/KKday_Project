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

//MARK: - Product Data
struct ResponseProductData: Codable {
    let code: String
    let data: [ProductData]
    let errmsg: String?
}

struct ProductData: Codable {
    let currency: String
    let discount: Double
    let id: String
    let imgUrl: String
    let name: String
    let originPrice: String
    let price: String
    let ratingCount: Int
    let ratingStar: Double
}
