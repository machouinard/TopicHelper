//
//  TopicTabBarController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/21/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

class TopicTabBarController: UITabBarController {
    
    var managedContext: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()

        insertStarterTopics()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK:- Starter Topics
    func insertStarterTopics() {
        
//        print(applicationDocumentsDirectory)
        NSFetchedResultsController<Topic>.deleteCache(withName: "Topics")
        
        let fetch: NSFetchRequest<Topic> = Topic.fetchRequest()
        let count = try! managedContext.count(for: fetch)
        
        if count > 0 {
            // Topics have already been added
            return
        }
                
        let path = Bundle.main.path(forResource: "topics", ofType: "plist")
        let dataArray = NSArray(contentsOfFile: path!)!
        
        for dict in dataArray {
            let entity = NSEntityDescription.entity(forEntityName: "Topic", in: managedContext)!
            let topic = Topic(entity: entity, insertInto: managedContext)
            let topicDict = dict as! [String: Any]
            topic.title = topicDict["title"] as? String
            topic.details = topicDict["details"] as? String
            topic.isFavorite = topicDict["isFavorite"] as! Bool
        }
        do {
            try managedContext.save()
        } catch  {
            fatalCoreDataError(error)
        }
    }


}
