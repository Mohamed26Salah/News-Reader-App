//
//  ArticleDetails.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ArticleDetails: View {
    let article: Article
    @State private var isFavorite = false
    @State private var showWebView = false
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 10) {
                    ZStack(alignment: .topLeading) {
                        WebImage(url: URL(string: article.urlToImage))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 200)
                            .cornerRadius(8)
                            .clipped()
                        
                        Color.black.opacity(0.3)
                            .frame(width: geometry.size.width, height: 200)
                            .cornerRadius(8)
                        
                        Text(article.title)
                            .font(.title)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .padding()
                        HStack {
                            Text("\(String(article.publishedAt.prefix(10)))")
                                .foregroundColor(.white)
                                .padding()
                            Spacer()
                            Button(action: {
                                isFavorite.toggle()
                            }) {
                                Image(systemName: isFavorite ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            .padding(20)
                        }
                        .padding(.top, geometry.size.height - (geometry.size.height - 110))
                    }
                    .frame(width: geometry.size.width, height: 200)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By: \(article.author)")
                            .font(.headline)
                        
                        Text("From: \(article.source.name?.rawValue ?? "Unknown")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray.opacity(0.2))
                        .overlay(
                            VStack(alignment: .leading) {
                                Text(article.title)
                                    .font(.headline)
                                    .padding()
                                    .layoutPriority(1) 
                                
                                Text(article.description)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                            }
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 260)
                        .padding()
                    
                    Button(action: {
                        //                    if let url = URL(string: article.url) {
                        //                        UIApplication.shared.open(url)
                        //                    }
                        showWebView.toggle()
                    }) {
                        Text("Read More")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showWebView) {
            WebView(urlString: article.url)
        }
        
    }
}

struct ArticleDetails_Previews: PreviewProvider {
    static let source = Source()
    static let article = Article(source: source, author: "", title: "", description: "", url: "", urlToImage: "", publishedAt: "", content: "")
    static var previews: some View {
        ArticleDetails(article: article)
    }
}
