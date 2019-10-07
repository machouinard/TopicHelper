//
//  TopicViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/2/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class TopicViewController: UIViewController {
    
    @IBOutlet weak var backgroundLogo: UIImageView!
    @IBOutlet weak var topicLock: UIBarButtonItem!
    @IBOutlet weak var isFavoriteButton: UIBarButtonItem!
    var listType: ListViewType!
    var managedContext: NSManagedObjectContext!
    var cacheName: String?

    lazy var fetchedResultsController: NSFetchedResultsController<Topic> = {
                
        let fetchRequest = NSFetchRequest<Topic>()
        
        let entity = Topic.entity()
        fetchRequest.entity = entity
        
        // If this was instantiated from Favorites tab, add predicate
        if ListViewType.Favorites == self.listType {
            fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
        }
        
        let sort = NSSortDescriptor(key: "title", ascending: true)
        
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        
        if let type = self.listType {
            self.cacheName = type.description
        } else {
            self.cacheName = ListViewType.AllTopics.description
        }
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: self.cacheName)
        
        return fetchedResultsController
    }()
    var currentTopic: Topic?
    var lastTopic: Topic?
    var topicLocked: Bool = false
    var prevTopics = [Topic]()
    var nextTopics = [Topic]()
    var isFavorite: Bool = false
    var viewShouldScroll: Bool = true
    var backButtonTitle: String?
    var topicTitleLabel: UILabel!
    var topicDetailTextView: UILabel!
    var topicScrollView: UIScrollView!
    var scrollStack: UIStackView!
    var titleCenterY: NSLayoutConstraint!
    var titleTop: NSLayoutConstraint!
    var nextButton: UIButton!
    var lpr: UILongPressGestureRecognizer!
    
    
    override func loadView() {
        super.loadView()
        
        
        
        nextButton = self.view.viewWithTag(201) as? UIButton
        
        // MARK: - Constraints - Title
        topicTitleLabel = UILabel(frame: .zero)
        topicTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        topicDetailTextView = UILabel(frame: .zero)
        topicDetailTextView.translatesAutoresizingMaskIntoConstraints = false
        topicScrollView = UIScrollView(frame: .zero)
        topicScrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollStack = UIStackView(frame: .zero)
        scrollStack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollStack.addSubview(topicDetailTextView)
        topicScrollView.addSubview(scrollStack)
        
        // Title constraint - centering vertically
        titleCenterY = topicTitleLabel.centerYAnchor.constraint(equalTo: self.backgroundLogo.centerYAnchor)
        
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
        scrollStack.heightAnchor.constraint(equalTo: topicDetailTextView.heightAnchor).isActive = true
        
        topicDetailTextView.leadingAnchor.constraint(equalTo: scrollStack.leadingAnchor).isActive = true
        topicDetailTextView.trailingAnchor.constraint(equalTo: scrollStack.trailingAnchor).isActive = true
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
        
        topicDetailTextView.numberOfLines = 0
        topicDetailTextView.textColor = .white
        topicDetailTextView.textAlignment = .center
//        topicDetailLabel.lineBreakMode = .byWordWrapping
//        topicDetailLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 21.0)
        topicDetailTextView.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .subheadline), size: 26)
        
        
        if let backText = backButtonTitle {
            let backButton = UIBarButtonItem(title: backText, style: .done, target: self, action: #selector(didTapBack))
            navigationItem.leftBarButtonItems?.insert(backButton, at: 0)
            if ListViewType.AllTopics == self.listType {
                let sgrBack = UISwipeGestureRecognizer(target: self, action: #selector(dumbFuncToGoBack))
                view.addGestureRecognizer(sgrBack)
            }
            nextButton.isHidden = true
        }
        
        backgroundLogo.isUserInteractionEnabled = true
        
        // Long press gesture recognizer
        lpr = UILongPressGestureRecognizer(target: self, action: #selector(self.editTopicGesture))
        lpr.minimumPressDuration = 0.7
        view.addGestureRecognizer(lpr)
        
        if viewShouldScroll {
            // Swipe right to show next topic
            let sgrRight = UISwipeGestureRecognizer(target: self, action: #selector(displayNextTopic))
            view.addGestureRecognizer(sgrRight)
            // Swipe left to show previous topics
            let sgrLeft = UISwipeGestureRecognizer(target: self, action: #selector(displayPreviousTopic))
            sgrLeft.direction = UISwipeGestureRecognizer.Direction.left
            view.addGestureRecognizer(sgrLeft)
        }
        
        
        
    }
    
    // TODO: Figure out why I decided to this on viewWillAppear instead of didLoad
    override func viewWillAppear(_ animated: Bool) {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: self.cacheName)
        self.performFetch()
        
        displayNextTopic()
    }
    
    // MARK:- Helper methods
    func performFetch() {

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    func clearCurrentTopic() {
        currentTopic = nil
        topicTitleLabel.text = ""
        topicDetailTextView.text = ""
    }
    
    // MARK: - GestureRecognizers
    
    @objc func dumbFuncToGoBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didTapEditButton(_ sender: Any) {
        performSegue(withIdentifier: "editDisplayedTopic", sender: nil)
    }
    
    @objc @IBAction func editTopicGesture(sender: UIGestureRecognizer) {
        
        if sender.state == UIGestureRecognizer.State.began {
            performSegue(withIdentifier: "editDisplayedTopic", sender: nil)
        }
    }
    
    // MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDisplayedTopic" {
            let etVC = segue.destination as? EditTopicViewController
            
            if nil == currentTopic {
                currentTopic = Topic(context: managedContext)
            }
            
            etVC?.currentTopic = currentTopic
            etVC?.managedContext = managedContext
            etVC?.topicLocked = topicLocked
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
                topicDetailTextView.isHidden = false
            } else {
                NSLayoutConstraint.deactivate([titleTop])
                NSLayoutConstraint.activate([titleCenterY])
                topicDetailTextView.isHidden = true
            }
            
        } else {
            NSLayoutConstraint.deactivate([titleTop])
            NSLayoutConstraint.activate([titleCenterY])
            topicDetailTextView.isHidden = true
        }
    }
    
    func displayTopic(sender: String) {
        guard false == topicLocked  && nil != currentTopic else {
            // If we've just deleted last topic, make sure we clear the display
            if nil == fetchedResultsController.fetchedObjects {
                self.clearCurrentTopic()
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
                topicDetailTextView.center.x += view.bounds.width
            }
        } else {
            topicTitleLabel.center.x -= view.bounds.width
            if nil != currentTopic?.details {
                topicDetailTextView.center.x -= view.bounds.width
            }
        }
        topicTitleLabel.alpha = 0.0
        if nil != currentTopic?.details {
            topicDetailTextView.alpha = 0.0
        }
        
        
        topicTitleLabel.text = currentTopic?.title
        
        
        topicDetailTextView?.text = currentTopic?.details
        
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseIn],
                       animations: {
                        if "previous" == sender {
                            self.topicTitleLabel.center.x -= self.view.bounds.width
                            self.topicDetailTextView?.center.x -= self.view.bounds.width
                        } else {
                            self.topicTitleLabel.center.x += self.view.bounds.width
                            self.topicDetailTextView?.center.x += self.view.bounds.width
                        }
                        self.topicTitleLabel.alpha = 1.0
                        self.topicDetailTextView?.alpha = 1.0
                        
        },
                       completion: nil
        )
        
    }
    
    func setRandomTopic() {
        if nil == fetchedResultsController.fetchedObjects {
            self.clearCurrentTopic()
            return
        }
        guard false == topicLocked && !fetchedResultsController.fetchedObjects!.isEmpty else {
            clearCurrentTopic()
            return
        }
        
        if (1 == fetchedResultsController.fetchedObjects?.count) {// If we only have 1 topic, return it
            currentTopic = fetchedResultsController.fetchedObjects?.first
            
        } else {
            
            let count = UInt32(fetchedResultsController.fetchedObjects!.count)
            let index = Int(arc4random_uniform(count))
//            let randomTopic = topics.randomElement()
            let randomTopic = fetchedResultsController.fetchedObjects?[index]
            
            
            

            
            if currentTopic == randomTopic {
                setRandomTopic()
                return
            }
            
            currentTopic = randomTopic
        }
    }
    
    @objc func displayNextTopic() {
        if nil == fetchedResultsController.fetchedObjects {
            clearCurrentTopic()
            return
        }
        guard false == topicLocked && !fetchedResultsController.fetchedObjects!.isEmpty else {
            clearCurrentTopic()
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
