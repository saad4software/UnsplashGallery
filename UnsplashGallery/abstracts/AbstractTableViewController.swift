//
//  AbstractTableViewController.swift
//  UnsplashGallery
//
//  Created by Saad on 1/3/19.
//

import UIKit
import Kingfisher

class AbstractTableViewController: UITableViewController {


    
    lazy var apiCalls:ApiCalls = ApiCalls.getInstance()
    lazy var pickerDictionary = [UIDatePicker:UITextField]()

    var onBack:(()->Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiCalls.delegate = self
        tableView.keyboardDismissMode = .onDrag
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    
    func setOnBack(onBack:@escaping ()->Void) {
        self.onBack = onBack
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(AbstractTableViewController.onBackPressed(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
    }
   
    
    @objc
    func onBackPressed(sender:UITabBarItem) {
        onBack?()
    }
 
    
    
    func datePicker(textField:UITextField,mode:UIDatePicker.Mode) {
        let pickerView = UIDatePicker()
        pickerView.datePickerMode = mode
        pickerView.addTarget(self, action: #selector(AbstractViewController.updateField(_:)), for: .valueChanged)
        
        pickerDictionary.updateValue(textField, forKey: pickerView)
        
        textField.inputView = pickerView
        updateField(pickerView)
    }
    
    @objc func updateField(_ sender: UIDatePicker) {
        
        pickerDictionary[sender]?.text = sender.datePickerMode == .date ? convertDateFormater(sender.date) : convertTimeFormatter(sender.date)

    }
    
    

}

extension AbstractTableViewController: ApiCallsDelegate{
    func showProgress(show: Bool) {
        toastActivity(show: show)
        
    }
    
    func toastError(msg: String?) {
        toast(msg)
    }
}
