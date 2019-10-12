//
//  SettingsSection.swift
//  TopicHelper
//
//  Created by Mark Chouinard on 10/6/19.
//  Copyright © 2019 Mark Chouinard. All rights reserved.
//

protocol SectionType: CustomStringConvertible {
  var containsSwitch: Bool { get }
  var detailText: String? { get }

}

enum TopicActions: Int, CaseIterable, CustomStringConvertible {
  case defaultRestore
  case defaultDelete
  case userDelete
  case globalDelete
  case clearFavorites

  var description: String {
    switch self {
    case .defaultRestore: return "Restore Default Topics"
    case .defaultDelete: return "Delete Default Topics"
    case .userDelete: return "Delete My Topics"
    case .globalDelete: return "Delete All Topics"
    case .clearFavorites: return "Clear all Favorites"
    }
  }

}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
  case defaults
  case user
  case global

  var description: String {
    switch self {
    case .defaults:
      return "Default Topics"
    case .user:
      return "User Topics"
    case .global:
      return "Global Topics"
    }
  }
}

enum DefaultOptions: Int, CaseIterable, SectionType {

  case restoreDefaultTopics
  case removeDefaultTopics

  var containsSwitch: Bool {
    switch self {
    case .restoreDefaultTopics:
      return false
    case .removeDefaultTopics:
      return false
    }
  }

  var detailText: String? {
    switch self {
    case .restoreDefaultTopics:
      return "Will not overwrite added topics"
    case .removeDefaultTopics:
      return "Remove original topics"
    }
  }

  var description: String {
    switch self {
    case .restoreDefaultTopics:
      return TopicActions.defaultRestore.description
    case .removeDefaultTopics:
      return TopicActions.defaultDelete.description
    }
  }
}

enum UserOptions: Int, CaseIterable, SectionType {
  case removeUserTopics

  var containsSwitch: Bool {
    switch self {
    case .removeUserTopics:
      return false
    }
  }

  var detailText: String? {
    switch self {
    case .removeUserTopics:
      return "Remove topics you've added"
    }

  }

  var description: String {
    switch self {
    case .removeUserTopics:
      return TopicActions.userDelete.description
    }
  }
}

enum GlobalOptions: Int, CaseIterable, SectionType {
  case removeAllTopics
  case clearAllFavorites

  var containsSwitch: Bool { return false }
  var detailText: String? {
    switch self {
    case .removeAllTopics:
      return "Remove everything"
    case .clearAllFavorites:
      return "Unmark all favorite topics"
    }
  }

  var description: String {
    switch self {
    case .removeAllTopics:
      return TopicActions.globalDelete.description
    case .clearAllFavorites:
      return TopicActions.clearFavorites.description
    }
  }
}
