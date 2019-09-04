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
    
    var managedContext: NSManagedObjectContext!
    var topics = [Topic]()
    var currentTopic: Topic!
    var lastTopic: Topic?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        insertStarterTopics()
        populateTopics()
        
        displayNewTopic()
        print(currentTopic.title!)
        
        backgroundLogo.isUserInteractionEnabled = true
        
//        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.displayNewTopic))
//        backgroundLogo.addGestureRecognizer(tgr)
        
        // Swipe right to show new topic
        let sgr = UISwipeGestureRecognizer(target: self, action: #selector(displayNewTopic))
        backgroundLogo.addGestureRecognizer(sgr)
    }
    
    override func viewDidLayoutSubviews() {
        topicView.centerVertically()
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        topics = try! managedContext.fetch(request)
    }
    
    func getRandomTopic() {
        let rnd = Int(arc4random_uniform(UInt32(topics.count)))
        currentTopic = topics[rnd]
    }
    
    @objc func displayNewTopic() {
        getRandomTopic()
        topicView.text = currentTopic.title
        topicView.centerVertically()
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
