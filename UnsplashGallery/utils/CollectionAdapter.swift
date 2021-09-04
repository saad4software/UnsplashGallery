//
//  CollectionAdapter.swift
//
//  Created by Saad on 10/12/18.
//  Copyright © 2018 Saad. All rights reserved.
//

import UIKit

class CollectionAdapter<T>: NSObject,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ViewControllerDelegate {
    
    //MARK: - State vars
    var numberOfColumns = 1 {
        didSet{
            freeLayout?.numberOfColumns = numberOfColumns
            collectionView?.reloadData()
        }
    }
    
    var cellPadding:CGFloat = 3 {
        didSet{
            freeLayout?.cellPadding = cellPadding
            collectionView?.reloadData()
        }
    }
    
    var freeStyle: Bool = true {
        didSet{
            if freeStyle {
                self.freeLayout = FreeCellLayout()
                self.freeLayout?.delegate = self
                self.collectionView?.collectionViewLayout = freeLayout!
            } else {
                self.collectionView?.collectionViewLayout = flowLayout!
            }
            reloadData()
        }
    }
    
    //MARK: - Public vars

    var isFullScreen = false//like pager?
    var isCentered = false
    var collectionView:UICollectionView?
    var pageControl: UIPageControl?
    var list = [T]()
    var viewNoResults:UIView?

    //MARK: - private vars
    private var oList = [T]()//original data list (without filtering)
    private var page = 1;//for pagenation
    private var pageLength = 0
    private var isDone = false
    private var delegate:CollectionAdapterDelegate?
    private var filterCondition:((T)->Bool) = {item in return true}
    private var selectedItemPosition:Int?
    private var selectedItemsPositions = [Int]()    //selected items indexes
    private var snapshotView: UIView?   //for dragging cells
    private var snapshotPanPoint: CGPoint?   //for dragging cells
    private var snapshotIndexPath: IndexPath?   //for dragging cells
    
    
    private var nibList = [String:UINib]()  //to ease loading nib cells
    
    
    //MARK: - calculated vars
    
    var isEmpty:Bool { list.isEmpty }
    var count:Int { list.count }
    
    
    
    var freeLayout: FreeCellLayout?
    var flowLayout: UICollectionViewFlowLayout?
    var refresher:UIRefreshControl?
    
    
    
    init(collectionView:UICollectionView,delegate:CollectionAdapterDelegate) {
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        (delegate as? AbstractViewController)?.addDelegate(delegate: self) //to update when rotating the screen
        
        self.collectionView = collectionView
        self.delegate = delegate
        self.flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout

        
        if (self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection == UICollectionView.ScrollDirection.vertical
        {
            // if vertical then freelayout, else just stick to flowlayout
            self.freeLayout = FreeCellLayout()
            self.freeLayout?.delegate = self
            self.collectionView?.collectionViewLayout = freeLayout!
            
            
            self.refresher = UIRefreshControl() //swipe to refresh
            self.refresher?.tintColor = UIColor.red
            self.refresher?.addTarget(self, action: #selector(loadData), for: .valueChanged)
            if #available(iOS 10.0, *) {
                self.collectionView!.refreshControl = self.refresher
            } else {
                self.collectionView?.addSubview(self.refresher!)
            }
            self.collectionView!.alwaysBounceVertical = true

        }
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Results"
        
        self.viewNoResults = label
        

        // for dragging cells
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressRecognized(_:)))
        gestureRecognizer.minimumPressDuration = 0.2
        collectionView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    
    
    //MARK: - functions
    
    
    @objc func longPressRecognized(_ recognizer: UILongPressGestureRecognizer) {
          let location = recognizer.location(in: collectionView)
          let indexPath = collectionView?.indexPathForItem(at: location)
          
          switch recognizer.state {
          case UIGestureRecognizerState.began:
            guard let indexPath = indexPath else { return }
            
            let cell = cellForRow(at: indexPath)
            snapshotView = cell?.snapshotView(afterScreenUpdates: true)
            collectionView!.addSubview(snapshotView!)
            cell?.contentView.alpha = 0.0
            
            UIView.animate(withDuration: 0.2, animations: {
              self.snapshotView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
              self.snapshotView?.alpha = 0.9
            })
            
            snapshotPanPoint = location
            snapshotIndexPath = indexPath
          case UIGestureRecognizerState.changed:
            guard let snapshotPanPoint = snapshotPanPoint else { return }
            
            let translation = CGPoint(x: location.x - snapshotPanPoint.x, y: location.y - snapshotPanPoint.y)
            snapshotView?.center.x += translation.x
            snapshotView?.center.y += translation.y
            self.snapshotPanPoint = location
            
            guard let indexPath = indexPath else { return }
            
            exchangeItemsAtIndex(snapshotIndexPath!.item, withItemAtIndex: indexPath.item)
            collectionView!.moveItem(at: snapshotIndexPath!, to: indexPath)
            snapshotIndexPath = indexPath
          default:
            guard let snapshotIndexPath = snapshotIndexPath else { return }
            let cell = cellForRow(at: snapshotIndexPath)
            UIView.animate(
              withDuration: 0.2,
              animations: {
                self.snapshotView?.center = cell?.center ?? CGPoint(x: 0, y: 0)
                self.snapshotView?.transform = CGAffineTransform.identity
                self.snapshotView?.alpha = 1.0
              },
              completion: { finished in
                cell?.contentView.alpha = 1.0
                self.snapshotView?.removeFromSuperview()
                self.snapshotView = nil
            })
            self.snapshotIndexPath = nil
            self.snapshotPanPoint = nil
          }
    }
    
    
    @objc func loadData() {
        delegate?.onRefresh(collectionView: collectionView!, refresher: refresher)
    }
    
    /// if not set, it uses the number of items on the first page
    func setPageLength(pageLength:Int) {
        self.pageLength = pageLength
    }
    
    func initiate() {
        reset()
        delegate?.loadData(collectionView: collectionView!, page: 1)
    }
    
    func exchangeItemsAtIndex(_ index: Int, withItemAtIndex otherIndex: Int) {
      if index != otherIndex {
        list.swapAt(index, otherIndex)
      }
    }
    
    /// avoid using this function
    func cellForRow(at indexPath: IndexPath) -> UICollectionViewCell? {
        return (collectionView?.cellForItem(at: indexPath))
    }
    
    func filter(condition:@escaping (T)->Bool) {
        filterCondition = condition
        list = oList.filter(condition)
        collectionView?.reloadData()
        if collectionView!.isPagingEnabled && list.count > 0 {
            selectedItemPosition = 0
            delegate?.onItemSelected(collectionView: collectionView!, indexPath: IndexPath(item: 0, section: 0))
        }
    }
    

    func addPage(lst:[T]?) {

  
        if let data = lst, data.count > 0{
            if pageLength < data.count {pageLength = data.count}
            isDone = data.count < pageLength
            oList+=data
            list = oList.filter(filterCondition)
            page+=1
            collectionView?.reloadData()
            refresher?.endRefreshing()
            
        }
        else
        {
            isDone = true
            collectionView?.reloadData()
        }
        
    }
    
    /// can be called from (on last item) and it will be called only once
    func addOnce(lst:[T]?) {
        addPage(lst: lst)
        isDone = true
        
    }
    
    func reset() {
        page = 1
        list = [T]()
        oList = [T]()
        isDone = false
        filterCondition = {_ in return true}
        collectionView?.reloadData()
        
        refresher?.endRefreshing()
    }
    
    func initiate(lst:[T]?) {
        reset()
        addPage(lst: lst)
        delegate?.loadData(collectionView: collectionView!, page: page)
        if collectionView!.isPagingEnabled && selectedItemPosition == nil && list.count > 0 {
            selectedItemPosition = 0
            delegate?.onItemSelected(collectionView: collectionView!, indexPath: IndexPath(item: 0, section: 0))
        }
    }
    
    func updateItem(indexPath:IndexPath,item:T)
    {
        list[indexPath.item] = item
        initiate(lst: list)
    }
    
    func getItem(at:IndexPath) -> T {
        return list[at.item]
    }
    
    func getItem(item:Any) -> T {
        return item as! T
    }
    
    func endRefreshing() {
        refresher?.endRefreshing()
    }
    
    func removeItem(index:IndexPath, condition: ((T)->Bool))
    {
        list.remove(at: index.item)
        let i = oList.firstIndex(where: condition)
        oList.remove(at: i!)
        collectionView?.deleteItems(at: [index])
        isDone = true
        collectionView?.reloadData()

    }
    
    func getSelectedItem() -> T?
    {
        return selectedItemPosition != nil && selectedItemPosition! < list.count ? list[selectedItemPosition!] : nil
    }
    
    func getSelectedItemPosition() -> Int? {
        return selectedItemPosition
    }
    
    func getSelectedItems() -> [T]
    {
        var lst = [T]()
        for index in selectedItemsPositions
        {
            lst.append(list[index])
        }
        return lst
    }
    
    func getSelectedItemsPositions() -> [Int] {
        return selectedItemsPositions
    }
    
    func isSelectedItem(index:Int) -> Bool {
        return index == selectedItemPosition
    }
    
    func isSelectedItems(index:Int) -> Bool {
        return selectedItemsPositions.contains(index)
    }
    
    func select(index:Int) {
        if index < list.count {
            selectedItemPosition = index
            delegate?.onItemSelected(collectionView: collectionView!, indexPath: IndexPath(item: index, section: 0))
        }
    }
    
    func reloadData(){
        collectionView?.reloadData()
    }
    
    
    /// get cell from nib file
    func getNibCell<C>(cellClass:C.Type,indexPath:IndexPath) -> C where C:UICollectionViewCell{
        
        let id = String(describing: cellClass.classForCoder())
        
        if nibList[id] == nil {
            let nib = UINib(nibName: id, bundle: nil)
            nibList.updateValue(nib, forKey: id)
            collectionView?.register(nib, forCellWithReuseIdentifier: id)
        }
        //        let cell = Bundle.main.loadNibNamed("GoodCollectionViewCell", owner: self, options: nil)?[0] as! GoodCollectionViewCell
        return collectionView?.dequeueReusableCell(withReuseIdentifier: id, for: indexPath) as! C
    }
    
    func getView<V>(viewClass:V.Type) -> V where V:UIView {
        let id = String(describing: viewClass.classForCoder())
        let view = Bundle.main.loadNibNamed(id, owner: self, options: nil)?[0] as! UIView
        return view as! V
    }
    
    //MARK: Viewcontroller delegate
    
    func willTransaction() {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    
    //MARK: datasource delegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        viewNoResults?.isHidden = !(list.isEmpty && isDone)
        pageControl?.numberOfPages = list.count
        
        if viewNoResults?.isHidden == false
        {
            self.viewNoResults?.frame = collectionView.frame
            self.collectionView?.backgroundView = self.viewNoResults
        }
        
        
        
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return delegate!.cellWillAppear(collectionView: collectionView, indexPath: indexPath)
    }
    
    
    //MARK: - flow layout delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // this code is only called when we use flow layout
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        
        if isFullScreen
        {
            return collectionView.frame.size
        }

        // this is always true, otherwise we would use freecell layout
        if layout.scrollDirection == UICollectionView.ScrollDirection.horizontal {
            if isCentered
            {

                return CGSize(width: collectionView.frame.width / CGFloat(count), height: layout.itemSize.height)
            }
            else
            {
                return layout.itemSize
            }
            
            
        }
        

        // this code is deprecated due to the use of freecell layout
        layout.minimumLineSpacing = cellPadding
        layout.minimumInteritemSpacing = cellPadding / 2.0

        let cellSpace = layout.minimumInteritemSpacing
        let left = layout.sectionInset.left
        let right = layout.sectionInset.right

        let marginsAndInsets = left + right + 0 + 0 + cellSpace * CGFloat(numberOfColumns - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(numberOfColumns)).rounded(.down)


        return CGSize(width: itemWidth, height: layout.itemSize.height)

    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        
        if !isDone && indexPath.item == list.count-1
        {
            delegate!.loadData(collectionView: collectionView,page: page)
        }
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if selectedItemsPositions.contains(indexPath.item), let index = selectedItemsPositions.firstIndex(of: indexPath.item)
        {
            selectedItemsPositions.remove(at: index)
        }
        else
        {
            selectedItemsPositions.append(indexPath.item)
        }

        if !collectionView.isPagingEnabled{
            selectedItemPosition = selectedItemPosition == indexPath.item ? nil : indexPath.item
            delegate?.onItemSelected(collectionView: collectionView, indexPath: indexPath)
        }
        
        collectionView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2), y: (scrollView.frame.height / 2))
        if let ip = collectionView!.indexPathForItem(at: center) {
            
            if ip.item != selectedItemPosition
            {
                pageControl?.currentPage = ip.item
                if collectionView!.isPagingEnabled{
                    delegate?.onItemSelected(collectionView: collectionView!, indexPath: ip)
                    selectedItemPosition = ip.item
                }
            }
        }
    }
    
    
    
    
}

extension CollectionAdapter: FreeCellLayoutDelegate{
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return delegate?.heightForCell?(collectionView: collectionView, indexPath: indexPath) ?? 0
    }
    
    
}


/// -loadData: get
/// -onItemSelected: load
@objc
protocol CollectionAdapterDelegate {
    
    /// this is loaded when the last list item appears
    func loadData(collectionView:UICollectionView, page:Int)
    
    /// this is called when the item with index path got selected
    func onItemSelected(collectionView:UICollectionView, indexPath:IndexPath)
    
    /// this is called when the 'swipe to refresh' is called
    func onRefresh(collectionView:UICollectionView,refresher:UIRefreshControl?)
    
    /// same as itemWillAppear in classic collection view
    func cellWillAppear(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell
    
    /// this should return the hight for cells (only used for freecell layout)
    @objc optional
    func heightForCell(collectionView:UICollectionView, indexPath:IndexPath)->CGFloat
}

