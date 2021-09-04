//
//  PhotosViewController.swift
//  UnsplashGallery
//
//  Created by Saad on 8/4/21.
//

import UIKit

class PhotosViewController: AbstractViewController {

    @IBOutlet weak var cvMain: UICollectionView!
    @IBOutlet weak var searchBarVIew: MySearchBarView!
        
    lazy var adapter = CollectionAdapter<PhotoModel>(collectionView: cvMain, delegate: self)
    let imagePicker = FilePicker()
    var searchQuery = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarVIew.delegate = self
        
        adapter.numberOfColumns = 2
        adapter.cellPadding = 1
        


        let viewNoResults = adapter.getView(viewClass: NoResultsCollectionViewCell.self)
        viewNoResults.addImageAction = {view in
            self.searchBarVIew.pickImageClicked()
        }
        adapter.viewNoResults = viewNoResults
        
        adapter.initiate()
        
    }
    
    
    override func showProgress(show: Bool) {
        searchBarVIew.isLoading = show
    }
    

    //MARK: Actions
    
    
    @IBAction func btnViewAction(_ sender: UIBarButtonItem) {
        
        if !self.adapter.freeStyle {
            sender.image = UIImage(systemName: "rectangle.grid.2x2")
            self.adapter.freeStyle = true

        } else {
            sender.image = UIImage(systemName: "rectangle.3.offgrid")
            self.adapter.freeStyle = false

        }
        
    }
    
    
    
    
}


 
extension PhotosViewController: CollectionAdapterDelegate {

    
    func heightForCell(collectionView: UICollectionView, indexPath: IndexPath) -> CGFloat {
        let item = adapter.getItem(at: indexPath)
        let cellWidth = (collectionView.frame.width-6)/2 //because we are showing two columns
        let imageHeight = Double(item.height ?? 0)
        let imageWidth = Double(item.width ?? 1)
        let h:CGFloat = CGFloat(imageHeight/imageWidth) * cellWidth

        return   h + 60

    }
    
    
    func loadData(collectionView: UICollectionView, page: Int) {
        
        if !searchQuery.isEmpty
        {
            apiCalls.search(
                query: searchQuery,
                page: page,
                per_page: 10,
                order_by: nil,
                collections: nil,
                content_filter: nil,
                color: nil,
                orientation: nil,
                failure: nil) { (response) in
                self.adapter.addPage(lst: response.results)
            }
        }else {
            apiCalls.photoes(
                page: page,
                failure: nil) { (response) in
                self.adapter.addPage(lst: response)
            }
            
        }
        

        
    }
    
    func onItemSelected(collectionView: UICollectionView, indexPath: IndexPath) {
        let item = adapter.getItem(at: indexPath)
        gotoViewController(DetailsViewController.self) { (target) in
            target.item = item
        }
        
    }
    
    func onRefresh(collectionView: UICollectionView, refresher: UIRefreshControl?) {
        adapter.initiate()
    }
    
    func cellWillAppear(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = adapter.getNibCell(cellClass: FeedsCollectionViewCell.self, indexPath: indexPath)
        let item = adapter.getItem(at: indexPath)
        cell.item = item
        cell.shareAction = {cell in
            
            let alert = UIAlertController(title: "More", message: nil, preferredStyle: .actionSheet)
            
            
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (action) in
                if !Defaults[.photoesList].contains(item) {
                    Defaults[.photoesList].append(item)
                    self.toast("Image saved successfully")
                } else {
                    self.toast("Image already saved")
                }
                
            }))
            
            alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (action) in
                self.displayShareSheet(shareContent: cell.item?.urls?.full)

            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            
            
        }
        return cell
                
    }
    
    
}

extension PhotosViewController: MySearchBarDelegate{
    func onTextChange(field: UITextField) {
        adapter.filter { (item) -> Bool in
            return field.text == "" ? true : (item.altDescription?.lowercased() ?? "").contains(field.text?.lowercased() ?? "")
        }
    }
    
    func onImagePressed() {
        self.gotoViewController(AddPhotoTableViewController.self) { (target) in
            target.callback = {model in

                self.adapter.addPage(lst: [model])
            }
        }
    }
    
    func onSearchHit(field: UITextField) {
        searchQuery = field.text ?? ""
        adapter.initiate()
        
    }
    
}
