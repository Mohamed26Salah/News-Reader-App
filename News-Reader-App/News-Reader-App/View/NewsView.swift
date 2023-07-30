//
//  NewsView.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//


import SwiftUI
import SDWebImageSwiftUI

struct NewsView: View {
    @ObservedObject var agents = NewsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Text("News")
                .font(.title)
                .padding(.top, -30)
            SearchBar(searchText: $searchText)
            if let news = agents.newsData?.articles {
                List(news, id: \.url) { article in
                    ZStack {
                        ArticleCellView(article: article)
                            .frame(height: 200)
                        NavigationLink(destination: ArticleDetails(article: article)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
        }
    }
}
struct ArticleCellView: View {
    let article: Article
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                WebImage(url: URL(string: article.urlToImage))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: 200) // Set the fixed height of 200
                    .cornerRadius(8) // Apply corner radius to the image
                    .clipped()
                
                Color.black.opacity(0.3)
                    .frame(width: geometry.size.width, height: 200) // Set the fixed height of 200
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.title2)
                        .foregroundColor(.white)
                        .lineLimit(2) // Truncate the title to 2 lines
                    Text("Author: " + article.author)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                    Text(article.description.prefix(100))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(3) // Truncate the description to 3 lines
                }
                .padding()
                .alignmentGuide(.top, computeValue: { d in
                    (200 - d.height) / 2 // Center the content vertically within the 200 height
                })
            }
            .frame(width: geometry.size.width, height: 200) // Set the fixed height of 200
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            HStack {
                TextField("Search", text: $searchText)
                    .padding(.leading, 8)
                Spacer()
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
               
            }
            .background(Color(.systemGray5))
            .cornerRadius(8)
            .padding(.horizontal)
            Button {
                print("Search")
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.leading, -10)
            .padding(.trailing, 8)
            Button {
                print("Search")
            } label: {
                Image(systemName: "arrow.clockwise")
                    .foregroundColor(.gray)
            }
            .padding(.trailing, 8)
        }
        
    }
}
//
//struct NewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsView()
//    }
//}
