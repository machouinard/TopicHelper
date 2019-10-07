//
//  TopicsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/5/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

/// Differentiate between tabs sharing this view controller
enum ListViewType: Int, CaseIterable, CustomStringConvertible {
    case Favorites
    case AllTopics
    
    var description: String {
        switch self {
            case .Favorites: return "Favorites"
            case .AllTopics: return "All Topics"
        }
    }
    
}

/**
 ListView display of topics
 
 Shared between All & Favorites tab bar items
 */
class TopicsViewController: UITableViewController {
    
    var listType: ListViewType!
    var cacheName: String!
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?
    var usePredicate: Bool = false
    var sectionPath: String?
    lazy var fetchedResultsController: NSFetchedResultsController<Topic> = {
        
        let fetchRequest = NSFetchRequest<Topic>()
        
        let entity = Topic.entity()
        fetchRequest.entity = entity
        
        let sort = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
        //        let sectionSort = NSSortDescriptor(key: "isFavorite", ascending: false)
        
        
        // If this was instantiated from Favorites tab, add predicate
        if ListViewType.Favorites == self.listType {
            fetchRequest.predicate = NSPredicate(format: "isFavorite == YES")
            fetchRequest.sortDescriptors = [sort]
        } else if ListViewType.AllTopics == self.listType {
            let sortChar = NSSortDescriptor(key: "title.firstChar", ascending: true, selector: #selector(NSString.caseInsensitiveCompare))
            fetchRequest.sortDescriptors = [sortChar, sort]
            self.sectionPath = "title.firstChar"
        }
        
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
//            sectionNameKeyPath: #keyPath(Topic.isFavorite),
            sectionNameKeyPath: self.sectionPath,
            cacheName: self.listType.description)
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    override func loadView() {
        super.loadView()
        self.tableView.rowHeight = 44
        
        tableView.sectionIndexColor = .white
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        performFetch()
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        tableView.backgroundView = UIImageView(image: UIImage(named: "gradiant"))
        self.title = self.listType.description
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchedResultsController.delegate = self
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: self.listType.description)
        // Update FRC with latest changes in other views
        self.performFetch()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.fetchedResultsController.delegate = nil
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
//        return 1
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        let title = UILabel(frame: .zero)
        title.tag = 1111
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        
        if ListViewType.AllTopics == self.listType {
            title.text = fetchedResultsController.sections![section].name
        } else {
            if let count = fetchedResultsController.fetchedObjects?.count {
                title.text = "\(count) \(ListViewType.Favorites.description)"
            }
            
        }
        
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return fetchedResultsController.sectionIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        let result = fetchedResultsController.section(forSectionIndexTitle: title, at: index)
                
        return result
    }
    
    /**
     Update count in section header
     
     Called from controllerDidChangeContent to keep count updated
     */
    func updateSectionHeaderCount() {
        var title: String = ""
        // Section header title has tag 1111
        let sectionTitle = view.viewWithTag(1111) as! UILabel
        if let count = fetchedResultsController.fetchedObjects?.count {
            title = "\(count) \(ListViewType.Favorites.description)"
        }
        
        
        sectionTitle.text = title
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]

        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        
        let topic = fetchedResultsController.object(at: indexPath)
        
        cell.configure(for: topic)
        
        // Create button to hold accessory image
        let accButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        // Create accessory image to place in button - withRenderingMode accepts tintColor from IB and/or allows us to set it with code
        let accImage = UIImage(named: "pencil")?.withRenderingMode(.alwaysTemplate)
        accButton.setBackgroundImage(accImage, for: .normal)
        accButton.addTarget(self, action: #selector(editTopic(_:)), for: .touchUpInside)
        // Set tintColor to white.  This overrides tintColor set in IB
        cell.tintColor = .systemGray
        cell.accessoryView = accButton

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTopic = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "showTopic", sender: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let topicToRemove = fetchedResultsController.object(at: indexPath)
        guard editingStyle == .delete else {
            return
        }
        
        managedContext.delete(topicToRemove)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalCoreDataError(error)
        }
        
    }
    
    // MARK: - Actions
    /// Add a topic
    @IBAction func addTopic(_ sender: Any) {
        currentTopic = Topic(context: managedContext)
        // Make sure we set isUsertopic property to true
        currentTopic?.isUserTopic = true
        // If topic is added from Favorites screen, make it a favorite
        if ListViewType.Favorites == self.listType {
            currentTopic?.isFavorite = true
        }
        performSegue(withIdentifier: "editTopic", sender: nil)
    }
    
    /// Segue to edit view from edit button
    @objc func editTopic(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
                
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            currentTopic = fetchedResultsController.object(at: indexPath)
        }
        
        performSegue(withIdentifier: "editTopic", sender: nil)
    }
    
    /**
     Toggle topic isFavorite property
     
     Called when user taps favorite button
     */
    @objc func toggleFavorite(_ sender: UIButton) {
        let buttonPosition = sender.convert(sender.bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            let topic = fetchedResultsController.object(at: indexPath)
            topic.isFavorite = !topic.isFavorite
            do {
                try managedContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTopic" {
            
            let editTopicVC = segue.destination as? EditTopicViewController
            
            // Get indexPath of cell that was tapped
            if nil != sender {
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                    editTopicVC?.currentTopic = fetchedResultsController.object(at: indexPath)
                }
            } else { // If sender is nil this was initiated by clicking the add barButton
                editTopicVC?.currentTopic = currentTopic
            }
            
            editTopicVC?.managedContext = managedContext
        } else if segue.identifier == "showTopic" {
            let TopicVC = segue.destination as! TopicViewController
//            RandomTopicVC.currentTopic = currentTopic
            if let ct = currentTopic {
                TopicVC.nextTopics.append(ct)
            }
            TopicVC.managedContext = managedContext
            TopicVC.title = self.listType.description
            if ListViewType.AllTopics == self.listType {
                TopicVC.viewShouldScroll = false
            }
            TopicVC.backButtonTitle = "Back"
            TopicVC.listType = self.listType
        }
    }
    
}

// MARK: - NSFetchedResultsController Delegate

extension TopicsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath? ) {
        
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .right)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .left)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!)
                as? TopicCell {
                let topic = controller.object(at: indexPath!)
                    as! Topic
                cell.configure(for: topic)
            }
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            print("controller didChange anObject switch default")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
            print("didChange sectionInfo switch default")
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        if ListViewType.Favorites == self.listType {
            self.updateSectionHeaderCount()
        }
    }
}

extension UIImageView {
    /// Set color of UIImage
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

extension NSString{
    /// Return first character of string, capitalized
    ///
    /// Used for SectionIndexTitle
    @objc func firstChar() -> String{
        if self.length == 0 {
            return ""
        }
        return self.substring(to: 1).capitalized
    }
}
