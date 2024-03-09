//
//  ContentView.swift
//  Players
//
//  Created by Temirlan on 10.02.2024.
//

import SwiftUI
import Alamofire
struct ContentView: View {
    @StateObject var networkManager = NetworkManager.shared
    
    @State var players = [Profile]()
    @State var games: Games?
    @State var heroes = [MyHeroes]()
    var body: some View {
        NavigationView {
            List {
                ForEach(players, id: \.self) { player in
                    NavigationLink(destination: PlayerView(player: player, games: $games, heroes: $heroes)) {
                        Text("\(player.personaname)")
                    }
                }
                .onDelete(perform: removeProfile)
            }
            .listStyle(.plain)
            .navigationTitle(navigationTitle())
            .navigationBarItems(trailing: Button(action: {
                alertTF(
                    title: "AccountID",
                    message: "Enter your Account ID",
                    primaryTitle: "Search",
                    secondaryTitle: "Cancel",
                    keyboardType: .numberPad) { text in
                        networkManager.accountId = text
                        networkManager.fetchPlayer() { result in
                            switch result {
                            case .success(let newPlayer):
                                players.append(contentsOf: newPlayer)
                            case .failure(let someError):
                                print("\(someError)")
                            }
                        }
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
                    } secondaryAction: {
                        print("Canceled")
                    }
            }, label: {
                Image(systemName: "plus")
            }) )
        }
    }
    func navigationTitle() -> String {
        if players.isEmpty { return "Add player"}
        if players.count == 1 { return "Player"}
        return "Players"
    }
    func removeProfile(as offsets: IndexSet) {
        players.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
extension View {
    func alertTF(
        title: String,
        message: String,
        primaryTitle: String,
        secondaryTitle: String,
        keyboardType: UIKeyboardType = .default,
        primaryAction: @escaping (String) ->(),
        secondaryAction: @escaping () -> ()
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = keyboardType
        }
        alert.addAction(.init(title: secondaryTitle, style: .cancel, handler: {
            _ in secondaryAction()
        }))
        alert.addAction(.init(title: primaryTitle, style: .default, handler: {
            _ in
            if let text = alert.textFields?[0].text {
                primaryAction(text)
            } else {
                primaryAction("")
            }
        }))
        rootController().present(alert, animated: true, completion: nil)
    }
    func rootController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as?
                UIWindowScene else { return .init() }
        guard let root = screen.windows.first?.rootViewController else { return .init() }
        return root
    }
}
