//
//  ListingVC.swift
//  FlickrDemoApp
//
//  Created by tanuj on 02/09/19.
//  Copyright © 2019 Tanuj Sharma. All rights reserved.
//

import UIKit
private let PhotoCellIdentifier = "photoCollectionViewCell";
private let TitleText           = "Flickr Search";
private let NoDataFoundText     = "No data found";

class ListingVC: UIViewController, UISearchBarDelegate {
    
    struct CellSize {
        static let lineSpacing: CGFloat = 10
        static let itemSpacing: CGFloat = 10
        static let edgeInset:   CGFloat = 10
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    var photosArray: Array? = []
    var totalNoOfPages : NSInteger = 0
    var pageNo : NSInteger = 1
    var pageSize : NSInteger = 20
    var isLoading : Bool = false
    var searchingText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
    }
    
    func configUI()
    {
        self.title = TitleText
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performSearchWithText(searchText: searchBar.text!)
    }
    
    // MARK: - Private Method
    private func performSearchWithText(searchText: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        searchingText = searchText
        apiCallToFetchPhotosForSearchText(searchText: searchText, page: pageNo)
    }
    
    // MARK: - Api to fetch photos for search Method
    func apiCallToFetchPhotosForSearchText(searchText : String , page : NSInteger)
    {
        self.activityIndicator.startAnimating()
        //Initiate FetchPhotosForSearchText Api Call
        ApiRequest().fetchPhotosForSearchText(using: searchText, pageNumber : page) {(data, error) in
            guard let data = data else {
                return
            }
            do {
                let flickrModel = try JSONDecoder().decode(FlickrModel.self, from: data)
                self.photosArray?.append(contentsOf: (flickrModel.photos?.photo)!)
                if self.photosArray?.count == 0
                {
                    DispatchQueue.main.async {
                        self.showAlertOnNoDataAvailable()
                    }
                    return
                }
                
                let value : CGFloat = CGFloat(Int(flickrModel.photos!.total)!/self.pageSize)
                self.totalNoOfPages = NSInteger(ceil(value))
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicator.stopAnimating()
                    self.title = searchText
                    self.collectionView.reloadData()
                })
            } catch let error {
                DispatchQueue.main.async(execute: { () -> Void in
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicator.stopAnimating()
                })
                print(error.localizedDescription)
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar,textDidChange searchText: String)
    {
        if searchText.isEmpty {
            resetSearch()
        }
    }
    
    func resetSearch()
    {
        self.title = TitleText
        searchingText = ""
        totalNoOfPages = 0
        pageNo = 1
        isLoading = false
        self.photosArray?.removeAll()
        self.collectionView.reloadData()
    }
    
    private func showAlertOnNoDataAvailable() {
        let alertController = UIAlertController(title: nil, message: NoDataFoundText , preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ListingVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photoCount = self.photosArray?.count else {
            return 0
        }
        return photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCellIdentifier, for: indexPath) as? PhotoCollectionViewCell {
            cell.imageView.image = nil
            let photo = self.photosArray![indexPath.row] as! FlickrPhotosModel
            cell.configUIWithPhotoUrlString(photoUrlString: photo.photoUrl)
            cell.setNeedsLayout()
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - 40) * 0.33,
                      height: (collectionView.bounds.size.width - 40) * 0.33)
    }
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CellSize.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CellSize.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CellSize.edgeInset,
                            left: CellSize.edgeInset,
                            bottom: CellSize.edgeInset,
                            right: CellSize.edgeInset)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height-33 && self.photosArray!.count > 0 && scrollView.contentOffset.y > 0
        {
            if isLoading == false
            {
                isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.loadMoreData()
                }
            }
        }
    }
    
    func loadMoreData()
    {
        if (pageNo <= totalNoOfPages)
        {
            isLoading = false;
            pageNo += 1;
            apiCallToFetchPhotosForSearchText(searchText: searchingText, page: pageNo)
        }
    }
}

