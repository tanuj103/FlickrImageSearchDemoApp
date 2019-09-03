//
//  FlickrModel.swift
//  FlickrDemoApp
//
//  Created by tanuj on 02/09/19.
//  Copyright © 2019 Tanuj Sharma. All rights reserved.
//

import UIKit

struct FlickrModel: Codable {
    var photos: Photos?
}

struct Photos: Codable {
    var photo: [FlickrPhotosModel]?
    let pages : Int
    let total : String
}

struct FlickrPhotosModel: Codable {
    let id: String?
    let farm: Int?
    let secret: String?
    let server: String?
    let title: String?
    
    var photoUrl: String {
        return "https://farm\(String(describing: farm!)).staticflickr.com/\(String(describing: server!))/\(String(describing: id!))_\(String(describing: secret!))_m.jpg"
    }
}
