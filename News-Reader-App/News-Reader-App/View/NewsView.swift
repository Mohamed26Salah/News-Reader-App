//
//  NewsView.swift
//  News-Reader-App
//
//  Created by Mohamed Salah on 30/07/2023.
//


import SwiftUI
import SDWebImageSwiftUI

struct NewsView: View {
    @ObservedObject var articles = NewsViewModel()
    @State private var searchText = ""
    var body: some View {
        VStack {
            Text(articles.queury + " News")
                .font(.title)
                .padding(.top, -30)
                .foregroundColor(Color(UIColor.label))
            SearchBar(articlesViewModel: articles, isRefrehDisabled: $articles.isRefreshDisabled, searchText: $searchText)
            if let news = articles.newsData?.articles {
                List(news, id: \.url) { article in
                    ZStack {
                        ArticleCellView(article: article, imageData: articles.getCachedImageFromRealm(url: article.url), error: $articles.isTheirAnError)
                            .frame(height: 200)
                        NavigationLink(destination: ArticleDetails(article: article, imageData: articles.getCachedImageFromRealm(url: article.url), error: $articles.isTheirAnError)) {
                            EmptyView()
                        }
                        .opacity(0.0)
                    }
                }
                .listRowInsets(EdgeInsets())
            }
        }
//        .background(Color(UIColor.systemBackground))
        .alert(articles.errorMessage, isPresented: $articles.showError) {
        }
    }
}
struct ArticleCellView: View {
    let article: Article
    let imageData: Data?
    @Binding var error: Bool
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if error {
                    if let imageD = imageData {
                        let uiImage = UIImage(data: imageD)
                        Image(uiImage: uiImage!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: 200)
                            .cornerRadius(8)
                            .clipped()
                    }
                } else {
                    WebImage(url: URL(string: article.urlToImage))
                        .placeholder(content: {
                            ProgressView()
                                .font(.largeTitle)
                        })
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: 200)
                        .cornerRadius(8)
                        .clipped()
                }
                Color.black.opacity(0.3)
                    .frame(width: geometry.size.width, height: 200)
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.title2)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    Text("Author: " + article.author)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.white)
                    Text(article.description.prefix(100))
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .lineLimit(3)
                }
                .padding()
                .alignmentGuide(.top, computeValue: { d in
                    (200 - d.height) / 2 // Center the content vertically within the 200 height
                })
            }
            .frame(width: geometry.size.width, height: 200)
        }
    }
}

struct SearchBar: View {
    var articlesViewModel: NewsViewModel
    @Binding var isRefrehDisabled: Bool
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
                articlesViewModel.queury = searchText
                articlesViewModel.searchAPI()
            } label: {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(.leading, -10)
            .padding(.trailing, 8)
            //ProgressView
            if isRefrehDisabled {
                ProgressView()
                    .font(.body)
                    .padding(.trailing, 8)
            } else {
                Button {
                    articlesViewModel.fetchDataFromApi()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.gray)
                }
                .disabled(isRefrehDisabled)
                .opacity(isRefrehDisabled ? 0.2 : 1.0)
                .padding(.trailing, 8)
            }
        }
        
    }
}
//
//struct NewsView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewsView()
//    }
//}
