//
//  TableAdapter.swift
//
//  Created by Saad on 11/15/18.
//  Copyright © 2018 Saad. All rights reserved.
//

import Foundation
import UIKit

class TableAdapter: NSObject,UITableViewDelegate, UITableViewDataSource {
    
    
    private var tableView:UITableView?
    
    private var delegate:TableAdapterDelegate?
    private var nibList = [String:UINib]()
    private var addedSectionCells = [String:[UITableViewCell]]()
    
    
    private var originalData = [String:[Any]]()//without filtering
    private var sectionData = [String:[Any]]()//could be filtered
    private var sectionSelection = [String:[Bool]]()
    private var selectedItem = [String:Int]()
    private var selectedItems = [String:[Int]]()
    private var sectionPage = [String:Int]()//for pagenation
    private var sectionPageLength = [String:Int]()
    private var sectionDone = [String:Bool]()
    private var sectionTitle = [Int:String]()
    private var sectionIndexCounter = 0
    
    var singleSelection = true//allow multible selection?
    var showHeaders = true//show sections headers?
    var showNoResults = true//show no results text on no data?
    var deletable = false
    var viewNoResults:UIView?

    var onScroll:((Bool,Int)->Void)?
    var condition:((Any)->Bool) = {item in return true}
    
    var refresher:UIRefreshControl!
    
    init(tableView:UITableView, delegate:TableAdapterDelegate) {
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView = tableView
        self.delegate = delegate
        
        self.refresher = UIRefreshControl()//swip to refresh
        self.tableView!.alwaysBounceVertical = true
        self.refresher.tintColor = #colorLiteral(red: 0.1427750289, green: 0.4550954103, blue: 0.733171463, alpha: 1)
        self.refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        if #available(iOS 10.0, *) {
            self.tableView!.refreshControl = self.refresher
        } else {
            self.tableView?.addSubview(self.refresher)
        }
        
        
        self.tableView?.separatorStyle = .none
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Results"
        
        self.viewNoResults = label
        
    }
    
    
    //MARK: functions
    
    @objc func loadData() {
        delegate?.onRefresh(tableView: tableView!, refresher: refresher)
    }
    
    func setPageLength(pageLength:Int) {
        for key in sectionData.keys
        {
            sectionPageLength[key] = pageLength
        }
    }
    
    func setPageLength(title:String,pageLength:Int) {
        if sectionPageLength.keys.contains(title)
        {
            sectionPageLength.updateValue(pageLength, forKey: title)
        }
        
    }
    
    func filter(title:String, condition:@escaping (Any)->Bool) {
        self.condition = condition
        sectionData[title]! = originalData[title]!.filter(condition)
        self.reloadData()
    }
    
    func filter(condition:@escaping (Any)->Bool) {
        filter(title: "", condition: condition)
    }
    
    func initiate() {
        if sectionTitle.isEmpty
        {
            initiate(lst: [Any]())
            return
        }
        
        sectionTitle.values.forEach { (title) in
            resetSection(title: title)
            delegate?.loadData(tableView: tableView!,section: title, page: 1)
        }
    }
    
    func initiate(title:String) {
        resetSection(title: title)
        let page = sectionPage[title]!
        delegate?.loadData(tableView: tableView!, section: title, page: page)
    }
    
    
    func initiate(lst:[Any]?) {
        initiate(title: "", lst: lst)
        
    }
    
    func initiate(title:String, lst:[Any]?) {
        
        resetSection(title: title)
        addPage(title: title, lst: lst)
        let page = sectionPage[title]!
        delegate?.loadData(tableView: tableView!,section: title, page: page)
        
    }
    
    func reloadData() {
        tableView?.reloadData()
    }
    
    private func addSection(title:String) {
        if !sectionTitle.values.contains(title)
        {
            sectionData.updateValue([Any](), forKey: title)
            originalData.updateValue([Any](), forKey: title)
            
            sectionSelection.updateValue([Bool](), forKey: title)
            
            sectionPage.updateValue(1, forKey: title)
            sectionPageLength.updateValue(0, forKey: title)
            sectionDone.updateValue(false, forKey: title)
            sectionTitle.updateValue(title, forKey: sectionIndexCounter)
            sectionIndexCounter+=1
        }
    }
    
    func addPage(lst:[Any]?) {
        addPage(title: "", lst: lst)
    }
    
    
    /**
    ** add data to the section with pagenation logic if needed
    **/
    func addPage(title:String, lst:[Any]?) {
        if let data = lst, data.count > 0{
            addSection(title: title)
            if sectionPageLength[title]! < data.count
            {sectionPageLength[title] = data.count}
            
            sectionDone[title] = data.count < 10//sectionPageLength[title]!
            
            originalData[title]!+=data
            
            sectionData[title]! = originalData[title]!.filter(condition)
            sectionSelection[title]!+=Array(repeating: false, count: data.count)
            sectionPage[title]!+=1
            tableView?.reloadData()
            
            refresher.endRefreshing()
        }
        else
        {
            sectionDone[title] = true
            tableView?.reloadData()
            refresher.endRefreshing()

        }
        
    }
    
    func addOnce(title:String, lst:[Any]?) {
        addPage(title: title, lst: lst)
        sectionDone[title] = true
        
    }
    
    func addOnce(lst:[Any]?) {
        addPage(title: "", lst: lst)
        sectionDone[""] = true
        
    }
    
    func getIndexPath(cell:UITableViewCell) -> IndexPath? {
        return tableView?.indexPath(for: cell)
    }
    
    func reset() {
        
        sectionIndexCounter = 0
        
        originalData = [String:[Any]]()
        sectionData = [String:[Any]]()
        
        sectionSelection = [String:[Bool]]()
        sectionPage = [String:Int]()
        sectionPageLength = [String:Int]()
        sectionDone = [String:Bool]()
        sectionTitle = [Int:String]()
        
        tableView?.reloadData()
        refresher.endRefreshing()
    }
    
    func resetSection(title:String) {
        
        addSection(title: title)
        
        originalData[title] = [Any]()
        sectionData[title] = [Any]()
        
        sectionSelection[title] = [Bool]()
        sectionPage[title] = 1
        sectionDone[title] = false
        sectionPageLength[title] = 0
        
    }
    
    func isEmpty() -> Bool {
        
        for key in sectionData.keys
        {
            if let data = sectionData[key], data.count > 0
            {
                return false
            }
        }
        
        return true
    }
    
    func isDone() -> Bool {
        
        for key in sectionData.keys
        {
            if let data = sectionDone[key], data == false
            {
                return false
            }
        }
        
        return true
    }
    
    
    func updateItem(indexPath:IndexPath ,newItem:Any)
    {
        let title = getSectionTitle(of: indexPath)
        var data = sectionData[title!]
        data![indexPath.item] = newItem
        initiate(title: title!, lst: data)
    }
    
    func updateItem(cell:UITableViewCell ,newItem:Any)
    {
        if let indexPath = tableView?.indexPath(for: cell)
        {
            let title = getSectionTitle(of: indexPath)
            var data = sectionData[title!]
            data![indexPath.item] = newItem
            
        }
    }
    
    
    
    func updateList(title:String,update:(Any)->Any) {
        
        if var lst = sectionData[title]
        {
            for i in lst.indices
            {
                lst[i] = update(lst[i])
            }
            sectionData.updateValue(lst, forKey: title)
        }
        
    }
    
    func removeItem(at indexPath:IndexPath) {
        let title = getSectionTitle(of: indexPath)
        
        removeItem(title: title, index: indexPath.item)
    }
    
    func removeItem(title:String?,index:Int) {
        if sectionTitle.values.contains(title ?? "")
        {
            var data = sectionData[title!]
            var sectionCells = addedSectionCells[title!] ?? [UITableViewCell]()
            
            if index < sectionCells.count
            {
                sectionCells.remove(at: index)
            }
            else if index < data!.count
            {
                data!.remove(at: index)
                
            }
            
            addedSectionCells[title!] = sectionCells
            initiate(title: title!, lst: data)
        }
        
    }
    
    
    func getList() -> [Any]? {
        return sectionData.first?.value
    }
    
    func getSelection() -> [Bool]? {
        return sectionSelection.first?.value
    }
    
    func getSelectedList() -> [Any] {
        var result = [Any]()
        let data = getList()
        if let lst = getSelection()
        {
            for index in lst.indices
            {
                if lst[index]
                {
                    result+=[data![index]]
                }
            }
        }
        
        return result
    }
    
    func getList(title:String) -> [Any]? {
        return sectionData[title]
    }
    
    func getSelection(title:String) -> [Bool]? {
        return sectionSelection[title]
    }
    
    
    
    func getSelectedList(title:String) -> [Any] {
        var result = [Any]()
        let data = getList(title:title)
        if let lst = getSelection(title:title)
        {
            for index in lst.indices
            {
                if lst[index]
                {
                    result+=[data![index]]
                }
            }
        }
        
        return result
    }
    
    func getItem(at:IndexPath) -> Any? {
        
        if let title = sectionTitle[at.section], let data = sectionData[title], data.count > at.item
        {
            return data.isEmpty ? nil : data[at.item]
        }
        else
        {
            return nil
        }
        
    }
    
    func getSelection(at:IndexPath) -> Bool {
        
        if let title = sectionTitle[at.section], let data = sectionSelection[title], data.count > at.item
        {
            return data[at.item]
        }
        else
        {
            return false
        }
        
    }
    
    func getSelectedItem() -> Any? {
        return getSelectedList().first
    }
    
    func getSelectedItem(title:String) -> Any? {
        return getSelectedList(title: title).first
    }
    
    func getSectionTitle(of:IndexPath) -> String? {
        return sectionTitle[of.section]
    }
    
    func removeSection(title:String) {
        
        //        if sectionTitle.values.contains(title)
        //        {
        //            sectionData.removeValue(forKey: title)
        //            sectionSelection.removeValue(forKey: title)
        //
        //            sectionPage.removeValue(forKey: title)
        //            sectionPageLength.removeValue(forKey: title)
        //            sectionDone.removeValue(forKey: title)
        //
        //
        //            sectionTitle.removeValue(forKey: title)
        //            sectionIndexCounter-=1
        //        }
        
        if sectionTitle.values.contains(title)
        {
            originalData.removeValue(forKey: title)
            sectionData.removeValue(forKey: title)
            
            sectionSelection.removeValue(forKey: title)
            sectionPage.removeValue( forKey: title)
            sectionPageLength.removeValue( forKey: title)
            sectionDone.removeValue( forKey: title)
            for key in sectionTitle.keys
            {
                if let t = sectionTitle[key], t == title
                {
                    
                    
                    for k in key+1 ..< sectionTitle.count
                    {
                        let value = sectionTitle[k]
                        sectionTitle.updateValue(value!, forKey: k-1)
                    }
                    
                    
                    sectionTitle.removeValue( forKey: sectionTitle.count-1)
                    
                    sectionIndexCounter-=1
                    
                }
                
            }
        }
    }

    func moveSection(title:String, position:Int) {
        
        if sectionTitle.values.contains(title) && position < sectionTitle.count
        {

            for key in sectionTitle.keys
            {
                if let t = sectionTitle[key], t == title
                {
                    if position > key
                    {
                        for k in key + 1 ..< position + 1
                        {
                            let value = sectionTitle[k]
                            sectionTitle.updateValue(value!, forKey: k-1)
                        }
                        sectionTitle.updateValue(title, forKey: position)
                    }
                    else if position < key
                    {
                        for k in (position+1 ..< key+1).reversed()
                        {
                            let value = sectionTitle[k-1]
                            sectionTitle.updateValue(value!, forKey: k)
                        }
                        sectionTitle.updateValue(title, forKey: position)
                    }
                }
                
            }
            reloadData()
            
        }
    }
    
    func removeAllSections() {
        if !sectionTitle.isEmpty
        {
            for val in sectionTitle.values
            {
                removeSection(title: val)
            }
        }
    }
    
    func addCells(cells:[UITableViewCell]) {
        addCells(section: "", cells: cells)
    }
    

    /**
    ** add static cells to the sections
    **/
    func addCells(section:String, cells:[UITableViewCell])
    {
        addedSectionCells.updateValue(cells, forKey: section)
        let dummy = [Bool](repeating: false, count: cells.count)
        sectionSelection[section]?.insert(contentsOf: dummy, at: 0)
        reloadData()
    }
    
    func getAllSectionsDataCount()->Int
    {
        var result = 0
        for section in sectionData.keys
        {
            result += (sectionData[section]?.count ?? 0)
        }
        
        return result
    }
    
    
    
    func endRefreshing() {
        refresher.endRefreshing()
    }
    
    /**
	** easily get cell from nib file 
    **/
    
    func getNibCell<C>(cellClass:C.Type,indexPath:IndexPath) -> C where C:UITableViewCell{
        
        let id = String(describing: cellClass.classForCoder())
        
        if nibList[id] == nil {
            let nib = UINib(nibName: id, bundle: nil)
            nibList.updateValue(nib, forKey: id)
            tableView?.register(nib, forCellReuseIdentifier: id)
        }
        //        let cell = Bundle.main.loadNibNamed("GoodCollectionViewCell", owner: self, options: nil)?[0] as! GoodCollectionViewCell
        return tableView?.dequeueReusableCell(withIdentifier: id, for: indexPath) as! C
        
    }
    
    func getView<V>(viewClass:V.Type) -> V where V:UIView {
        let id = String(describing: viewClass.classForCoder())
        let view = Bundle.main.loadNibNamed(id, owner: self, options: nil)?[0] as! UIView
        return view as! V
    }
    
    
    //MARK: datasource delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return sectionData.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = sectionTitle[section]
        
        if section == 0 && title == ""
        {
            return nil
        }
        return title
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        viewNoResults?.isHidden = !(isEmpty() && showNoResults && isDone())
        if viewNoResults?.isHidden == false
        {
            self.viewNoResults?.frame = tableView.frame
            self.tableView?.backgroundView = self.viewNoResults
        }
        
        let k = sectionTitle[section]
        let addedSectionCellsCount = addedSectionCells[k ?? ""]?.count ?? 0
        
        return sectionData[k!]!.count + addedSectionCellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = getSectionTitle(of: indexPath) ?? ""
        let cells = addedSectionCells[section] ?? [UITableViewCell]()
        
        if indexPath.item < cells.count
        {
            return cells[indexPath.item]
        }
        
        return delegate!.cellWillAppear(tableView: tableView, indexPath: IndexPath(item: indexPath.item-cells.count, section: indexPath.section))
    }
    
    
    //MARK: layout delegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let t = sectionTitle[indexPath.section], let d = sectionData[t], indexPath.item == d.count-1, !sectionDone[t]!
        {
            delegate?.loadData(tableView: tableView, section: t, page: sectionPage[t]!)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = getSectionTitle(of: indexPath) ?? ""
        let cells = addedSectionCells[section] ?? [UITableViewCell]()
        
        guard indexPath.item >= cells.count else
        {
            return
        }
        
        
        let title = getSectionTitle(of: indexPath)
        var data = sectionSelection[title!]
        let item = !data![indexPath.item]
        if singleSelection
        {
            data = Array(repeating: false, count: data!.count)
            data![indexPath.item] = item
        }
        else
        {
            data![indexPath.item] = item
        }
        sectionSelection[title!] = data
        
        delegate?.onItemSelected(tableView: tableView,indexPath: IndexPath(item: indexPath.item-cells.count, section: indexPath.section))

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let title = sectionTitle[section]
        return delegate?.viewForHeader?(tableView: tableView, section: title)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showHeaders ? UITableView.automaticDimension : 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
//            tableView.deleteRows(at: [indexPath], with: .fade)
            delegate?.onItemDeleted?(tableView: tableView, indexPath: indexPath)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return deletable
    }
    
    
    
    
    
    // we set a variable to hold the contentOffSet before scroll view scrolls
    var lastContentOffset: CGFloat = 0
    
    // this delegate is called when the scrollView (i.e your UITableView) will start scrolling
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    // while scrolling this delegate is being called so you may now check which direction your scrollView is being scrolled to
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset < scrollView.contentOffset.y) {
            onScroll?(true,Int(scrollView.contentOffset.y))
        } else if (self.lastContentOffset > scrollView.contentOffset.y) {
            onScroll?(true,Int(scrollView.contentOffset.y))
        } else {
            // didn't move
        }
    }
}

@objc
protocol TableAdapterDelegate {
    func loadData(tableView:UITableView,section:String, page:Int)
    func onItemSelected(tableView:UITableView, indexPath:IndexPath)
    func onRefresh(tableView:UITableView,refresher:UIRefreshControl)
    
    @objc
    optional func viewForHeader(tableView:UITableView,section:String?) -> UIView?
    
    @objc
    optional func onItemDeleted(tableView:UITableView, indexPath:IndexPath)
    
    func cellWillAppear(tableView:UITableView, indexPath:IndexPath) -> UITableViewCell
}
