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
                                self.currentTopic = nil
                                self.nextTopics.append(first)
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
                        
                    }
                    // This should display topic from nextTopics array or random topic
                    self.displayNextTopic()
                }
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
    var topicTitleLabel: UILabel!
    var topicDetailLabel: UILabel!
    var topicScrollView: UIScrollView!
    var scrollStack: UIStackView!
    var titleCenterY: NSLayoutConstraint!
    var titleTop: NSLayoutConstraint!
    var nextButton: UIButton!
    
    
    override func loadView() {
        super.loadView()
        
        nextButton = self.view.viewWithTag(201) as? UIButton
        
        // MARK: - Constraints - Title
        topicTitleLabel = UILabel(frame: .zero)
        topicTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topicDetailLabel = UILabel(frame: .zero)
        topicDetailLabel.translatesAutoresizingMaskIntoConstraints = false
        topicScrollView = UIScrollView(frame: .zero)
        topicScrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollStack = UIStackView(frame: .zero)
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollStack.addSubview(topicDetailLabel)
        topicScrollView.addSubview(scrollStack)
        
        // Title constraint - centering vertically
        titleCenterY = topicTitleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        view.addSubview(topicTitleLabel)
        view.addSubview(topicScrollView)
        
        // Set and activate title constraints
        topicTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        topicTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        titleCenterY.isActive = true
        topicTitleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        // Title constraint for later use - top 20 below safe area
        titleTop = topicTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        
        topicScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        topicScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        topicScrollView.topAnchor.constraint(equalTo: topicTitleLabel.bottomAnchor, constant: 20).isActive = true
        topicScrollView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -20).isActive = true
        
        scrollStack.leadingAnchor.constraint(equalTo: topicScrollView.leadingAnchor).isActive = true
        scrollStack.trailingAnchor.constraint(equalTo: topicScrollView.trailingAnchor).isActive = true
        scrollStack.topAnchor.constraint(equalTo: topicScrollView.topAnchor).isActive = true
        scrollStack.bottomAnchor.constraint(equalTo: topicScrollView.bottomAnchor).isActive = true
        scrollStack.widthAnchor.constraint(equalTo: topicScrollView.widthAnchor).isActive = true
        scrollStack.heightAnchor.constraint(equalTo: topicDetailLabel.heightAnchor).isActive = true
        
        topicDetailLabel.leadingAnchor.constraint(equalTo: scrollStack.leadingAnchor).isActive = true
        topicDetailLabel.trailingAnchor.constraint(equalTo: scrollStack.trailingAnchor).isActive = true
//        topicDetailLabel.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    
        
        scrollStack.axis = .vertical
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - Label attributes
        topicTitleLabel.numberOfLines = 0
        topicTitleLabel.textColor = .white
        topicTitleLabel.textAlignment = .center
        topicTitleLabel.lineBreakMode = .byWordWrapping
//        topicTitleLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 32.0)
        topicTitleLabel.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 34)
        
        topicDetailLabel.numberOfLines = 0
        topicDetailLabel.textColor = .white
        topicDetailLabel.textAlignment = .center
//        topicDetailLabel.lineBreakMode = .byWordWrapping
//        topicDetailLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 21.0)
        topicDetailLabel.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .subheadline), size: 26)
        
        populateTopics()
        
        if let backText = backButtonTitle {
            let backButton = UIBarButtonItem(title: backText, style: .done, target: self, action: #selector(didTapBack))
            navigationItem.leftBarButtonItems?.insert(backButton, at: 0)
            let sgrBack = UISwipeGestureRecognizer(target: self, action: #selector(dumbFuncToGoBack))
            view.addGestureRecognizer(sgrBack)
        }
        
        backgroundLogo.isUserInteractionEnabled = true
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(self.topicTapGesture))
        tgr.numberOfTapsRequired = 2
        view.addGestureRecognizer(tgr)
        
        if viewShouldScroll {
            // Swipe right to show next topic
            let sgrRight = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
            view.addGestureRecognizer(sgrRight)
            // Swipe left to show previous topics
            let sgrLeft = UISwipeGestureRecognizer(target: self, action: #selector(displayPreviousTopic))
            sgrLeft.direction = UISwipeGestureRecognizer.Direction.left
            view.addGestureRecognizer(sgrLeft)
        }
        
        displayNextTopic()
        
    }
    
    func clearCurrentTopic() {
        currentTopic = nil
        topicTitleLabel.text = ""
        topicDetailLabel.text = ""
    }
    
    // MARK: - GestureRecognizers
    
    @objc func dumbFuncToGoBack() {
        navigationController?.popViewController(animated: true)
    }
    
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
    
    // TODO: Figure out why I decided to this on viewWillAppear instead of didLoad
    override func viewWillAppear(_ animated: Bool) {
        if let topicText = currentTopic?.title {
            topicTitleLabel.text = topicText
        }
        if let detailText = currentTopic?.details {
            topicDetailLabel.text = detailText
        }
    }
    
    /**
     Fetch all topics
     */
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        if topics.isEmpty {
            topics = try! managedContext.fetch(request)
        }
    }
    
    /**
     If we have details to show, move topic title to top of view
     */
    func moveTopic(topic: Topic) {
        if let details = topic.details {
            
            if "" != details {
                NSLayoutConstraint.deactivate([titleCenterY])
                NSLayoutConstraint.activate([titleTop])
                topicDetailLabel.isHidden = false
            } else {
                NSLayoutConstraint.deactivate([titleTop])
                NSLayoutConstraint.activate([titleCenterY])
                topicDetailLabel.isHidden = true
            }
            
        } else {
            NSLayoutConstraint.deactivate([titleTop])
            NSLayoutConstraint.activate([titleCenterY])
            topicDetailLabel.isHidden = true
        }
    }
    
    func displayTopic(sender: String) {
        guard false == topicLocked  && nil != currentTopic else {
            // If we've just deleted last topic, make sure we clear the display
            if topics.isEmpty {
                topicTitleLabel.text = ""
                topicDetailLabel.text = ""
                
                currentTopic = nil
            }
            
            return
        }
        
        // MARK: - Set Favorite
        isFavorite = currentTopic?.isFavorite ?? false
        configureFavoriteButton()
        
//        if let topic = currentTopic {
//            moveTopic(topic: topic)
//        }
        
        // MARK: - Animations
        // Change direction based on swipe
        
        if "previous" == sender {
            topicTitleLabel.center.x += view.bounds.width
            if nil != currentTopic?.details {
                topicDetailLabel.center.x += view.bounds.width
            }
        } else {
            topicTitleLabel.center.x -= view.bounds.width
            if nil != currentTopic?.details {
                topicDetailLabel.center.x -= view.bounds.width
            }
        }
        topicTitleLabel.alpha = 0.0
        if nil != currentTopic?.details {
            topicDetailLabel.alpha = 0.0
        }
        
        
        topicTitleLabel.text = currentTopic?.title
        
        
        topicDetailLabel?.text = currentTopic?.details
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        if "previous" == sender {
                            self.topicTitleLabel.center.x -= self.view.bounds.width
                            self.topicDetailLabel?.center.x -= self.view.bounds.width
                        } else {
                            self.topicTitleLabel.center.x += self.view.bounds.width
                            self.topicDetailLabel?.center.x += self.view.bounds.width
                        }
                        self.topicTitleLabel.alpha = 1.0
                        self.topicDetailLabel?.alpha = 1.0
                        
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
        //        nextTopics.append(prevTopics.removeLast())
        currentTopic = prevTopics.removeLast()
        displayTopic(sender: "previous")
        //        displayNextTopic()
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
            lockImg = "locked"
            navigationItem.rightBarButtonItems?.first?.isEnabled = false
        } else {
            lockImg = "unlocked"
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
        navigationController?.popViewController(animated: true)
    }
    
    func configureFavoriteButton() {
        let btn = navigationItem.leftBarButtonItems?.last
        if isFavorite {
            btn?.image = UIImage(named: "star-fill")
        } else {
            btn?.image = UIImage(named: "star-open")
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

// TODO: do we still need this?
extension UIView {
    func constraint(withIdentifier: String) -> NSLayoutConstraint? {
        return self.constraints.filter { $0.identifier == withIdentifier }.first
    }
}
