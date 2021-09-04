//
//  SearchBarView.swift
//
//  Created by Saad on 2/19/21.
//  Copyright © 2021 Saad. All rights reserved.
//

import UIKit

@IBDesignable
class MySearchBarView: UIView {

    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var btnImage: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    let imagePicker = FilePicker()
    var delegate: MySearchBarDelegate?
    var loading = false

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
        contentView?.prepareForInterfaceBuilder()
    }
    
    override func awakeFromNib() {
        commonInit()
    
    }
    
    @IBInspectable
    var isLoading: Bool {
        get {
            return !loadingIndicator.isHidden
        }
        set {
            loadingIndicator.isHidden = !newValue
            btnSearch.isHidden = newValue
            loading = newValue
        }
    }
    
    var text: String? {
        get {
            return txtSearch.text
        }
        set {
            txtSearch.text = newValue
        }
    }
    
    
    func commonInit() {
      
        let bundle = Bundle(for: MySearchBarView.self)
        bundle.loadNibNamed(String(describing: MySearchBarView.self), owner: self, options: nil)
        
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        loadingIndicator.isHidden = !loading
        btnSearch.isHidden = loading
        
    }
    

    func pickImageClicked()
    {
        btnImage.sendActions(for: .touchUpInside)
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        delegate?.onSearchHit(field: txtSearch)
        
    }
    
    @IBAction func btnPickImage(_ sender: Any) {

        delegate?.onImagePressed()

    }

    @IBAction func txtSearchDidChange(_ sender: UITextField) {
        delegate?.onTextChange(field: sender)
        
    }


}

protocol MySearchBarDelegate {
    func onTextChange(field:UITextField)
    func onImagePressed()
    func onSearchHit(field:UITextField)
}

extension UIView {
    func findViewController() -> UIViewController? {
        if let nextResponder = self.next as? UIViewController {
            return nextResponder
        } else if let nextResponder = self.next as? UIView {
            return nextResponder.findViewController()
        } else {
            return nil
        }
    }
}
