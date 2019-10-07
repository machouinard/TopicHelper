//
//  SettingsViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/6/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController {
    
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
        case .Social:
            return SocialOptions.allCases.count
        case .Communications:
            return CommunicationOptions.allCases.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        
        guard let section = SettingsSection(rawValue: indexPath.section) else {
            return cell
        }
        
        switch section {
        case .Social:
            cell.sectionType = SocialOptions(rawValue: indexPath.row)
        case .Communications:
            cell.sectionType = CommunicationOptions(rawValue: indexPath.row)
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
    
}
