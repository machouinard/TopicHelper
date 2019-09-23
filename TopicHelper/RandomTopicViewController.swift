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
    @IBOutlet weak var isFavoriteButton: UIBarButtonItem!
    
    
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
//                                    self.nextTopics.append(first)
                                }
                            }
                    } else if nil != dictionary[NSDeletedObjectsKey] {
                        let deletedTopics = dictionary["deleted"] as! Set<Topic>
                        if let first = deletedTopics.first {
                            // Remove topic from prev/next arrays
                            self.prevTopics.removeAll{ $0 == first }
                            self.nextTopics.removeAll{ $0 == first }
                            if let ind = self.topics.firstIndex(of: first) {
                                // Remove topic from array
                                self.topics.remove(at: ind)
                            }
                            if self.currentTopic == first {
                                self.clearCurrentTopic()
                            }
                        }
                        // This should display topic from nextTopics array or random topic
                        self.displayNextTopic()
                    }
                }
//                if nil != self.currentTopic {
//                    self.lastTopic = self.currentTopic // Make sure we track last topic
//                }
                
            }
        }
    }
    var topics = [Topic]()
    var currentTopic: Topic?
    var lastTopic: Topic?
    var topicLocked: Bool = false
    var prevTopics = [Topic]()
    var nextTopics = [Topic]()
    var isFavorite: Bool = false
    var viewShouldScroll: Bool = true
    var backButtonTitle: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateTopics()
        
        if nil == currentTopic {
            setRandomTopic()
        }
        
        if let backText = backButtonTitle {
            let backButton = UIBarButtonItem(title: backText, style: .done, target: self, action: #selector(didTapBack))
            navigationItem.leftBarButtonItems?.insert(backButton, at: 0)
        }
        
        displayTopic(sender: "viewDidLoad")
        
        backgroundLogo.isUserInteractionEnabled = true
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
        backgroundLogo.addGestureRecognizer(tgr)
        
        if viewShouldScroll {
            // Swipe right to show new topic
            let sgrRight = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
            view.addGestureRecognizer(sgrRight)
            
            let sgrLeft = UISwipeGestureRecognizer(target: self, action: #selector(displayPreviousTopic))
            sgrLeft.direction = UISwipeGestureRecognizer.Direction.left
            backgroundLogo.addGestureRecognizer(sgrLeft)
        }
        
    }
    
    func clearCurrentTopic() {
        currentTopic = nil
        topicTitleLabel.text = ""
        topicDetailLabel.text = ""
    }
    
    // MARK: - GestureRecognizers
    
    @objc @IBAction func topicTapGesture() {
        performSegue(withIdentifier: "editDisplayedTopic", sender: nil)
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDisplayedTopic" {
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
    
    func displayTopic(sender: String) {
        guard false == topicLocked  && nil != currentTopic else {
            if topics.isEmpty {
                topicTitleLabel.text = ""
                topicDetailLabel.text = ""
                
                currentTopic = nil
            }
            
            return
        }
        
        isFavorite = currentTopic?.isFavorite ?? false
        configureFavoriteButton()
        
        // MARK: - Animations
        // Change direction based on swipe
        if "previous" == sender {
            topicTitleLabel.center.x += view.bounds.width
            topicDetailLabel.center.x += view.bounds.width
        } else {
            topicTitleLabel.center.x -= view.bounds.width
            topicDetailLabel.center.x -= view.bounds.width
        }
        topicTitleLabel.alpha = 0.0
        topicDetailLabel.alpha = 0.0
        

        topicTitleLabel.text = currentTopic?.title

        topicDetailLabel.text = currentTopic?.details

        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        if "previous" == sender {
                            self.topicTitleLabel.center.x -= self.view.bounds.width
                            self.topicDetailLabel.center.x -= self.view.bounds.width
                        } else {
                            self.topicTitleLabel.center.x += self.view.bounds.width
                            self.topicDetailLabel.center.x += self.view.bounds.width
                        }
                        self.topicTitleLabel.alpha = 1.0
                        self.topicDetailLabel.alpha = 1.0
                        
        },
                       completion: nil
        )
        
    }
    
    func setRandomTopic() {
        
        guard false == topicLocked && !topics.isEmpty else {
            return
        }
        
        if (1 == topics.count) {// If we only have 1 topic, return it
            currentTopic = topics.first
            
        } else {
            
            let randomTopic = topics.randomElement()
            
            if currentTopic == randomTopic {
                setRandomTopic()
                return
            }
            
            currentTopic = randomTopic
        }
    }
    
    @objc func displayNextTopic() {
        guard false == topicLocked  && 0 != topics.count else {
            return
        }
        
        saveCurrentTopicPrevious()

        if nextTopics.isEmpty {
            setRandomTopic()
        } else {
            currentTopic = nextTopics.removeLast()
        }
        
        displayTopic(sender: "next")
    }
    
    @objc func displayPreviousTopic() {
        guard !prevTopics.isEmpty else {
            return
        }
        
        saveCurrentTopicNext()
        currentTopic = prevTopics.removeLast()
        displayTopic(sender: "previous")
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
            navigationItem.rightBarButtonItems?.first?.isEnabled = false
        } else {
            lockImg = "unlock"
            navigationItem.rightBarButtonItems?.first?.isEnabled = true
        }
        
        topicLock.image = UIImage(named: lockImg)
        
    }
    
    @IBAction func tappedNextTopic(_ sender: Any) {
        displayNextTopic()
    }
    
    @IBAction func didTapFavorite(_ sender: Any) {
        guard nil != currentTopic else {
            return
        }
        
        isFavorite = !isFavorite
        currentTopic?.isFavorite = isFavorite
        
        do {
            try managedContext.save()
        } catch {
            fatalCoreDataError(error)
        }
        
        
        configureFavoriteButton()
    }
    
    @objc func didTapBack() {
        print("ASDFASFDASFDASDF")
        navigationController?.popViewController(animated: true)
    }
    
    func configureFavoriteButton() {
        let btn = navigationItem.leftBarButtonItems?.last
        if isFavorite {
            btn?.image = UIImage(named: "fave-fill")
        } else {
            btn?.image = UIImage(named: "fave")
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
