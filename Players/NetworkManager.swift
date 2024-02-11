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
            return URL(string: "https://api.opendota.com/api/players/\(accountID)/wl")!
        case .myHeroes(let accountID):
            return URL(string: "https://api.opendota.com/api/players/\(accountID)/heroes")!
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
    func timeAgoString(from unixTime: Int) -> String {
        if unixTime == 0 {
            return "0"
        }
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now < date) ? now : date
        let latest = (earliest == now) ? date : now
        
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: earliest, to: latest)
        
        if let year = components.year, year >= 2 {
            return "\(year) years ago"
        } else if let year = components.year, year >= 1 {
            return "Last year"
        } else if let month = components.month, month >= 2 {
            return "\(month) months ago"
        } else if let month = components.month, month >= 1 {
            return "Last month"
        } else if let week = components.weekOfYear, week >= 2 {
            return "\(week) weeks ago"
        } else if let week = components.weekOfYear, week >= 1 {
            return "Last week"
        } else if let day = components.day, day >= 2 {
            return "\(day) days ago"
        } else if let day = components.day, day >= 1 {
            return "Yesterday"
        } else if let hour = components.hour, hour >= 2 {
            return "\(hour) hours ago"
        } else if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        } else if let minute = components.minute, minute >= 2 {
            return "\(minute) minutes ago"
        } else if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        } else if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        } else {
            return "Just now"
        }
    }

}
