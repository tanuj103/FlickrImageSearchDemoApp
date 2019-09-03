//
//  PhotoCollectionViewCell.swift
//  FlickrDemoApp
//
//  Created by tanuj on 02/09/19.
//  Copyright © 2019 Tanuj Sharma. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.image = nil
    }
    func configUIWithPhotoUrlString(photoUrlString : String)
    {
        CustomCacheImageView().downloadImage(from: photoUrlString, withContentMode: .scaleAspectFill) {(image) in
            self.imageView.image = image
        }
    }
}
