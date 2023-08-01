//
//  News_Reader_AppTests2.swift
//  News-Reader-AppTests2
//
//  Created by Mohamed Salah on 02/08/2023.
//

import XCTest
@testable import News_Reader_App

final class News_Reader_AppTests2: XCTestCase {

    var sut: APIClient!
    
    override func setUp() {
        super.setUp()
        let provider = NetworkAPIProvider()
        let baseURL = URL(string: "https://newsapi.org/v2/everything?q=Google&from=2023-07-01&sortBy=popularity&apiKey=3f913531a6404bc4a4b63f57f4c7dff8")
        sut = APIClient(baseURL: baseURL!, apiProvider: provider)
    }
    
    override func tearDown() {
        sut = nil
    }
    
    func testFetchNews() {
        let promise = XCTestExpectation(description: "Fetch news Completed")
        var responseError: Error?
        var responseNews: NewsParser?
        
        guard let bundle = Bundle.unitTest.path(forResource: "articles", ofType: "json") else {
            XCTFail("Error: content Not Found ")
            return
        }
        sut.baseURL = URL(fileURLWithPath: bundle)
        sut.fetchResourceData(modelDTO: responseNews) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                responseNews = data
            case .failure(let error):
                print(error.localizedDescription)
                responseError = error
            }
        }
        wait(for: [promise])
        XCTAssertNil(responseError)
        XCTAssertNotNil(responseNews)
    }

}
