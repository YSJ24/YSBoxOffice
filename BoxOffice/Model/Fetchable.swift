//
//  Fetchable.swift
//  BoxOffice
//
//  Created by by Yeseul Jang on 2023/08/16.
//

import Foundation

protocol Fetchable: AnyObject, NetworkConfigurable {
}

extension Fetchable {
    func fetchBoxOfficeData(networkManager: NetworkManager, queryParameters: [String: String], completion: @escaping () -> Void) {
        queryParameters.forEach { [weak self] (key, value) in
            self?.queryItems = [key: value]
        }
        
        do {
            let endPoint = EndPoint(baseURL: baseURL, queryItems: queryParameters)
            
            let url = try endPoint.generateURL(isFullPath: false)
            
            let urlRequest = URLRequest(url: url)
            
            networkManager.getBoxOfficeData(requestURL: urlRequest) { (boxOffice: BoxOffice) in
                let count = boxOffice.boxOfficeResult.dailyBoxOfficeList.count
                for index in 0...(count-1) {
                    let rankNumber = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankNumber
                    let rankIntensity = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankIntensity
                    let movieName = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].movieName
                    let audienceCount = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].audienceCount
                    let audienceAccumulated = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].audienceAccumulated
                    let rankOldAndNew = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].rankOldAndNew
                    let movieCode = boxOffice.boxOfficeResult.dailyBoxOfficeList[index].movieCode
                    
                    let items = Item(rankNumber: rankNumber, rankIntensity: rankIntensity, movieName: movieName, audienceCount: audienceCount, audienceAccumulated: audienceAccumulated, rankOldAndNew: rankOldAndNew, movieCode: movieCode)
                    
                    Item.all.append(items)
                }
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

extension Fetchable {
    func fetchMoviePoster(networkManager: NetworkManager, headers: [String: String] ,queryParameters: [String: String], completion: @escaping (String) -> Void) {
        queryParameters.forEach { [weak self] (key, value) in
            self?.queryItems = [key: value]
        }
        
        do {
            let endPoint = EndPoint(headerParameters: headers, baseURL: baseURL, queryItems: queryParameters)
            
            let url = try endPoint.generateURL(isFullPath: false)
            let config = ApiDataNetworkConfig(baseURL: url, headers: headers, queryParameters: queryParameters)
            let urlRequest = try generateURLRequest(config: config)
            
            networkManager.getBoxOfficeData(requestURL: urlRequest) { (moviePoster: KakaoImageSearchResult) in
                let moviePosterURL = moviePoster.documents[0].imageUrl
                guard let moviePosterImageURL = MoviePoster(imageUrl: moviePosterURL).imageUrl else { return }
                completion(moviePosterImageURL)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
