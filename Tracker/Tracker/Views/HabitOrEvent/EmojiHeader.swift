//
//  EmojiOrColorHeader.swift
//  Tracker
//
//  Created by User on 14.04.2025.
//

import Foundation
import UIKit

final class EmojiHeader: UICollectionReusableView {
    
    static let identifier = "EmojiIdentifier"
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        titleLabel.textColor = .ypBlack
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant:28)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
        titleLabel.text = text
    }
}
