//
//  KakaoImageSearchResult.swift
//  BoxOffice
//
//  Created by by Yeseul Jang on 2023/08/16.
//

import Foundation

struct KakaoImageSearchResult: Decodable, Hashable {
    let documents: [Documents]
}

struct Documents: Decodable, Hashable {
    let imageUrl: String
    
    private enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
    }
}
