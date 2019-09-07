//
//  AllTopicsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/5/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class AllTopicsViewController: UITableViewController, TopicDetailViewControllerDelegate {
    
    var topics = [Topic]()
    var managedContext: NSManagedObjectContext!
    var currentTopic: Topic?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        populateTopics()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func populateTopics() {
        let request: NSFetchRequest<Topic> = Topic.fetchRequest()
        topics = try! managedContext.fetch(request)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        print("number of sections")
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        print("number of rows")
        return topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topicCell", for: indexPath)

        let txt = topics[indexPath.row].title
//        print("txt: \(txt!)")
        cell.textLabel?.text = txt

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentTopic = topics[indexPath.row]
        prepare(for: UIStoryboardSegue(identifier: "editSingleTopic", source: self, destination: TopicDetailViewController.init()), sender: nil)
        performSegue(withIdentifier: "editSingleTopic", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let topicToRemove = topics[indexPath.row]
        guard editingStyle == .delete else {
            return
        }
        
        managedContext.delete(topicToRemove)
        
        do {
            try managedContext.save()
            topics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch let error as NSError {
            print("Deleting error: \(error) description: \(error.userInfo)")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editSingleTopic" {
            let dtvc = segue.destination as? TopicDetailViewController
            dtvc?.currentTopic = currentTopic
            dtvc?.title = currentTopic?.title
            dtvc?.editTopic = true
            dtvc?.managedContext = managedContext
        }
    }
    
    // MARK: - Topic Detail View Delegate
    func TopicDetailViewDidEditTopic(_ controller: TopicDetailViewController, topic: Topic) {
        // Topic has been edited in TopicDetailViewController - need to update our table
        tableView.reloadData()
        currentTopic = topic
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
