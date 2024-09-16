//
//  BrandModel.swift
//  Observation Framework
//
//  Created by differenz53 on 08/07/24.
//

import Foundation

//MARK: - BrandModel
struct brandModel: Codable {
    var id: Int?
    var uid, brand, equipment: String?
}

extension brandModel {
    
  
    static func getBrandData(completion: @escaping (_ arrData:[brandModel],_ error: NetworkError?,_ isAuthError:Bool) -> Void) {
        let url = "https://random-data-api.com/api/v2/appliances?size=10#"
        Task {
            let data = await APIManager.makeAsyncRequest(url: url, method: .get, parameter: nil, type: [brandModel].self)
            var arrData:[brandModel] = []
            var networkErrorType:NetworkError? = nil
            var isAuthError:Bool = false
            switch data {
            case .success(let responseData):
                arrData = responseData
            case .failure(let error):
                if let networkError = error as? NetworkError {
                    networkErrorType = networkError
                    switch networkError {
                    case .invalidURL:
                        print(error.localizedDescription)
                    case .responseError:
                        print(error.localizedDescription)
                    case .unknown:
                        print(error.localizedDescription)
                    case .authentication:
                        print(error.localizedDescription)
                        isAuthError = true
                    }
                }
            }
            completion(arrData, networkErrorType, isAuthError)
        }
    }
    
}
