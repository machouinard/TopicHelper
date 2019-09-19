//
//  TopicDetailViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/4/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class TopicDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var topicDetailView: UITextView!
    @IBOutlet weak var topicTitleView: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var editTopic: Bool = false
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?
    var topicLocked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        topicTitleView.delegate = self
        
        // If topic title is empty, it's new - go straight to editing
        if nil == currentTopic?.title {
            editCurrentTopic()
        } else {
            showCurrentTopic()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard !topicLocked else {
            return
        }
        
        if editTopic || nil == currentTopic {
            topicTitleView.becomeFirstResponder()
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(done))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: nil, action: #selector(editCurrentTopic))
        }
        
    }
    
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        done()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        
        return false
    }
    
    func showCurrentTopic() {
        topicTitleView.text = currentTopic?.title
        topicTitleView.isEnabled = editTopic
        topicDetailView.text = currentTopic?.details
        topicDetailView.isEditable = editTopic
        topicDetailView.centerVertically()
    }
    
    @objc func editCurrentTopic() {
        title = "Edit Topic"
        editTopic = true
        topicTitleView.isEnabled = true
        topicTitleView.becomeFirstResponder()
        topicDetailView.isEditable = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(done))
    }
    
    @objc func done() {
        topicTitleView.resignFirstResponder()
        topicDetailView.resignFirstResponder()
        
        guard nil != currentTopic else {
            return
        }
        
        if editTopic {
            
            do {
                currentTopic!.title = topicTitleView.text
                currentTopic!.details = topicDetailView.text
                
                try managedContext.save()
                navigationController?.popViewController(animated: true)
            } catch let error as NSError {
                fatalCoreDataError(error)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Keyboard functions
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

}
