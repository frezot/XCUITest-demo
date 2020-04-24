import Foundation


struct Response<T> where T: Codable {
    let data: [T]
    let meta: Meta?
}


extension Response: Codable {
    struct Meta: Codable {
        let status: Int?
        let msg: String?
    }
}
