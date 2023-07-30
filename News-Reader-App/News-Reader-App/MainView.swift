//
//  MainView.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import SwiftUI

struct MainView: View {
    //    @ObservedObject var agents = NewsViewModel()
    @State private var selectedTab = 0
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ZStack {
                    Color.white
                        .ignoresSafeArea(.all)
                    NewsView()
                }
                .tabItem {
                    Image(systemName: "newspaper")
                    Text("News")
                }
                .bold()
                .tag(0)
//                .overlay(
//                    VStack {
//                        Text("News")
//                            .font(.title)
//                            .foregroundColor(.black)
//                            .padding()
//                        
//                        Spacer()
//                    }
//                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
//                        .padding(),
//                    alignment: .topLeading
//                )
                ZStack {
                    Color.white
                        .ignoresSafeArea(.all)
                }
                .tabItem {
                    Image(systemName: "star")
                    Text("favourites")
                }
                .bold()
                .tag(1)
            }
            .tint(Color.red)
            .navigationBarHidden(false)
            .onAppear {
                let tabBarAppearance = UITabBarAppearance()
                tabBarAppearance.configureWithDefaultBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
