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
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = trackerButton.backgroundColor
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var trackerCardEmojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(white: 1, alpha: 0.3)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return label
    }()
    
    private lazy var trackerCardNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var trackerButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.backgroundColor = .colorSelection6
        button.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        label.text = "1 день"
        label.textColor = .black
        label.font = UIFont(name: "YSDisplay-Medium", size: 12)
        return label
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
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            trackerCardNameLabel.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerCardNameLabel.bottomAnchor.constraint(equalTo: trackerCardView.bottomAnchor, constant: -12),
            trackerCardNameLabel.trailingAnchor.constraint(equalTo: trackerCardView.trailingAnchor, constant: -12),
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(tracker: Tracker, isCompletedToday: Bool){
        trackerCardView.backgroundColor = tracker.color
        trackerCardNameLabel.text = tracker.name
        trackerCardEmojiLabel.text = tracker.emoji
        trackerButton.backgroundColor = trackerCardView.backgroundColor
        let image = isCompletedToday ? UIImage(named: "doneButton") : UIImage(named: "plusButton")
        trackerButton.setImage(image, for: .normal)
    }
    
}
#Preview {
    TrackerCell()
}
