//
//  EditTopicViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/4/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class EditTopicViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var topicDetailView: UITextView!
    @IBOutlet weak var topicTitleView: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?
    var topicLocked: Bool = false
    
    override func loadView() {
        super.loadView()
        
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Swipe left to show return to previous screen
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(returnToPreviousScreen))
//        sgr.direction = UISwipeGestureRecognizer.Direction.left
        view.addGestureRecognizer(sgr)
        
        topicTitleView.text = currentTopic?.title
        topicTitleView.delegate = self
        
        topicDetailView.text = currentTopic?.details
        
        if let title = currentTopic?.title, !title.isEmpty {
            topicDetailView.becomeFirstResponder()
        } else {
            topicTitleView.becomeFirstResponder()
        }
        
    }
    
    // Rollback unsaved managedObjectContext changes when hitting back button
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        // If parent is nil, back button was used and we need to dump the topic that wasn't saved
        if nil == parent {
            rollbackMangedObject()
            setPreviousControllerCurrentTopic()
        }
    }
    
    // Rollback unsaved managedObjectContext changes when swiping left to return from detail screen
    @objc func returnToPreviousScreen() {
        rollbackMangedObject()
        navigationController?.popViewController(animated: true)
    }
    
    // Rollback managedObjectContext changes
    func rollbackMangedObject() {
        if managedContext.hasChanges {
            managedContext.rollback()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        done()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        done()
        
        return false
    }
    
    func done() {
        
        guard nil != currentTopic, "" != topicTitleView.text else {
            return
        }
        
        if topicTitleView.isFirstResponder {
            topicTitleView.resignFirstResponder()
        }
        if topicDetailView.isFirstResponder {
            topicDetailView.resignFirstResponder()
        }
        
        do {
            currentTopic!.title = topicTitleView.text
            currentTopic!.details = topicDetailView.text
            
            try managedContext.save()
            
//            setPreviousControllerCurrentTopic()
            
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            fatalCoreDataError(error)
        }
        
    }
    
    func setPreviousControllerCurrentTopic() {
        let nc = self.parent as! UINavigationController
        if let tvc = nc.getPreviousViewController() as? TopicViewController {
            tvc.currentTopic = nil
            tvc.nextTopics.append(currentTopic!)
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

extension UINavigationController {
    func getPreviousViewController() -> UIViewController? {
        let count = viewControllers.count
        guard count > 1 else { return nil }
        return viewControllers[count - 2]
    }
}
