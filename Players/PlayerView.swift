//
//  PlayerView.swift
//  Players
//
//  Created by Temirlan on 10.02.2024.
//

import SwiftUI
import Kingfisher
struct PlayerView: View {
    @StateObject var networkManager = NetworkManager.shared
    var player: Profile
    @Binding var games: Games?
    @Binding var heroes: [MyHeroes]
    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    KFImage(URL(string: "\(player.avatarfull)"))
                    Toggle("Турбовоин", isOn: $networkManager.isTurbo)
                        .onChange(of: networkManager.isTurbo) { oldValue, newValue in
                            if newValue {
                                networkManager.fetchGames() { result in
                                    switch result {
                                    case .success(let newGames):
                                        games = newGames
                                    case .failure(let someError):
                                        print("\(someError)")
                                    }
                                }
                                
                                networkManager.fetchMyHeroes() { result in
                                    switch result {
                                    case .success(let myHeroes):
                                        heroes = myHeroes // Присваиваем значение myHeroes свойству heroes
                                    case .failure(let error):
                                        print("\(error)")
                                    }
                                }
                            } else {
                                networkManager.fetchGames() { result in
                                    switch result {
                                    case .success(let newGames):
                                        games = newGames
                                    case .failure(let someError):
                                        print("\(someError)")
                                    }
                                }
                                
                                networkManager.fetchMyHeroes() { result in
                                    switch result {
                                    case .success(let myHeroes):
                                        heroes = myHeroes // Присваиваем значение myHeroes свойству heroes
                                    case .failure(let error):
                                        print("\(error)")
                                    }
                                }
                            }
                        }
                    HStack {
                        VStack {
                            Text("WINS")
                            Text("\(games?.win ?? 0)")
                                .foregroundColor(Color.green)
                        }
                        VStack {
                            Text("LOSSES")
                            Text("\(games?.lose ?? 0)")
                                .foregroundColor(Color.red)
                        }
                        VStack {
                            Text("WINRATE")
                            Text("\(String(format: "%.2f", Double(games?.win ?? 0) / (Double(games?.win ?? 0) + Double(games?.lose ?? 0)) * 100)) %")
                        }
                    }
                }
                .navigationTitle("\(player.personaname)")
            }
            .tabItem { Image(systemName: "1.circle") }
            NavigationView {
                List(heroes, id: \.self) { hero in
                    HStack {
                        HStack {
                            KFImage(URL(string: "https://cdn.cloudflare.steamstatic.com\(networkManager.getHeroImage(for: hero.hero_id)!)"))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 60)
                        }
                        VStack {
                            Text("\(networkManager.getHeroName(for: hero.hero_id)!)")
                            Text("\(networkManager.timeAgoString(from: hero.last_played))")
                        }
                        Text("\(hero.games)")
                            .foregroundColor(Color.green)
                        Text("\(String(format: "%.1f", Double(hero.win) / (Double(hero.win) + Double(hero.games - hero.win)) * 100)) %")
                    }
                }
                .navigationTitle("Heroes")
            }
                .tabItem { Image(systemName: "2.circle") }
        }
        .task {
            networkManager.fetchAllHeroes() { result in
                switch result {
                case .success(let heroes):
                    networkManager.allHeroes = heroes
                case .failure(let error):
                    print("\(error)")
                }
            }
        }
    }
}


