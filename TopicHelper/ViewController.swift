//
//  ViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/2/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var topicView: UITextView!
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var topicLock: UIBarButtonItem!
    
    var managedContext: NSManagedObjectContext! {
        didSet {
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedContext, queue: OperationQueue.main) { notification in
                
                if let dictionary = notification.userInfo {
                    if nil != dictionary[NSInsertedObjectsKey] {
                        print("new topic")
                        if !self.topicLocked {
                            let topics = dictionary["inserted"] as! Set<Topic>
                            self.currentTopic = topics.first
                        }
                    } else if nil != dictionary[NSUpdatedObjectsKey] {
                        print("updated topic")
                        if !self.topicLocked {
                            let topics = dictionary["updated"] as! Set<Topic>
                            self.currentTopic = topics.first
                        }
                        
                    } else {
                        print("deleted topic")
                        self.displayNextTopic()
                    }
                }
                self.populateTopics()
            }
        }
    }
    var topics = [Topic]()
    var currentTopic: Topic!
    var lastTopic: Topic?
    var topicLocked: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        insertStarterTopics()
        populateTopics()
        
        displayNextTopic()
        
        backgroundLogo.isUserInteractionEnabled = true
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
        backgroundLogo.addGestureRecognizer(tgr)
        
        // Swipe right to show new topic
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
        backgroundLogo.addGestureRecognizer(sgr)
    }
    
    // MARK: - GestureRecognizers
    
    @objc func topicTapGesture() {
        performSegue(withIdentifier: "showTopicDetail", sender: nil)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTopicDetail" {
            let dtvc = segue.destination as? TopicDetailViewController
            dtvc?.currentTopic = currentTopic
//            dtvc?.title = currentTopic.title
            dtvc?.managedContext = managedContext
        }
        
//        if segue.identifier == "editTopicDetail" {
//            let dtvc = segue.destination as? TopicDetailViewController
//            dtvc?.currentTopic = currentTopic
//            dtvc?.title = currentTopic.title
//            dtvc?.editTopic = true
//            dtvc?.managedContext = managedContext
//        }
    }
    
    override func viewDidLayoutSubviews() {
        topicView.centerVertically()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topicView.text = currentTopic.title
        topicView.centerVertically()
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        topics = try! managedContext.fetch(request)
    }
    
    func getRandomTopic() {
        guard 0 != topics.count else {
            return
        }
        // If we only have 1 topic, return it
        if (1 == topics.count) {
            currentTopic = topics[0]
            return
        }
        
        let rnd = Int(arc4random_uniform(UInt32(topics.count)))
        
        currentTopic = topics[rnd]
        
        if currentTopic.title == lastTopic?.title {
            getRandomTopic()
            topicView.alpha = 1.0
        }
        lastTopic = currentTopic
    }
    
    @objc func displayNextTopic() {
        guard false == topicLocked  && 0 != topics.count else {
            return
        }
        
        topicView.center.x -= view.bounds.width
        topicView.alpha = 0.0
        
        getRandomTopic()
        topicView.text = currentTopic.title
        topicView.centerVertically()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        self.topicView.center.x += self.view.bounds.width
                        self.topicView.alpha = 1.0
        },
                       completion: nil
        )
    }

    
    @IBAction func toggleTopicLock(_ sender: Any) {
        topicLocked = !topicLocked
        
        var lockImg = String()
        
        switch topicLocked {
        case true:
            lockImg = "lock"
            break
        default:
            lockImg = "unlock"
            break
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
