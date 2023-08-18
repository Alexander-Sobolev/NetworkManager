//
//  BaseTokenInterceptor.swift
//  NetworkManager
//
//  Created by Alexander Sobolev on 18.8.23..
//

import Foundation
import Alamofire
 

class BaseTokenInterceptor: RequestInterceptor {
    
    let contentType: ContentType
    
    enum ContentType: String {
        case wwwFormUrlencoded = "application/x-www-form-urlencoded"
        case multipartFormData = "multipart/form-data"
    }
    
    init (contentType: ContentType = .wwwFormUrlencoded) {
        self.contentType = contentType
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        urlRequest.timeoutInterval = 200
        urlRequest.headers.add(.accept("application/json"))
        if contentType == .wwwFormUrlencoded {
            urlRequest.headers.add(.contentType(contentType.rawValue))
        }
        
//
//        if let accessToken = AppData.shared.auth.value?.accessToken {
//            urlRequest.headers.add(.authorization(bearerToken: accessToken))
//        } else {
//            Logger.log(type: .INFO, "TokenInterceptor.swift. There's no available access token")
//        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            // Обновить токен и повторить запрос
//            refreshToken { success in
//                completion(success ? .retry : .doNotRetry)
//            }
        } else {
            // не повторять попытку
            completion(.doNotRetryWithError(error))
        }
    }
    
//    private func refreshToken(completion: @escaping (Bool) -> Void) {
//        let url = NetworkManager.baseUrl + "v1/auth/refresh-jwt"
//        let parameters = ["refreshToken": AppData.shared.auth.value?.refreshToken]
//        AF.request(url, method: .post,
//                   parameters: parameters,
//                   headers: .init(arrayLiteral: .accept("application/json")))
//        .responseDecodable(of: RAuthJwt.self) { response in
//            switch response.result {
//            case .success(let authData):
//                AppData.shared.auth.value?.accessToken = authData.accessToken
//                AppData.shared.auth.value?.refreshToken = authData.refreshToken
//                completion(true)
//            case .failure(let error):
//                print(error)
//                completion(false)
//                self.resetDefaults()
//                AppData.shared.appRootScreenState.value = .WELCOME
//                Navigator.shared.path.popToRoot()
//
//            }
//        }
//    }
}

