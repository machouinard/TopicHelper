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

enum Actions: Int, CaseIterable, CustomStringConvertible {
    case defaultRestore
    case defaultDelete
    case userDelete
    case globalDelete
    
    var description: String {
        switch self {
        case .defaultRestore: return "Restore Default Topics"
        case .defaultDelete: return "Delete Default Topics"
        case .userDelete: return "Delete My Topics"
        case .globalDelete: return "Delete All Topics"
        }
    }
    
}

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Defaults
    case User
    case Global
    
    var description: String {
        switch self {
        case .Defaults:
            return "Default Topics"
        case .User:
            return "User Topics"
        case .Global:
            return "Global Topics"
        }
    }
}

enum DefaultOptions: Int, CaseIterable, SectionType {
    
    case restoreDefaultTopics
    case RemoveDefaultTopics
    
    var containsSwitch: Bool {
        switch self {
        case .restoreDefaultTopics:
            return false
        case .RemoveDefaultTopics:
            return true
        }
    }
    
    var detailText: String? {
        switch self {
        case .restoreDefaultTopics:
            return nil
        case .RemoveDefaultTopics:
            return "Remove permanently with switch"
        }
    }
    
    var description: String {
        switch self {
        case .restoreDefaultTopics:
            return Actions.defaultRestore.description
        case .RemoveDefaultTopics:
            return Actions.defaultDelete.description
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
    
    var detailText: String? { return nil }
    
    var description: String {
        switch self {
        case .removeUserTopics:
            return Actions.userDelete.description
        }
    }
}

enum GlobalOptions: Int, CaseIterable, SectionType {
    case removeAllTopics
    
    var containsSwitch: Bool { return false }
    var detailText: String? { return nil }
    
    var description: String {
        switch self {
        case .removeAllTopics:
            return Actions.globalDelete.description
        }
    }
}
