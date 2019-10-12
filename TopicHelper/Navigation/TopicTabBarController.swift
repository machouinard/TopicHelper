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

  //    var managedContext: NSManagedObjectContext!
  lazy var coreDataStack = CoreDataStack(modelName: "TopicHelper")

  override func viewDidLoad() {
    super.viewDidLoad()

    let settingsItem = UITabBarItem()
    settingsItem.title = "Settings"
    settingsItem.image = UIImage(named: "gear")
    let settingsVC = SettingsViewController()
    settingsVC.managedContext = coreDataStack.managedContext
    let settingsNC = UINavigationController()
    settingsNC.tabBarItem = settingsItem
    settingsNC.viewControllers.append(settingsVC)
    self.viewControllers?.append(settingsNC)

    //        self.managedContext = coreDataStack.managedContext
    // swiftlint:disable force_cast
    if let tabViewControllers = self.viewControllers {
      var navController = tabViewControllers[2] as! UINavigationController
      let allTopicsVC = navController.viewControllers.first as! TopicsViewController
      allTopicsVC.managedContext = coreDataStack.managedContext
      allTopicsVC.listType = ListViewType.allTopics
      navController = tabViewControllers[0] as! UINavigationController
      let topicVC = navController.topViewController as! TopicViewController
      topicVC.managedContext = coreDataStack.managedContext
      navController = tabViewControllers[1] as! UINavigationController
      let faveVC = navController.topViewController as! TopicsViewController
      faveVC.managedContext = coreDataStack.managedContext
      faveVC.listType = ListViewType.favorites
    }

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    // swiftlint:enable force_cast
    appDelegate.managedContext = coreDataStack.managedContext

    listenForFatalCoreDataNotifications()

    insertStarterTopics(force: false)
  }
  
  // MARK: - Helper methods

  func listenForFatalCoreDataNotifications() {
    // 1
    _ = NotificationCenter.default.addObserver(
      forName: coreDataSaveFailedNotification,
      object: nil, queue: OperationQueue.main,
      using: { _ in
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

  // MARK: - Starter Topics

  func insertStarterTopics(force: Bool) {
    // swiftlint:disable force_cast
    let completed: Bool = UserDefaults.standard.bool(forKey: "topicsInserted")
    if completed { return }

    //        print(applicationDocumentsDirectory)
    NSFetchedResultsController<Topic>.deleteCache(withName: "Topics")

    let fetch: NSFetchRequest<Topic> = Topic.fetchRequest()
    var count: Int = 0
    do {
      count = try coreDataStack.managedContext.count(for: fetch)
    } catch {

    }

    if count > 0 && !force {
      // Topics have already been added
      return
    }
    // Start activityIndicator
    let path = Bundle.main.path(forResource: "topics", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!

    for dict in dataArray {
      let entity = NSEntityDescription.entity(forEntityName: "Topic", in: coreDataStack.managedContext)!
      let topic = Topic(entity: entity, insertInto: coreDataStack.managedContext)
      let topicDict = dict as! [String: Any]
      topic.title = topicDict["title"] as? String
      topic.details = topicDict["description"] as? String
      topic.isFavorite = topicDict["isFavorite"] as! Bool
    }
    do {
      try coreDataStack.managedContext.save()
      UserDefaults.standard.set(true, forKey: "topicsInserted")
      // stop activityIndicator
    } catch {
      fatalCoreDataError(error)
    }
  }
  // swiftlint:enable force_cast

}
