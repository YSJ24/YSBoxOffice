//
//  EndPoint.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 2023/08/01.
//

public struct EndPoint: NetworkConfigurable {
    public var headerParameters: [String : String]?
    public var baseURL: String
    public var queryItems: [String : String]?
}
