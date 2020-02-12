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
  case defaultGemDelete
  case userGemDelete
  case globalGemDelete

  var description: String {
    switch self {
    case .defaultRestore: return "Restore Default Topics & Gems"
    case .defaultDelete: return "Delete Default Topics"
    case .userDelete: return "Delete My Topics"
    case .globalDelete: return "Delete All Topics"
    case .clearFavorites: return "Clear all Favorites"
    case .defaultGemDelete: return "Delete Default Gems"
    case .userGemDelete: return "Delete My Gems"
    case .globalGemDelete: return "Delete All Gems"
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
      return "Default"
    case .user:
      return "User"
    case .global:
      return "Global"
    }
  }
}

enum DefaultOptions: Int, CaseIterable, SectionType {

  case restoreDefaultTopics
  case removeDefaultTopics
  case removeDefaultGems

  var containsSwitch: Bool {
    switch self {
    case .restoreDefaultTopics:
      return false
    case .removeDefaultTopics:
      return false
    case .removeDefaultGems:
      return false
    }
  }

  var detailText: String? {
    switch self {
    case .restoreDefaultTopics:
      return "Will also clear favorited default topics"
    case .removeDefaultTopics:
      return "Remove original topics"
    case .removeDefaultGems:
      return "Remove original gems"
    }
  }

  var description: String {
    switch self {
    case .restoreDefaultTopics:
      return TopicActions.defaultRestore.description
    case .removeDefaultTopics:
      return TopicActions.defaultDelete.description
    case .removeDefaultGems:
      return TopicActions.defaultGemDelete.description
    }
  }
}

enum UserOptions: Int, CaseIterable, SectionType {
  case removeUserTopics
  case removeUserGems

  var containsSwitch: Bool {
    switch self {
    case .removeUserTopics:
      return false
    case .removeUserGems:
      return false
    }
  }

  var detailText: String? {
    switch self {
    case .removeUserTopics:
      return "Remove topics you've added"
    case .removeUserGems:
      return "Remove gems you've added"
    }

  }

  var description: String {
    switch self {
    case .removeUserTopics:
      return TopicActions.userDelete.description
    case .removeUserGems:
      return TopicActions.userGemDelete.description
    }
  }
}

enum GlobalOptions: Int, CaseIterable, SectionType {
  case removeAllTopics
  case clearAllFavorites
  case removeAllGems

  var containsSwitch: Bool { return false }
  var detailText: String? {
    switch self {
    case .removeAllTopics:
      return "Remove all topics"
    case .clearAllFavorites:
      return "Unmark all favorites"
    case .removeAllGems:
      return "Remove all gems"
    }
  }

  var description: String {
    switch self {
    case .removeAllTopics:
      return TopicActions.globalDelete.description
    case .clearAllFavorites:
      return TopicActions.clearFavorites.description
    case .removeAllGems:
      return TopicActions.globalGemDelete.description
    }
  }
}
