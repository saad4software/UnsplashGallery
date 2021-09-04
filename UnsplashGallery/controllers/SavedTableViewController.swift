//
//  SavedTableViewController.swift
//  UnsplashGallery
//
//  Created by Saad on 8/4/21.
//

import UIKit

class SavedTableViewController: UITableViewController {
    
    lazy var adapter = TableAdapter(tableView: tableView, delegate: self)
    @IBOutlet weak var btnAdd: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adapter.initiate()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.deletable = true
        
        
        
        let viewNoResults = adapter.getView(viewClass: NoResultsCollectionViewCell.self)
        viewNoResults.addImageAction = {view in
            self.btnAddAction(self.btnAdd)
            
        }
        adapter.viewNoResults = viewNoResults
        
    }
    
    
    @IBAction func btnClearAction(_ sender: Any) {
        let alert = UIAlertController(title: "Clear Photos", message: "Do you want to clear saved photos?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (action) in
            Defaults[.photoesList] = []
            self.adapter.initiate()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func btnAddAction(_ sender: UIBarButtonItem) {
        self.gotoViewController(AddPhotoTableViewController.self) { (target) in
            target.callback = {model in
                if !Defaults[.photoesList].contains(model) {
                    Defaults[.photoesList].append(model)
                }
                
            }
        }
    }
    
}

extension SavedTableViewController: TableAdapterDelegate{
    func loadData(tableView: UITableView, section: String, page: Int) {
        adapter.addOnce(lst: Defaults[.photoesList])
    }
    
    func onItemSelected(tableView: UITableView, indexPath: IndexPath) {
        let item = adapter.getItem(at: indexPath) as? PhotoModel
        gotoViewController(DetailsViewController.self) { (target) in
            target.item = item
        }
    }
    
    func onRefresh(tableView: UITableView, refresher: UIRefreshControl) {
        viewDidLoad()
    }
    
    func onItemDeleted(tableView: UITableView, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Photo", message: "Do you want to delete this item?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action) in
            Defaults[.photoesList].remove(at: indexPath.item)
            self.adapter.initiate()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func cellWillAppear(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SavedImageTableViewCell
        cell.item = adapter.getItem(at: indexPath) as? PhotoModel
        return cell
    }
    
    
}
