//
//  NetworkManager.swift
//  Players
//
//  Created by Temirlan on 10.02.2024.
//

import Foundation
import Alamofire
enum NetworkError: Error {
    case noData
}
enum Link {
    case profile(accountID: String)
    case games(accountID: String)
    case myHeroes(accountID: String)
    case allHeroes
    var url: URL {
        switch self {
        case .profile(let accountID):
            return URL(string: "https://api.opendota.com/api/players/\(accountID)")!
        case .games(let accountID):
            return URL(string: "https://api.opendota.com/api/players/\(accountID)/wl\(NetworkManager.shared.isTurbo ? "?significant=0&game_mode=23" : "")")!
        case .myHeroes(let accountID):
            return URL(string: "https://api.opendota.com/api/players/\(accountID)/heroes\(NetworkManager.shared.isTurbo ? "?significant=0&game_mode=23" : "")")!
        case .allHeroes:
            return URL(string: "https://api.opendota.com/api/heroStats")!
        }
    }
}
final class NetworkManager: ObservableObject {
    init () {}
    static let shared = NetworkManager()
    @Published var allHeroes = [AllHeroes]()
    @Published var accountId = ""
    @Published var isTurbo = false
    func fetchPlayer(completion: @escaping(Result<[Profile], NetworkError>) -> Void) {
        AF.request(Link.profile(accountID: accountId).url)
            .validate()
            .responseData { responseData in
                switch responseData.result {
                case .success(let correctData):
                    do {
                        let decoded = try JSONDecoder().decode(Query.self, from: correctData)
                        completion(.success([decoded.profile]))
                    } catch {
                        completion(.failure(.noData))
                    }
                case .failure(let error):
                    print("\(error)")
                    completion(.failure(.noData))
                }
            }
    }
    func fetchGames(completion: @escaping(Result<Games, NetworkError>) -> Void) {
        AF.request(Link.games(accountID: accountId).url)
            .validate()
            .responseData { responseData in
                switch responseData.result {
                case .success(let correctData):
                    do {
                        let games = try JSONDecoder().decode(Games.self, from: correctData)
                        completion(.success(games))
                    } catch {
                        completion(.failure(.noData))
                    }
                case .failure(let afError):
                    print("\(afError)")
                    completion(.failure(.noData))
                }
            }
    }
    func fetchMyHeroes(completion: @escaping(Result<[MyHeroes], NetworkError>) -> Void) {
        AF.request(Link.myHeroes(accountID: accountId).url)
            .validate()
            .responseData { responseData in
                switch responseData.result {
                case .success(let correctData):
                    do {
                        let decoded = try JSONDecoder().decode([MyHeroes].self, from: correctData)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(.noData))
                    }
                case .failure(let afError):
                    print("\(afError)")
                    completion(.failure(.noData))
                }
            }
    }
    func fetchAllHeroes(completion: @escaping(Result<[AllHeroes], NetworkError>) -> Void) {
        AF.request(Link.allHeroes.url)
            .validate()
            .responseData { responseData in
                switch responseData.result {
                case .success(let correctData):
                    do {
                        let allHeroes = try JSONDecoder().decode([AllHeroes].self, from: correctData)
                        completion(.success(allHeroes))
                    } catch {
                        completion(.failure(.noData))
                    }
                case .failure(let afError):
                    print("\(afError)")
                    completion(.failure(.noData))
                }
            }
    }
    func getHeroImage(for heroID: Int) -> String? {
        if let heroesStat = allHeroes.first(where: { $0.id == heroID}) {
            return heroesStat.img
        }
        return nil
    }
    func getHeroName(for heroID: Int) -> String? {
        if let heroesStat = allHeroes.first(where: { $0.id == heroID}) {
            return heroesStat.localized_name
        }
        return nil
    }
}
