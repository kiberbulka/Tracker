//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Olya on 05.05.2025.
//

import Foundation

class CategoryViewModel{
    
    var categories: [TrackerCategory] = [] {
        didSet {
            self.reloadData?()
        }
    }
    
    var reloadData: (() -> Void)?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    init() {
        fetchCategories()
    }
    
    func fetchCategories(){
        categories = trackerCategoryStore.fetchCategories()
    }
    
    func addCategory(_ category: TrackerCategory) {
        trackerCategoryStore.addCategory(category)
        fetchCategories()
    }
    
    func deleteCategory(at indexPath: IndexPath) {
        trackerCategoryStore.deleteCategory(at: indexPath)
        fetchCategories()
        
    }
    
    func editCategory(at indexPath: IndexPath, newTitle: String) {
        trackerCategoryStore.updateCategory(at: indexPath, with: newTitle)
        fetchCategories()
    }
}
