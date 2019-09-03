//
//  ApiRequest.swift
//  FlickrDemoApp
//
//  Created by tanuj on 02/09/19.
//  Copyright © 2019 Tanuj Sharma. All rights reserved.
//

import UIKit

class ApiRequest: NSObject
{
    struct ApiRequest {
        static let flickrUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key={{ApiKey}}&tags={{SearchText}}&page={{PageNumber}}&per_page=20&format=json&nojsoncallback=1"
        static let flickrKey = "8ca24dbe817b5c6a5c4e48ccc9a84cd8"
    }
    func fetchPhotosForSearchText(using searchText: String, pageNumber : NSInteger , handler: @escaping(_ response: Data?, _ error: Error?) -> ()) {
        
        let apiKeyReplaceString: String = ApiRequest.flickrUrl.replacingOccurrences(of: "{{ApiKey}}", with: ApiRequest.flickrKey, options: .literal, range: nil)
        var finalString: String = apiKeyReplaceString.replacingOccurrences(of: "{{SearchText}}", with: searchText, options: .literal, range: nil)
        finalString = finalString.replacingOccurrences(of: "{{PageNumber}}", with: String(pageNumber), options: .literal, range: nil)
        guard let baseUrl = URL(string: finalString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: baseUrl) { (data, reposne, error) in
            if let error = error {
                handler(nil, error)
                return
            }
            if let data = data {
                handler(data, nil)
            }
        }
        task.resume()
    }
}
