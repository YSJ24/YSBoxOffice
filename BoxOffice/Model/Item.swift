//
//  Item.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 2023/08/10.
//

import Foundation

struct Item: Hashable {
    let rankNumber: String?
    let rankIntensity: String?
    let movieName: String?
    let audienceCount: String?
    let audienceAccumulated: String?
    let rankOldAndNew: String?
    let movieCode: String?
    
    init(rankNumber: String? = nil, rankIntensity: String? = nil, movieName: String? = nil, audienceCount: String? = nil, audienceAccumulated: String? = nil, rankOldAndNew: String? = nil, movieCode: String? = nil) {
        self.rankNumber = rankNumber
        self.rankIntensity = rankIntensity
        self.movieName = movieName
        self.audienceCount = audienceCount
        self.audienceAccumulated = audienceAccumulated
        self.rankOldAndNew = rankOldAndNew
        self.movieCode = movieCode
    }
    
    private let identifier = UUID()
    
    static var all: [Item] = []
}
