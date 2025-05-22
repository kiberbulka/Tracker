//
//  Extensions.swift
//  Tracker
//
//  Created by Olya on 20.05.2025.
//

import Foundation
extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }

    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: compactMap {
            guard let newKey = transform($0.key) else { return nil }
            return (newKey, $0.value)
        })
    }
}
