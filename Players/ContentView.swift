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
    var body: some View {
        NavigationView {
            List(players, id: \.self) { player in
                NavigationLink{
                    PlayerView(player: player)
                } label: {
                    Text("\(player.personaname)")
                }
            }
            .navigationTitle("Players")
            .navigationBarItems(trailing: Button(action: {
                //
            }, label: {
                Image(systemName: "plus")
            }) )
        }
        .task {
            networkManager.fetchPlayer(from: Link.profile.url) { result in
                switch result {
                case .success(let newPlayer):
                    players = newPlayer
                case .failure(let someError):
                    print("\(someError)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
