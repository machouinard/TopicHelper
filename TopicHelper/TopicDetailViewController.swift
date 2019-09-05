//
//  TopicDetailViewController.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/4/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import UIKit

class TopicDetailViewController: UIViewController {
    @IBOutlet weak var topicDetailView: UITextView!
    @IBOutlet weak var topicTitleView: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var topicDetail: String!
    var topicTitle: String!
    var editTopic: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        topicDetailView.text = topicDetail
        topicDetailView.isEditable = editTopic
        topicDetailView.centerVertically()
        topicTitleView.text = topicTitle
        topicTitleView.isEnabled = editTopic
        
    }
    @IBAction func tappedDoneButton(_ sender: UIBarButtonItem) {
        // If editing, save
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
