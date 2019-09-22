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
    
    @IBOutlet weak var topicView: UITextView!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var topicLock: UIBarButtonItem!
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedContext, queue: OperationQueue.main) { notification in
                
                // Update our topics with latest changes
                if let dictionary = notification.userInfo {
                    // New topic is inserted empty, then updated.  We only deal with updated and deleted.
                    if nil != dictionary[NSUpdatedObjectsKey] {
                            let topics = dictionary["updated"] as! Set<Topic>
                            if let first = topics.first {
                                if  nil == self.topics.firstIndex(of: first) {
                                    // no index means this is a new topic and needs to be added to our array
                                    self.topics.append(first)
                                }
                                // If topic is not locked, make this the current topic
                                if !self.topicLocked {
                                    self.currentTopic = first
                                }
                            }
                    } else if nil != dictionary[NSDeletedObjectsKey] {
                        let topics = dictionary["deleted"] as! Set<Topic>
                        if let first = topics.first {
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
        // Do any additional setup after loading the view.
        insertStarterTopics()
        
        populateTopics()
        
        displayRandomTopic()
        
        backgroundLogo.isUserInteractionEnabled = true
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
        backgroundLogo.addGestureRecognizer(tgr)
        
        // Swipe right to show new topic
        let sgrRight = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
        backgroundLogo.addGestureRecognizer(sgrRight)
        
        let sgrLeft = UISwipeGestureRecognizer(target: self, action: #selector(displayPreviousTopic))
        sgrLeft.direction = UISwipeGestureRecognizer.Direction.left
        backgroundLogo.addGestureRecognizer(sgrLeft)
        
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
        topicView.centerVertically()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let topicText = currentTopic?.title {
            topicView.text = topicText
            topicView.centerVertically()
        }
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        topics = try! managedContext.fetch(request)
//        print("topics populated: \(topics)")
    }
    
    func displayTopic() {
        guard false == topicLocked  && nil != currentTopic else {
            return
        }
        
        topicView.center.x -= view.bounds.width
        topicView.alpha = 0.0
        
        topicView.text = currentTopic?.title
        topicView.centerVertically()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        self.topicView.center.x += self.view.bounds.width
                        self.topicView.alpha = 1.0
        },
                       completion: nil
        )
        
    }
    
    func displayRandomTopic() {
        
        guard false == topicLocked && !topics.isEmpty else {
            
//            if topics.isEmpty {
//                topicView.text = ""
//                currentTopic = nil
//            }
            
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
    
    // MARK:- Starter Topics
    func insertStarterTopics() {
        
        let fetch: NSFetchRequest<Topic> = Topic.fetchRequest()
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // Topics have already been added
            return
        }
        let path = Bundle.main.path(forResource: "topics10", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Topic", in: managedContext)!
            let topic = Topic(entity: entity, insertInto: managedContext)
            let topicDict = dict as! [String: Any]
            topic.title = topicDict["title"] as? String
            topic.details = topicDict["details"] as? String
            topic.isFavorite = topicDict["isFavorite"] as! Bool
        }
        do {
            try managedContext.save()
        } catch  {
            fatalCoreDataError(error)
        }
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
