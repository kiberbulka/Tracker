//
//  DataManager.swift
//  Tracker
//
//  Created by User on 07.04.2025.
//

import Foundation

final class DataManager {
    
    static let shared = DataManager()
    
    var categories: [TrackerCategory] = []
    
    private init(){}
    
    func add(category: TrackerCategory){
        categories.append(category)
        
    }
}
