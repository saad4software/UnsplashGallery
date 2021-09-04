
import UIKit

class AbstractViewController: UIViewController {
    
   
    let notificationCenter = UNUserNotificationCenter.current()
    
    lazy var apiCalls:ApiCalls = ApiCalls.getInstance()
    lazy var pickerDictionary = [UIDatePicker:UITextField]()
    
    var delegateList = [ViewControllerDelegate]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apiCalls.delegate = self

        //show only back arrow, without previous screen title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    

    
    func sendLocalNotification(title: String, body: String) {
        
        let content = UNMutableNotificationContent()
        let userActions = "User Actions"
        
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = userActions
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        

    }
    
    func addDelegate(delegate:ViewControllerDelegate) {
        delegateList.append(delegate)
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if view != nil
        {
            delegateList.forEach({ (delegate) in
                delegate.willTransaction()
            })
            
        }
    }
    
    
    

}

extension AbstractViewController: ApiCallsDelegate{
    
    @objc
    func showProgress(show: Bool) {
        toastActivity(show: show)
    }
    
    func toastError(msg: String?) {
        toast(msg)
    }
}



protocol ViewControllerDelegate {
    func willTransaction()
}
