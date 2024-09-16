//
//  APIManager.swift
//  Observation Framework
//
//  Created by differenz53 on 04/07/24.
//

import Foundation
import Alamofire
import Combine

enum NetworkError: Error {
    case invalidURL
    case responseError
    case unknown
    case authentication
}

enum apiUrl: String {
    case brand
    case user
    case todos
    
    var route: String {
        get {
            switch self {
                
            case .brand:
                "https://random-data-api.com/api/v2/appliances?size=10#"
            case .user:
                "https://jsonplaceholder.typicode.com/users"
            case .todos:
                "https://jsonplaceholder.typicode.com/todos"
            }
        }
    }
    
}


extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "Invalid URL")
        case .responseError:
            return NSLocalizedString("Unexpected status code", comment: "Invalid response")
        case .unknown:
            return NSLocalizedString("Unknown error", comment: "Unknown error")
        case .authentication:
            return NSLocalizedString("Authentication is expired", comment: "Authentication error")
        }
    }
}
 
class APIManager {
    
    class func makeRequest<T: Codable>(url: String, method: HTTPMethod,parameter:[String:Any]?,type: T.Type) -> Future<T,Error> {
        
        let headers:[String:String] = [:]
        let httpHeader = HTTPHeaders.init(headers)
        
        return Future { promise in
            guard let url = URL(string: url) else {
                return promise(.failure(NetworkError.invalidURL))
            }
            
            AF.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: httpHeader)
                .responseData(queue: .global(qos: .background)) { response in
                    switch response.result {
                        
                    case .success(let responseData):
                        
                        do {
                            guard let httpResponse = response.response else {
                                promise(.failure(NetworkError.unknown))
                                return
                            }
                            
                            if httpResponse.statusCode == 200 {
                                let data = try JSONDecoder().decode(T.self, from: responseData)
                                promise(.success(data))
                            } else if httpResponse.statusCode == 401 {
                                promise(.failure(NetworkError.authentication))
                            } else {
                                promise(.failure(NetworkError.authentication))
                            }
                        } catch {
                            print(error.localizedDescription)
                            promise(.failure(NetworkError.unknown))
                        }
                        
                    case .failure(_):
                        promise(.failure(NetworkError.responseError))
                    }
                }
                
        }
        
    }
    
    class func makeAsyncRequest<T:Codable>(url: String, method: HTTPMethod, parameter: [String:Any]?, type: T.Type) async -> Result<T,Error> {
        
        let headers:[String:String] = [:]
        let httpHeader = HTTPHeaders(headers)
       
        do {
            return try await withCheckedThrowingContinuation { continuation in
                AF.request(url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: httpHeader)
                    .responseData(queue: .global(qos: .background)) { response in
                        
                        switch response.result {
                            
                        case .success(let responseData):
                            do {
                                
                                guard let httpResponse = response.response else {
                                    continuation.resume(returning: .failure(NetworkError.unknown))
                                    return
                                }
                                if httpResponse.statusCode == 200 {
                                    let data = try JSONDecoder().decode(T.self, from: responseData)
                                    continuation.resume(returning: .success(data))
                                } else if httpResponse.statusCode == 401 {
                                    continuation.resume(returning: .failure(NetworkError.authentication))
                                } else {
                                    continuation.resume(returning: .failure(NetworkError.responseError))
                                }
                                
                                
                            } catch {
                                print(error.localizedDescription)
                                continuation.resume(returning: .failure(NetworkError.unknown))
                            }
                            
                        case .failure(let error):
                            print(error.localizedDescription)
                            continuation.resume(returning: .failure(NetworkError.invalidURL))
                        }
                        
                    }
            }
        } catch {
            print(error.localizedDescription)
            return .failure(NetworkError.invalidURL)
            
        }
    }
    
}

