//
//  Flight.swift
//  Kiwi
//
//  Created by Denis Mikhaylovskiy on 12.12.2022.
//

import Foundation

struct Flight: Codable {
    let id: String
    let cityFrom: String
    let cityTo: String
    let countryTo: Country
    let dTime: Int
    let distance: Double
    let price: Int
    
}

struct Country: Codable {
    let code: String
    let name: String
}

struct Response: Codable {
    let search_id: String
    let data: [Flight]
}
