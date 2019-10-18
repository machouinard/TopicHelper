//
//  SettingsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/6/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController {

  var managedContext: NSManagedObjectContext!
  var tableView: UITableView!
  var settingsInfoHeader: SettingsInfoHeader!
  var headerLabel: UILabel!
  var queue: DispatchQueue?

  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    headerLabel = view.viewWithTag(401) as? UILabel
    if nil != headerLabel {
      headerLabel.text = ""
      headerLabel.textColor = .systemGreen
      headerLabel.font = .boldSystemFont(ofSize: 14)
    }

  }

  // MARK: - Helper Functions

  func configureTableView() {
    tableView = UITableView()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = 60

    tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
    view.addSubview(tableView)
    tableView.frame = view.frame

    let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
    settingsInfoHeader = SettingsInfoHeader(frame: frame)
    tableView.tableHeaderView = settingsInfoHeader
    tableView.tableFooterView = UIView()
  }

  func configureUI() {
    configureTableView()

    navigationController?.navigationBar.prefersLargeTitles = true
    navigationController?.navigationBar.isTranslucent = false
    navigationController?.navigationBar.barStyle = .default
    //        navigationController?.navigationBar.barTintColor = .systemBlue
    navigationItem.title = "Settings"
  }

  @objc func modifyTopics(action: String) {
    queue = DispatchQueue(label: "me.chouinard.topic-settings")
    headerLabel.text = ""
    // Start activityIndicator
    NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: ListViewType.allTopics.description)
    NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: ListViewType.favorites.description)

    var actionPredicate: NSPredicate?

    switch action {
    case TopicActions.defaultDelete.description:
      actionPredicate = NSPredicate(format: "isUserTopic == NO")
      queue?.async {
        self.deleteTopics(predicate: actionPredicate!)
        DispatchQueue.main.async {
          self.updateHeaderlabel(label: "Default topics were deleted")
        }
      }
    case TopicActions.defaultRestore.description:
      actionPredicate = NSPredicate(format: "isUserTopic == NO")
      queue?.async {
        self.deleteTopics(predicate: actionPredicate!)
      }
      queue?.async {
        self.restoreDefaultTopics()
        DispatchQueue.main.async {
          self.updateHeaderlabel(label: "Default topics were restored")
        }
      }
    case TopicActions.userDelete.description:
      actionPredicate = NSPredicate(format: "isUserTopic == YES")
      queue?.async {
        self.deleteTopics(predicate: actionPredicate!)
        DispatchQueue.main.async {
          self.updateHeaderlabel(label: "Your topics were deleted")
        }
      }
    case TopicActions.globalDelete.description:
      queue?.async {
        self.deleteTopics(predicate: nil)
        DispatchQueue.main.async {
          self.updateHeaderlabel(label: "All topics were deleted")
        }
      }
    case TopicActions.clearFavorites.description:
      actionPredicate = NSPredicate(format: "isFavorite == YES")
      queue?.async {
        self.clearFavorites(predicate: actionPredicate!)
        DispatchQueue.main.async {
          self.updateHeaderlabel(label: "All favorites were cleared")
        }
      }
    default:
      return
    }

  }

  func clearFavorites(predicate: NSPredicate) {

    let updateRequest = NSBatchUpdateRequest(entityName: "Topic")
    updateRequest.propertiesToUpdate = ["isFavorite": "NO"]
    updateRequest.predicate = predicate
    updateRequest.resultType = .updatedObjectsCountResultType

    do {
      try managedContext.execute(updateRequest)
      removeSpinner()
    } catch {
      fatalCoreDataError(error)
    }

  }

  func deleteTopics(predicate: NSPredicate?) {
    let fetch = NSFetchRequest<Topic>()
    let entity = Topic.entity()
    fetch.entity = entity

    if nil != predicate {
      fetch.predicate = predicate
    }

    // swiftlint:disable force_cast
    let request = NSBatchDeleteRequest(fetchRequest: fetch as! NSFetchRequest<NSFetchRequestResult>)

    do {
      try managedContext.execute(request)
      removeSpinner()
    } catch {
      fatalCoreDataError(error)
    }
    // swiftlint:enable force_cast
  }

  func updateHeaderlabel(label: String) {
    headerLabel = view.viewWithTag(401) as? UILabel
    headerLabel?.text = label
  }

  func restoreDefaultTopics() {
    let path = Bundle.main.path(forResource: "topics", ofType: "plist")
    let dataArray = NSArray(contentsOfFile: path!)!

    // swiftlint:disable force_cast
    for dict in dataArray {
      let entity = NSEntityDescription.entity(forEntityName: "Topic", in: managedContext)!
      let topic = Topic(entity: entity, insertInto: managedContext)
      let topicDict = dict as! [String: Any]
      topic.title = topicDict["title"] as? String
      topic.details = topicDict["description"] as? String
      topic.isFavorite = topicDict["isFavorite"] as! Bool
    }
    // swiftlint:enable force_cast
    do {
      try managedContext.save()
      removeSpinner()
    } catch {
      fatalCoreDataError(error)
    }
  }

}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {

  func numberOfSections(in tableView: UITableView) -> Int {
    return SettingsSection.allCases.count
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .systemBlue

    let title = UILabel()
    title.font = UIFont.boldSystemFont(ofSize: 16)
    title.textColor = .white
    view.addSubview(title)
    title.translatesAutoresizingMaskIntoConstraints = false
    title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
    title.text = SettingsSection(rawValue: section)?.description

    return view
  }

  //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
  //        return 30
  //    }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    guard let section = SettingsSection(rawValue: section) else {
      return 0
    }

    switch section {
    case .defaults:
      return DefaultOptions.allCases.count
    case .user:
      return UserOptions.allCases.count
    case .global:
      return GlobalOptions.allCases.count
    }

  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // swiftlint:disable force_cast
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
    // swiftlint:enable force_cast
    guard let section = SettingsSection(rawValue: indexPath.section) else {
      return cell
    }

    switch section {
    case .defaults:
      cell.sectionType = DefaultOptions(rawValue: indexPath.row)
    case .user:
      cell.sectionType = UserOptions(rawValue: indexPath.row)
    case .global:
      cell.sectionType = GlobalOptions(rawValue: indexPath.row)
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    // swiftlint:disable force_cast
    let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
    // swiftlint:enable force_cast
    guard let topicAction = cell.sectionType?.description else {
      return
    }

    let title: String = "Are you sure?"
    let message: String = "Do you really want to \(topicAction)?"

    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Yes", style: .default ) { (action: UIAlertAction!) in
      tableView.deselectRow(at: indexPath, animated: false)
      self.modifyTopics(action: topicAction)
    }
    alertController.addAction(confirmAction)
    let cancelAction = UIAlertAction(title: "No", style: .default) { (_: UIAlertAction!) in
      tableView.deselectRow(at: indexPath, animated: false)
    }
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)

  }

}
