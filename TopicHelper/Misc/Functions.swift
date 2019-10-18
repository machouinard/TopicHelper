//
//  Functions.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 9/15/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

import Foundation
import UIKit

private var aView: UIView?

extension UIViewController {
  func showSpinner() {
    aView = UIView(frame: self.view.bounds)
    aView?.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

    let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
    activityIndicator.center = aView!.center
    activityIndicator.startAnimating()
    aView!.addSubview(activityIndicator)
    self.view.addSubview(aView!)
  }

  func removeSpinner() {
    aView?.removeFromSuperview()
    aView = nil
  }
}

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
                                execute: run)
}

let applicationDocumentsDirectory: URL = {
  let paths = FileManager.default.urls(for: .documentDirectory,
                                       in: .userDomainMask)
  return paths[0]
}()

let coreDataSaveFailedNotification =
  Notification.Name(rawValue: "CoreDataSaveFailedNotification")

func fatalCoreDataError(_ error: Error) {
  print("*** Fatal error: \(error)")
  NotificationCenter.default.post(
    name: coreDataSaveFailedNotification, object: nil)
}
