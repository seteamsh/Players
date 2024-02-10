//
//  Player.swift
//  Players
//
//  Created by Temirlan on 10.02.2024.
//

import Foundation
struct Profile: Decodable, Hashable {
    let personaname: String
    let avatarfull: String
}

struct Query: Decodable {
    let profile: Profile
}

struct Games: Decodable {
    let win: Int
    let lose: Int
}

struct MyHeroes: Decodable, Hashable {
    let hero_id: Int
    let last_played: Int
    let games: Int
    let win: Int
}

struct AllHeroes: Decodable {
    let id: Int
    let localized_name: String
    let img: String
}
