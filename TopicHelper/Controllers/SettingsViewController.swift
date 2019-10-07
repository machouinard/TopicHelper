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

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
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
//        navigationController?.navigationBar.barStyle = .blackTranslucent
//        navigationController?.navigationBar.barTintColor = .systemBlue
//        navigationController?.navigationBar.barTintColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)
        navigationItem.title = "Settings"
    }
    
    @objc func modifyTopics(action: String) {
        // Start activityIndicator
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: ListViewType.AllTopics.description)
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: ListViewType.Favorites.description)
        
        var actionPredicate: NSPredicate?
        
        
        switch action {
        case Actions.defaultDelete.description:
            actionPredicate = NSPredicate(format: "isUserTopic == NO")
            deleteTopics(predicate: actionPredicate!)
            print("delete default")
        case Actions.defaultRestore.description:
            actionPredicate = NSPredicate(format: "isUserTopic == NO")
            deleteTopics(predicate: actionPredicate!)
            restoreDefaultTopics()
            print("restore default")
        case Actions.userDelete.description:
            actionPredicate = NSPredicate(format: "isUserTopic == YES")
            deleteTopics(predicate: actionPredicate!)
            print("user delete")
        case Actions.globalDelete.description:
            deleteTopics(predicate: nil)
            print("global delete")
        default:
            print("none")
        }
        
        
        
        
    }
    
    func deleteTopics(predicate: NSPredicate?) {
        let fetch = NSFetchRequest<Topic>()
        let entity = Topic.entity()
        fetch.entity = entity
        
        if nil != predicate {
            fetch.predicate = predicate
        }
        
        let request = NSBatchDeleteRequest(fetchRequest: fetch as! NSFetchRequest<NSFetchRequestResult>)
        
        
        do {
            try managedContext.execute(request)
            // End activityIndicator
            removeSpinner()
            print("DONE")
        } catch  {
            fatalCoreDataError(error)
        }
    }
    
    func restoreDefaultTopics() {
        let path = Bundle.main.path(forResource: "topics10", ofType: "plist")
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
            // stop activityIndicator
        } catch  {
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
        case .Defaults:
            return DefaultOptions.allCases.count
        case .User:
            return UserOptions.allCases.count
        case .Global:
            return GlobalOptions.allCases.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return cell
        }
        
        
        
        switch section {
        case .Defaults:
            cell.sectionType = DefaultOptions(rawValue: indexPath.row)
        case .User:
            cell.sectionType = UserOptions(rawValue: indexPath.row)
        case .Global:
            cell.sectionType = GlobalOptions(rawValue: indexPath.row)
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Section:Row \(indexPath.section):\(indexPath.row)")
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        
        guard let topicAction = cell.sectionType?.description else {
            return
        }
        
        
        let title: String = "Are you sure?"
        let message: String = "Do you really want to \(topicAction)?"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default ) {
            (action: UIAlertAction!) in
            print("confirmed action")
            // Start spinner
            self.showSpinner()
            self.modifyTopics(action: topicAction)
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "No", style: .default) { (action: UIAlertAction!) in
            print("canceled action")
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}
