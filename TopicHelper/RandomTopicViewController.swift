//
//  RandomTopicViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/2/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class RandomTopicViewController: UIViewController {
    
    @IBOutlet weak var topicTitleLabel: UILabel!
    @IBOutlet weak var topicDetailLabel: UILabel!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var topicLock: UIBarButtonItem!
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedContext, queue: OperationQueue.main) { notification in
                
                // Update our topics with latest changes
                if let dictionary = notification.userInfo {
                    // New topic is inserted empty, then updated.  We only deal with updated and deleted.
                    if nil != dictionary[NSUpdatedObjectsKey] {
                            let updatedTopics = dictionary["updated"] as! Set<Topic>
                            if let first = updatedTopics.first {
                                if  nil == self.topics.firstIndex(of: first) {
                                    // no index means this is a new topic and needs to be added to our array
                                    self.topics.append(first)
                                }
                                // If topic is not locked, make this the current topic
                                if !self.topicLocked {
                                    self.currentTopic = first
                                    self.nextTopics.append(first)
                                }
                            }
                    } else if nil != dictionary[NSDeletedObjectsKey] {
                        let deletedTopics = dictionary["deleted"] as! Set<Topic>
                        if let first = deletedTopics.first {
                            if let ind = self.topics.firstIndex(of: first) {
                                self.topics.remove(at: ind)
                            }
                        }
                        // currentTopic should be the one we just deleted - need to change that
                        self.displayRandomTopic()
                    }
                }
                self.lastTopic = self.currentTopic // Make sure we track last topic
                self.displayNextTopic()
            }
        }
    }
    var topics = [Topic]()
    var currentTopic: Topic?
    var lastTopic: Topic?
    var topicLocked: Bool = false
    var prevTopics = [Topic]()
    var nextTopics = [Topic]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateTopics()
        
        if nil == currentTopic {
            displayRandomTopic()
        } else {
            displayTopic()
        }
        
        backgroundLogo.isUserInteractionEnabled = true
        
//        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
//        backgroundLogo.addGestureRecognizer(tgr)
        
        // Swipe right to show new topic
        let sgrRight = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
        view.addGestureRecognizer(sgrRight)
        
        let sgrLeft = UISwipeGestureRecognizer(target: self, action: #selector(displayPreviousTopic))
        sgrLeft.direction = UISwipeGestureRecognizer.Direction.left
//        backgroundLogo.addGestureRecognizer(sgrLeft)
        
    }
    
    // MARK: - GestureRecognizers
    
    @objc func topicTapGesture() {
        performSegue(withIdentifier: "showTopicDetail", sender: nil)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTopicDetail" {
            let dtvc = segue.destination as? EditTopicViewController
            
            if nil == currentTopic {
                currentTopic = Topic(context: managedContext)
            }
            
            dtvc?.currentTopic = currentTopic
            dtvc?.managedContext = managedContext
            dtvc?.topicLocked = topicLocked
        }
    }
    
    override func viewDidLayoutSubviews() {
//        topicView.centerVertically()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let topicText = currentTopic?.title {
            topicTitleLabel.text = topicText
        }
        if let detailText = currentTopic?.details {
            topicDetailLabel.text = detailText
        }
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        if topics.isEmpty {
            topics = try! managedContext.fetch(request)
        }
//        print("topics populated: \(topics)")
    }
    
    func displayTopic() {
        guard false == topicLocked  && nil != currentTopic else {
            return
        }
        
        topicTitleLabel.center.x -= view.bounds.width
        topicTitleLabel.alpha = 0.0
        
        if let title = currentTopic?.title {
            topicTitleLabel.text = title
        }
        if let details = currentTopic?.details {
            topicDetailLabel.text = details
        }
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        self.topicTitleLabel.center.x += self.view.bounds.width
                        self.topicTitleLabel.alpha = 1.0
        },
                       completion: nil
        )
        
    }
    
    func displayRandomTopic() {
        
        guard false == topicLocked && !topics.isEmpty else {
            
            if topics.isEmpty {
                topicTitleLabel.text = ""
                currentTopic = nil
            }
            
            return
        }
        
        if (1 == topics.count) {// If we only have 1 topic, return it
            currentTopic = topics.first
            
        } else {
            //        let randomIndex = Int.random(in: 0 ..< topics.count)
            
            let randomTopic = topics.randomElement()
            
            if currentTopic == randomTopic {
                displayRandomTopic()
                return
            }
            
            currentTopic = randomTopic
        }
        

        
        displayTopic()
    }
    
    @objc func displayNextTopic() {
        guard false == topicLocked  && 0 != topics.count else {
            return
        }
        
        saveCurrentTopicPrevious()

        if nextTopics.isEmpty {
            displayRandomTopic()
        } else {
            currentTopic = nextTopics.removeLast()
        }
        
        displayTopic()
    }
    
    @objc func displayPreviousTopic() {
        guard !prevTopics.isEmpty else {
            return
        }
        
        saveCurrentTopicNext()
        print("PrevTopics: \(prevTopics)")
        print("CurrentTopic: \(String(describing: currentTopic))")
        print("****************")
        currentTopic = prevTopics.removeLast()
        print("PrevTopics: \(prevTopics)")
        print("CurrentTopic: \(String(describing: currentTopic))")
        displayTopic()
    }
    
    func saveCurrentTopicPrevious() {
        if let cTopic = currentTopic {
            prevTopics.append(cTopic)
        }
        if prevTopics.count > 5 {
            prevTopics.removeFirst()
        }
    }
    
    func saveCurrentTopicNext() {
        if let cTopic = currentTopic {
            nextTopics.append(cTopic)
        }
        if nextTopics.count > 5 {
            nextTopics.removeFirst()
        }
    }

    // MARK: - Actions
    @IBAction func toggleTopicLock(_ sender: Any) {
        topicLocked = !topicLocked
        
        var lockImg = String()
        
        if topicLocked {
            lockImg = "lock"
        } else {
            lockImg = "unlock"
        }
        
        topicLock.image = UIImage(named: lockImg)
        
    }
    
    @IBAction func tappedNextTopic(_ sender: Any) {
        displayNextTopic()
    }
}

// MARK:- Extensions
extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
}
