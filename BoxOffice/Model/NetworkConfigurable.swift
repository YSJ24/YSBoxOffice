//
//  NetworkConfigurable.swift
//  BoxOffice
//
//  Created by Yeseul Jang on 2023/08/01.
//

import Foundation

public protocol NetworkConfigurable {
    var baseURL: String { get }
    var queryItems: [String: String]? { get set }
    var headerParameters: [String: String]? { get }
}

extension NetworkConfigurable {
    public func generateURLRequest(config: ApiDataConfigurable) throws -> URLRequest {
        var urlQureyItems: [URLQueryItem] = []
        
        var allHeaders: [String: String] = config.headers
        headerParameters?.forEach({ allHeaders.updateValue($1, forKey: $0) })
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkConfigurableError.urlComponents
        }
        
        queryItems?.forEach {
            urlQureyItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        urlComponents.queryItems = urlQureyItems
        
        guard let url = urlComponents.url else {
            throw NetworkConfigurableError.url
        }
        
        var requestURL = URLRequest(url: url)
        requestURL.allHTTPHeaderFields = allHeaders
        
        return requestURL
    }
    
    public func generateURL(isFullPath: Bool) throws -> URL {
        guard let url = URL(string: baseURL) else {
            throw NetworkConfigurableError.url
        }
        
        let baseURL = url.absoluteString
        
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw NetworkConfigurableError.urlComponents
        }
        
        var urlQureyItems: [URLQueryItem] = []
        
        queryItems?.forEach {
            urlQureyItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        
        urlComponents.queryItems = !urlQureyItems.isEmpty ? urlQureyItems : nil
        
        let fullPathURL = isFullPath ? URL(string: baseURL) : urlComponents.url
        
        guard let urlResult = fullPathURL else {
            throw NetworkConfigurableError.urlResult
        }
        
        return urlResult
    }
}
