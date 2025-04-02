//
//  TrackerCell.swift
//  Tracker
//
//  Created by User on 30.03.2025.
//

import Foundation
import UIKit

final class TrackerCell: UICollectionViewCell {
    static let trackerCellIdentifier = "TrackerCell"
    
    private lazy var trackerCardView: UIView = {
        let trackerCardView = UIView()
        trackerCardView.layer.masksToBounds = true
        trackerCardView.layer.cornerRadius = 16
        return trackerCardView
    }()
    
    private lazy var trackerCardEmojiLabel: UILabel = {
        let trackerCardEmojiLabel = UILabel()
        trackerCardEmojiLabel.backgroundColor = UIColor(white: 1, alpha: 0.3)
        trackerCardEmojiLabel.layer.masksToBounds = true
        trackerCardEmojiLabel.layer.cornerRadius = 12
        trackerCardEmojiLabel.textAlignment = .center
        trackerCardEmojiLabel.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return trackerCardEmojiLabel
    }()
    
    private lazy var trackerCardNameLabel: UILabel = {
        let trackerCardNameLabel = UILabel()
        trackerCardNameLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        trackerCardNameLabel.textColor = .white
        trackerCardNameLabel.numberOfLines = 2
        return trackerCardNameLabel
    }()
    
    private lazy var trackerButton: UIButton = {
        let trackerButton = UIButton()
        trackerButton.layer.masksToBounds = true
        trackerButton.layer.cornerRadius = 17
        trackerButton.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        return trackerButton
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let daysCounterLabel = UILabel()
        daysCounterLabel.text = "1 день"
        daysCounterLabel.textColor = .black
        daysCounterLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        return daysCounterLabel
    }()
    
    @objc private func didTapTrackerButton(){
        
    }
    
    private func setupUI(){
        [trackerCardView, trackerButton, trackerCardNameLabel, trackerCardEmojiLabel, daysCounterLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: 90),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCardEmojiLabel.heightAnchor.constraint(equalToConstant: 24),
            trackerCardEmojiLabel.widthAnchor.constraint(equalToConstant: 24),
            trackerCardEmojiLabel.topAnchor.constraint(equalTo: trackerCardView.topAnchor, constant: 12),
            trackerCardEmojiLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerButton.heightAnchor.constraint(equalToConstant: 34),
            trackerButton.widthAnchor.constraint(equalToConstant: 34),
            trackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            trackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            daysCounterLabel.centerYAnchor.constraint(equalTo: trackerButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
#Preview {
    TrackerCell()
}
