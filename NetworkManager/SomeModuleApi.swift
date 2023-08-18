//
//  SomeModuleApi.swift
//  NetworkManager
//
//  Created by Alexander Sobolev on 18.8.23..
//

import Foundation



// Создаем класс, где прописываем роуты для определенного модуля в приле. Можно все роуты описать и здесь, но удобнее разбить
class SomeModuleApi {
    
    static func getSomeImportantData() async throws -> SomeType? {
        return try await NetworkManager.makeRequest(url: "/", method: .get, model: SomeType.self)
    }
    
}



struct SomeType: Codable {
    var date: String
    var milliseconds_since_epoch: Int
    var time: String
}

