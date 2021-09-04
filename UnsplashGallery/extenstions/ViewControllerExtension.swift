//
//  ViewControllerExtension.swift
//  UnsplashGallery
//
//  Created by Saad on 11/18/18.
//  Copyright © 2018 Saad. All rights reserved.
//

import Foundation
import UIKit
//import PKHUD


extension UIViewController
{
    var contents:UIViewController{
        if let navcon = self as? UINavigationController{
            return navcon.visibleViewController ?? self
        }
        else if let tabcon = self as? UITabBarController
        {
            return tabcon.viewControllers![0].contents
        }
        else
        {
            return self
        }
    }
    
    
     func getViewcontroller<T: UIViewController>() -> T {
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
    
    func getViewcontroller<T: UIViewController>(story:String) -> T {
        
        return UIStoryboard(name: story, bundle: nil).instantiateViewController(withIdentifier: String(describing: T.self)) as! T
    }
    
    func setTransparentBar(isTransparent:Bool) {
        
        let img = isTransparent ? UIImage() : nil
        
        self.navigationController?.navigationBar.setBackgroundImage(img, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = img
        self.navigationController?.navigationBar.isTranslucent = isTransparent
    }
    
    
    private func presentViewController(_ alert: UIAlertController, animated flag: Bool, completion: (() -> Void)?) -> Void {
        var parentController = UIApplication.shared.keyWindow?.rootViewController
              while (parentController?.presentedViewController != nil &&
                  parentController != parentController!.presentedViewController) {
                      parentController = parentController!.presentedViewController
              }
              
        parentController?.present(alert, animated:true, completion:nil)
    }
    
    func showToast(message:String?) {

        guard let msg = message, msg != "" else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .actionSheet)

        alert.view.layer.cornerRadius = 15

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.presentViewController(alert, animated: true, completion: nil)
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    

    //MARK: validate inputs
    func validateInputs(txtFields:[UITextField]) -> Bool {
        var result = true
        for field in txtFields
        {
            if field.text!.isEmpty
            {
                if let placeholder = field.placeholder , !placeholder.contains("*")
                {
                    field.placeholder = placeholder + "*"
                }
                else if field.placeholder == nil
                {
                    field.placeholder = "*"
                }
                field.becomeFirstResponder()
                field.makeToast(NSLocalizedString("This field is required", comment: ""))
                
                field.borderWidth = 0.5
                field.borderColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
                field.cornerRadius = 5
                
                result = false
            }
            else
            {
                field.borderWidth = 0
                field.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                field.cornerRadius = 5
                
            }
        }
        
        return result
    }
    
    func validateInputs(txtFields:[UITextView]) -> Bool {
        var result = true
        for field in txtFields
        {
            if field.text!.isEmpty
            {
                
                field.becomeFirstResponder()
                field.makeToast(NSLocalizedString("This field is required", comment: ""))
                
                field.borderWidth = 0.5
                field.borderColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
                field.cornerRadius = 5
                
                
                result = false
            }
            else
            {
                field.borderWidth = 0.5
                field.borderColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                field.cornerRadius = 5
                
            }
        }
        
        return result
    }
    
   
    public func toast(_ msg:String?) {
        self.view.endEditing(true)
        showToast(message: msg)

    }
    
    

    //MARK: go back
    func goBack()
    {
        if let navigator = navigationController
        {
            navigator.popViewController(animated: true)
        }
        else
        {
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    func goBack<T>(controller:T.Type) where T:UIViewController
    {
        goBack(controller: controller, with: nil)
    }
    
    func goBack<T>(controller:T.Type,with prepare:((T)->Void)?) where T:UIViewController
    {
        if let navigator = navigationController
        {
            
            let index = navigator.viewControllers.firstIndex { (vc) -> Bool in
                return vc.classForCoder == controller.classForCoder()
            }
            
            if let i = index, i < navigator.viewControllers.count
            {
                let vc = navigator.viewControllers[i]
                prepare?(vc as! T)
                navigator.popToViewController(vc, animated: true)
            }
            
        }
        else
        {
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    func goRoot() {
        
        if let navigator = navigationController
        {
            navigator.popToRootViewController(animated: true)
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    func convertDateFormat(date:String) -> Date! {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date)
    }
    
   
       
       func convertTimeFormatter(_ date:Date?) -> String? {
           if let d = date
           {
               let dateFormatter = DateFormatter()
               dateFormatter.dateFormat = "HH:mm"
               return  dateFormatter.string(from: d)
           }
           else {
               return nil
           }
       }
       
    
    func gotoViewController<T>(_ controller:T.Type) where T:UIViewController {
        gotoViewController(controller, story: nil, with: nil)
    }
    
    
    func gotoViewController<T>(_ controller:T.Type,with prepare:((T)->Void)?) where T:UIViewController {
        gotoViewController(controller, story: nil, with: prepare)
    }
    
    func gotoViewController<T>(_ controller:T.Type,story:String?,with prepare:((T)->Void)?) where T:UIViewController {
        var sb = self.storyboard
        if let s = story
        {
            sb = UIStoryboard(name: s, bundle: nil)
            
        }
        
        if let storyboard = sb
        {
            let destination = storyboard.instantiateViewController(withIdentifier: String(describing: controller.classForCoder()))
            
            let target = destination.contents
            prepare?(target as! T)
            
            switch destination
            {
            case is UINavigationController, is UITabBarController:
                present(destination, animated: true, completion: nil)
            
            default:
                if  let navigator = self.navigationController
                {
                    navigator.pushViewController(destination , animated: true)
                }
                else
                {
                    present(destination, animated: true, completion: nil)
                }
            }
            
            
        }
    }
    
    func presentViewController<T>(_ controller:T.Type,story:String?,with prepare:((T)->Void)?) where T:UIViewController {
        var sb = self.storyboard
        if let s = story
        {
            sb = UIStoryboard(name: s, bundle: nil)
            
        }
        
        if let storyboard = sb
        {
            let destination = storyboard.instantiateViewController(withIdentifier: String(describing: controller.classForCoder()))
            
            let target = destination.contents
            prepare?(target as! T)
            
            switch destination
            {
            case is UINavigationController, is UITabBarController:
                present(destination, animated: true, completion: nil)
            
            default:
                present(destination, animated: true, completion: nil)

            }
            
            
        }
    }
    

    func replaceViewController<T>(_ controller:T.Type, with prepare:((T)->Void)?) where T:UIViewController {
        if let navigator = self.navigationController,let storyboard = self.storyboard
        {
            let destination = storyboard.instantiateViewController(withIdentifier: String(describing: controller.classForCoder())).contents
            
            prepare?(destination as! T)
            
            navigator.popViewController(animated: false)
            navigator.setViewControllers([destination], animated: false)
            
        }
    }
    
    func findView<V>(type:V.Type,view:UIView) -> V? where V:UIView {
        for v in view.subviews
        {
            if v is V
            {
                return v as? V
            }
        }
        return nil
    }
    
   
    
    func hideTabAt(index:Int) {
        if let tabBarController = self.tabBarController {
            
            if index < (tabBarController.viewControllers?.count)! {
                var viewControllers = tabBarController.viewControllers
                viewControllers?.remove(at: index)
                tabBarController.viewControllers = viewControllers
                
                
            }
            
        }
    }
    
    
    func convertDateFormater(_ date: Date?) -> String?
    {
        if let d = date
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return  dateFormatter.string(from: d)
        }
        else {
            return nil
        }
        
        
    }
    
    
    func setTitle(title:String?) {
        self.title = title
    }
    
    func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                if #available(iOS 10.0, *) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                } else {
                    application.openURL(phoneCallURL)
                }
            }
        }
    }
    
    func sendEmail(email:String) {
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func goSite(url:String?) {

        if let siteUrl = URL(string: url ?? "")
        {
            UIApplication.shared.openURL(siteUrl)
        }
        
    }
    
    func openFile(url:String?){
        let fileUrl = NSURL.fileURL(withPath: url ?? "")
        if let data = try? Data(contentsOf: fileUrl)
        {
            let vc = UIActivityViewController(
              activityItems: [data],
              applicationActivities: []
            )
            present(vc, animated: true, completion: nil)
        }
    }
    
 
    
    func showShareAlert(quote:String ,url:String) {
        displayShareSheet(shareContent: quote+"\n"+url)
    }
    
    func displayShareSheet(shareContent:String?) {
        if let contents = shareContent {
            let activityViewController = UIActivityViewController(activityItems: [contents as NSString], applicationActivities: nil)
            present(activityViewController, animated: true, completion: {})
        }
        
    }
    
     func setStatusBarBackgroundColor(color:UIColor) {
             
        UIApplication.shared.statusBarView?.backgroundColor = color
        self.navigationController?.navigationBar.backgroundColor = color

    }
       
    func toastActivity(show:Bool)
    {
//        if show
//        {
//            PKHUD.sharedHUD.show()
//        }
//        else
//        {
//            PKHUD.sharedHUD.hide(afterDelay: 1.0)
//        }
    }
        

    
}

extension UIApplication {
    // for status bar background color, ios >= 13.0
    var statusBarView: UIView? {

        if #available(iOS 13.0, *) {
            let tag = 3848245
            let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows.first

            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999

                keyWindow?.addSubview(statusBarView)
            
                return statusBarView
            
            }

        
        } else {
        
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
      
    }
    
}
