//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Olya on 03.05.2025.
//

import Foundation

final class CategoryViewModel {
    
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)? // вызывается когда данные обновляются
    
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    
    private let trackerCategoryStore: TrackerCategoryStore
    
    init(store: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = store
    }
    
    func loadCategories() {
        self.categories = [
            TrackerCategory(title: "Важное", trackers: []),
            TrackerCategory(title: "Домашний уют", trackers: [])
        ]
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
}
