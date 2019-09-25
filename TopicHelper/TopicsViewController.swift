//
//  AllTopicsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/5/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

enum ListViewType: String {
    case AllTopics
    case FavoriteTopics
    
}

class TopicsViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?
    var usePredicate: Bool = false
    lazy var fetchedResultsController: NSFetchedResultsController<Topic> = {
        let fetchRequest = NSFetchRequest<Topic>()
        
        let entity = Topic.entity()
        fetchRequest.entity = entity
        
        let sort = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedContext,
            sectionNameKeyPath: nil,
            cacheName: "Topics")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    override func loadView() {
        super.loadView()
        self.tableView.rowHeight = 44
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        performFetch()
        self.navigationItem.rightBarButtonItems?.append(self.editButtonItem)
        tableView.backgroundView = UIImageView(image: UIImage(named: "gradiant"))
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

//    override func numberOfSections(in tableView: UITableView) -> Int {
////        return fetchedResultsController.sections!.count
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
//        print("NumberOfObjects: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath) as! TopicCell
        
        let topic = fetchedResultsController.object(at: indexPath)
        
        cell.configure(for: topic)

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
    
    @IBAction func addTopic(_ sender: Any) {
        currentTopic = Topic(context: managedContext)
        performSegue(withIdentifier: "editTopic", sender: nil)
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
            let RandomTopicVC = segue.destination as! RandomTopicViewController
//            RandomTopicVC.currentTopic = currentTopic
            if let ct = currentTopic {
                RandomTopicVC.nextTopics.append(ct)
            }
            RandomTopicVC.managedContext = managedContext
            RandomTopicVC.title = "All Topics"
            RandomTopicVC.viewShouldScroll = false
            RandomTopicVC.backButtonTitle = "Back"
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
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
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
    }
}