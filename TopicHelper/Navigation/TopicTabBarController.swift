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
    lazy var coreDataStack = CoreDataStack(modelName: "TopicHelper")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.managedContext = coreDataStack.managedContext
        if let tabViewControllers = self.viewControllers {
            var navController = tabViewControllers[2] as! UINavigationController
            let allTopicsVC = navController.viewControllers.first as! TopicsViewController
            allTopicsVC.managedContext = coreDataStack.managedContext
            allTopicsVC.listType = ListViewType.AllTopics
            navController = tabViewControllers[0] as! UINavigationController
            let randomVC = navController.topViewController as! RandomTopicViewController
            randomVC.managedContext = coreDataStack.managedContext
            navController = tabViewControllers[1] as! UINavigationController
            let faveVC = navController.topViewController as! TopicsViewController
            faveVC.managedContext = coreDataStack.managedContext
            faveVC.listType = ListViewType.Favorites
        }
        
        listenForFatalCoreDataNotifications()

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
    
    // MARK:- Helper methods
        func listenForFatalCoreDataNotifications() {
            // 1
            NotificationCenter.default.addObserver(
                forName: CoreDataSaveFailedNotification,
                object: nil, queue: OperationQueue.main,
                using: { notification in
                    // 2
                    let message = """
    There was a fatal error in the app and it cannot continue.
    Press OK to terminate the app. Sorry for the inconvenience.
    """
                    // 3
                    let alert = UIAlertController(
                        title: "Internal Error", message: message,
                        preferredStyle: .alert)
                    // 4
                    let action = UIAlertAction(title: "OK",
                                               style: .default) { _ in
                                                let exception = NSException(
                                                    name: NSExceptionName.internalInconsistencyException,
                                                    reason: "Fatal Core Data error", userInfo: nil)
                                                exception.raise()
                    }
                    alert.addAction(action)
                    
                    self.present(alert, animated: true,
                                          completion: nil)
            })
        }

    
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
            topic.details = topicDict["description"] as? String
            topic.isFavorite = topicDict["isFavorite"] as! Bool
        }
        do {
            try managedContext.save()
        } catch  {
            fatalCoreDataError(error)
        }
    }


}
