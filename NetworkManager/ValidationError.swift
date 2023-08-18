//
//  ValidationError.swift
//  NetworkManager
//
//  Created by Alexander Sobolev on 18.8.23..
//

import SwiftUI


// Модель ошибок с бекенда

struct ValidationError: Decodable {
    let message: String
    let errors: [String: [String]]
}


