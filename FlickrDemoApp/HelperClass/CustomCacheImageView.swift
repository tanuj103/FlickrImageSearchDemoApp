//
//  CustomCacheImageView.swift
//  FlickrDemoApp
//
//  Created by tanuj on 02/09/19.
//  Copyright © 2019 Tanuj Sharma. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class CustomCacheImageView: UIImageView {
    var urlString: String?
    
    func downloadImage(from link:String, withContentMode: UIView.ContentMode, handler: @escaping(_ imageDownloaded: UIImage?) -> ()) {
        
        //add the placeholder for all the images fetched
        handler(UIImage(named: "placeHoldeImage"))
        //10 MB limit
        imageCache.totalCostLimit = 10 * 1024 * 1024
        urlString = link
        //Make sure the url is valid
        image = nil
        
        //check if image is already in cache if so load it
        if let imageFromCache = imageCache.object(forKey: link as NSString){
            self.image = imageFromCache
            self.contentMode =  withContentMode
            handler(self.image)
        }
        
        // download image if image is not in cache
        guard let url = URL(string: urlString!) else{
            handler(self.image)
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    //if image not found return a placeholder image
                    guard let image = UIImage(data: data) else{
                        imageCache.setObject((UIImage(named: "placeHoldeImage")!), forKey: link as NSString)
                        return
                    }
                    // we have an image!
                    if link == self.urlString{
                        self.contentMode =  withContentMode
                        self.image = image
                    }
                    handler(self.image)
                    // add image to the cache!
                    imageCache.setObject(image, forKey: link as NSString)
                }
            }
            }.resume()
    }
}
