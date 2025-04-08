//
//  SupplementaryView.swift
//  Tracker
//
//  Created by User on 30.03.2025.
//

import Foundation
import UIKit

final class SupplementaryView: UICollectionReusableView {
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont(name: "YSDisplay-Bold", size: 19)
        titleLabel.textColor = .black
        titleLabel.text = "Важное"
        return titleLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
