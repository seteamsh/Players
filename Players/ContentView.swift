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
    @StateObject var coreDataStack = CoreDataStack.shared
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
                    } secondaryAction: {
                        print("Canceled")
                    }
            }, label: {
                Image(systemName: "plus")
            }) )
            .environment(\.managedObjectContext, coreDataStack.persistantContainer.viewContext)
        }
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
