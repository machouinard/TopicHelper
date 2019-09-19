//
//  AllTopicsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/5/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class AllTopicsViewController: UITableViewController {
    
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?
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
            sectionNameKeyPath: "isFavorite",
            cacheName: "Topics")
        
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
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
        prepare(for: UIStoryboardSegue(identifier: "showSingleTopic", source: self, destination: TopicDetailViewController.init()), sender: nil)
        performSegue(withIdentifier: "showSingleTopic", sender: nil)
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
        performSegue(withIdentifier: "editSingleTopic", sender: nil)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSingleTopic" {
            
            let topicDetailVC = segue.destination as? TopicDetailViewController
            
            // Get indexPath of cell that was tapped
            if nil != sender {
                if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                    topicDetailVC?.currentTopic = fetchedResultsController.object(at: indexPath)
                }
            } else {
                topicDetailVC?.currentTopic = currentTopic
            }
            topicDetailVC?.title = "Edit Topic"
            topicDetailVC?.editTopic = true
            topicDetailVC?.managedContext = managedContext
        } else if segue.identifier == "showSingleTopic" {
            let dtvc = segue.destination as? TopicDetailViewController
            dtvc?.currentTopic = currentTopic
            dtvc?.managedContext = managedContext
        }
    }

}

extension AllTopicsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("** controllerWillChangeContent ***")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath? ) {
        
        print("fetched objects: \(String(describing: self.fetchedResultsController.fetchedObjects))")
        print("AllTopics indexPath: \(String(describing: indexPath))")
        print("AllTopics newIndexPath: \(String(describing: newIndexPath))")
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)
                as? TopicCell {
                let topic = controller.object(at: indexPath!)
                    as! Topic
                cell.configure(for: topic)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        @unknown default:
            print("controller didChange anObject switch default")
        }
        print("fetched objects: \(String(describing: self.fetchedResultsController.fetchedObjects))")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
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
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
