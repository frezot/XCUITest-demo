import Foundation


protocol GiphyService {
    func getTrends(offset: Int, completion: @escaping (Result<[Gif], Error>) -> Void)
    func search(query: String, offset: Int, completion: @escaping (Result<[Gif], Error>) -> Void)
}


final class GiphyServiceImpl {
    enum QueryType {
        case trending
        case search(query: String)
    }
    
    private let api: ApiClient
    private let objectsLimit = Constants.queryDataLimit
    
    init(api: ApiClient) {
        self.api = api
    }
    
    private func getQuery(for type: QueryType) -> Query {
        switch type {
        case .trending:
            return Query(parameters: ["limit": objectsLimit], path: "/trending")
        case .search(let query):
            return Query(parameters: ["q": "\(query)", "limit": objectsLimit], path: "/search")
        }
    }
    
    private func getGifs(type: QueryType, offset: Int, completion: @escaping (Result<[Gif], Error>) -> Void) {
        let query = getQuery(for: type)
        var parameters = query.parameters
        parameters["offset"] = offset
        
        api.get(path: query.path, parameters: parameters) { result in
            completion(
                result.flatMap { data in
                    do {
                        let dataResponse = try JSONDecoder().decode(Response<Gif>.self, from: data)
                        
                        guard dataResponse.meta?.status == 200 else {
                            print("ERROR",
                                  "status:",
                                  dataResponse.meta?.status ?? "unknown",
                                  "message:",
                                  dataResponse.meta?.msg ?? "unknown")
                            return .failure(NetworkingError.default)
                        }
                        
                        return .success(dataResponse.data)
                    } catch {
                        print(error.localizedDescription)
                        return .failure(error)
                    }
                }.mapError { _ in return CommonError.default }
            )
        }
    }
}


extension GiphyServiceImpl: GiphyService {
    func getTrends(offset: Int, completion: @escaping (Result<[Gif], Error>) -> Void) {
        getGifs(type: .trending, offset: offset, completion: completion)
    }
    
    func search(query: String, offset: Int, completion: @escaping (Result<[Gif], Error>) -> Void) {
        getGifs(type: .search(query: query), offset: offset, completion: completion)
    }
}
