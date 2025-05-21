//
//  TrackerCell.swift
//  Tracker
//
//  Created by User on 30.03.2025.
//

import Foundation
import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompletedTracker(id: UUID, at indexPath: IndexPath)
}

final class TrackerCell: UICollectionViewCell {
    
    static let trackerCellIdentifier = "TrackerCell"
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
    weak var delegate: TrackerCellDelegate?
    
    lazy var trackerCardView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var trackerCardEmojiLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(white: 1, alpha: 0.3)
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 12
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private lazy var trackerCardNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var pinImage: UIImageView = {
        let image = UIImageView()
        image.image = .pin
        image.isHidden = true
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var emojiAndPinContainer: UIStackView = {
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let stack = UIStackView(arrangedSubviews: [trackerCardEmojiLabel, spacer, pinImage])
        
        trackerCardEmojiLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true
            trackerCardEmojiLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        stack.axis = .horizontal
        stack.alignment = .center
        return stack
    }()
    
    private lazy var trackerCardContentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emojiAndPinContainer, trackerCardNameLabel])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 8
        return stack
    }()
    
    private lazy var trackerButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(didTapTrackerButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var daysCounterLabel: UILabel = {
        let label = UILabel()
        let labelText = NSLocalizedString("tracker.day", comment: "")
        label.text = "1 \(labelText)"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    @objc private func didTapTrackerButton() {
        guard let id = trackerId, let indexPath = indexPath else {
            assertionFailure("no trackerId")
            return
        }
        isCompletedToday
            ? delegate?.uncompletedTracker(id: id, at: indexPath)
            : delegate?.completeTracker(id: id, at: indexPath)
        AnalyticsService.shared.report(event: "click", screen: "Main", item: "track")
    }
    
    private func setupUI() {
        [trackerCardView, trackerButton, daysCounterLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        trackerCardContentStack.translatesAutoresizingMaskIntoConstraints = false
        trackerCardView.addSubview(trackerCardContentStack)
        
        NSLayoutConstraint.activate([
            trackerCardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCardView.heightAnchor.constraint(equalToConstant: 90),
            trackerCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            trackerCardContentStack.topAnchor.constraint(equalTo: trackerCardView.topAnchor, constant: 12),
            trackerCardContentStack.leadingAnchor.constraint(equalTo: trackerCardView.leadingAnchor, constant: 12),
            trackerCardContentStack.trailingAnchor.constraint(equalTo: trackerCardView.trailingAnchor, constant: -12),
            trackerCardContentStack.bottomAnchor.constraint(lessThanOrEqualTo: trackerCardView.bottomAnchor, constant: -12),
            
            pinImage.widthAnchor.constraint(equalToConstant: 8),
            pinImage.heightAnchor.constraint(equalToConstant: 12),
            
            trackerButton.heightAnchor.constraint(equalToConstant: 34),
            trackerButton.widthAnchor.constraint(equalToConstant: 34),
            trackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            daysCounterLabel.centerYAnchor.constraint(equalTo: trackerButton.centerYAnchor),
            daysCounterLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
        ])
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath, isPinned: Bool) {
        self.trackerId = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        trackerCardView.backgroundColor = tracker.color
        trackerCardNameLabel.text = tracker.name
        trackerCardEmojiLabel.text = tracker.emoji
        daysCounterLabel.text = pluralizeDays(completedDays)
        trackerButton.tintColor = tracker.color
        
        let imageName = isCompletedToday ? "doneButton" : "plusButton"
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate) {
            trackerButton.setImage(image, for: .normal)
            trackerButton.tintColor = tracker.color
        }
        
        pinImage.isHidden = !isPinned
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        if remainder10 == 1 && remainder100 != 11 {
            let text = NSLocalizedString("tracker.day", comment: "")
            return "\(count) \(text)"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            let text = NSLocalizedString("tracker.2,3,4day", comment: "")
            return "\(count) \(text)"
        } else {
            let text = NSLocalizedString("tracker.days", comment: "")
            return "\(count) \(text)"
        }
    }
}
