//
//  NetworkManager.swift
//  NetworkManager
//
//  Created by Alexander Sobolev on 18.8.23..
//

import Foundation
import Alamofire
import MobileCoreServices

class NetworkManager {
    static let baseUrl = "http://date.jsontest.com"
    
    

    static func makeRequest<CodableEntity: Codable>(url: String,
                                                 method: HTTPMethod,
                                                 model: CodableEntity.Type,
                                                 useInterseptor: Bool = true,
                                                 queryParams: Parameters? = nil) async throws -> CodableEntity? {
        
        
        let result: Data? = try await withCheckedThrowingContinuation { continuation in
            AF.request(
                NetworkManager.baseUrl + url,
                method: method,
                parameters: queryParams,
                encoding: URLEncoding.queryString,
                headers: .init(arrayLiteral: .accept("application/json")),
                interceptor: useInterseptor ? BaseTokenInterceptor() : nil
            )
            .validate(statusCode: Array(100...400) + Array(402...599))
            .responseData { response in
                guard let statusCode = response.response?.statusCode else {
                    return continuation.resume(throwing: AFError.responseValidationFailed(reason: .dataFileNil))
                }
                switch statusCode {
                case 200:
                    continuation.resume(returning: response.data)
                case 204:
                    continuation.resume(returning: nil)
                    //                case 401:
                    //                    continuation.resume(throwing: ResponseError.unauthenticated) 401 error pass to TokenInterceptor
                case 409:
                    break
                    //continuation.resume(throwing: QugoError.conflict)
                case 422:
                    do {
                        if let responseData = response.data {
                            let errorData = try JSONDecoder().decode(ValidationError.self, from: responseData)
                            continuation.resume(throwing: ResponseError.validationException(errorData))
                        } else {
                            continuation.resume(throwing: AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
                        }
                    } catch {
                        continuation.resume(throwing: AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
                    }
                default:
                    continuation.resume(throwing: AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: statusCode)))
                }
            }
        }
        
        if let result {
            return try JSONDecoder().decode(CodableEntity.self, from: result)
        } else {
            print("Cannot parse recieved object: \(model.self)")
            return nil
        }
    }
}



enum ResponseError: LocalizedError {
    case unauthenticated
    case conflict
    case validationException(ValidationError)

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "You are not logged in."
        case .conflict:
            return "There is a conflict with the server."
        case .validationException(let errorData):
            return "There are some validation errors: \(errorData.message) \(errorData.errors)"
        }
    }
}


enum CommonError: LocalizedError {
    case unauthenticated
    case conflict
    case validationException(ValidationError)

    var errorDescription: String? {
        switch self {
        case .unauthenticated:
            return "You are not logged in."
        case .conflict:
            return "There is a conflict with the server."
        case .validationException(let errorData):
            return "There are some validation errors: \(errorData.message) \(errorData.errors)"
        }
    }
}

extension Error {
    var asCommonError: CommonError? {
        if let commonError = self as? CommonError {
            return commonError
        } else {
            print(self.localizedDescription)
            return nil
        }
        
    }
}

