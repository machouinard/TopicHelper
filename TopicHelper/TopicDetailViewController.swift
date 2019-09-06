//
//  TopicDetailViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/4/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

protocol TopicDetailViewControllerDelegate: class {
    func topicDetailViewControllerDidModifyTopic(_ controller: TopicDetailViewController)
}

class TopicDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var topicDetailView: UITextView!
    @IBOutlet weak var topicTitleView: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var currentTopic: Topic!
    var editTopic: Bool = false
    var managedContext: NSManagedObjectContext!
    weak var delegate: TopicDetailViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        topicTitleView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if editTopic {
            topicTitleView.becomeFirstResponder()
//            self.navigationItem.backBarButtonItem = UIBarButtonItem.init(title: "ASklsdn", style: .plain, target: nil, action: nil)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        topicDetailView.text = currentTopic?.details
        topicDetailView.isEditable = editTopic
        topicTitleView.text = currentTopic?.title
        topicTitleView.isEnabled = editTopic
        
        doneButton.isEnabled = editTopic
        topicDetailView.centerVertically()
        
        
    }
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        // If editing, save
        done()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        
        return false
    }
    
    @objc func done() {
        
        guard topicTitleView.text != "" else {
            return
        }
        
        if nil == currentTopic {
            currentTopic = Topic(context: managedContext)
        }
        
        topicTitleView.resignFirstResponder()
        topicDetailView.resignFirstResponder()
        if editTopic {
            currentTopic.title = topicTitleView.text
            currentTopic.details = topicDetailView.text
            try! managedContext.save()
        }
        navigationController?.popViewController(animated: true)
        delegate?.topicDetailViewControllerDidModifyTopic(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        scrollView.contentInset.bottom = keyboardFrame.height
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
