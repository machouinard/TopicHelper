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
    
    var managedContext: NSManagedObjectContext!
    var topics = [Topic]()
    var currentTopic: Topic!
    var lastTopic: Topic?
    var topicLocked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        insertStarterTopics()
        populateTopics()
        
        displayNewTopic()
        print(currentTopic.title!)
        
        backgroundLogo.isUserInteractionEnabled = true
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
        backgroundLogo.addGestureRecognizer(tgr)
        
        // Swipe right to show new topic
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(displayNewTopic))
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
            dtvc?.topicDetail = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
            dtvc?.topicTitle = currentTopic.title
            dtvc?.title = currentTopic.title
        }
        
        if segue.identifier == "editTopicDetail" {
            let dtvc = segue.destination as? TopicDetailViewController
            dtvc?.topicDetail = "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
            dtvc?.topicTitle = currentTopic.title
            dtvc?.title = currentTopic.title
            dtvc?.editTopic = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        topicView.centerVertically()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topicView.centerVertically()
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        topics = try! managedContext.fetch(request)
    }
    
    func getRandomTopic() {
        let rnd = Int(arc4random_uniform(UInt32(topics.count)))
        currentTopic = topics[rnd]
        
        if currentTopic.title == lastTopic?.title {
            getRandomTopic()
            
        }
        lastTopic = currentTopic
    }
    
    @objc func displayNewTopic() {
        guard false == topicLocked else {
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

    // MARK:- Starter Topics
    func insertStarterTopics() {
        
        let fetch: NSFetchRequest<Topic> = Topic.fetchRequest()
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // Topics have been added
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
        try! managedContext.save()
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
    
    @IBAction func tappedNewTopic(_ sender: Any) {
        displayNewTopic()
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
