//
//  StatisticViewController.swift
//  Tracker
//
//  Created by User on 21.03.2025.
//

import Foundation
import UIKit

final class StatisticViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let statisticsService = StatisticsService()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var statisticsData: StatisticsData?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedString("statisticsLabel", comment: "")
        label.text = text
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let image = UIImageView()
        image.image = .statPlaceholder
        return image
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        let text = NSLocalizedString("statisticPlaceholder", comment: "")
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.statisticsCellIdentifier)
        tableView.bounces = false
        tableView.layer.masksToBounds = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .ypWhite
        tableView.separatorStyle = .none
        return tableView
    }()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        trackerRecordStore.delegate = self
        reloadStatistics()
    }
    
    // MARK: - Private Methods
    
    private func reloadStatistics() {
        statisticsData = statisticsService.fetchStatistics()
        
        let hasData = [
            statisticsData?.longestStreak ?? 0,
            statisticsData?.perfectDays ?? 0,
            statisticsData?.completedCount ?? 0,
            statisticsData?.averagePerDay ?? 0
        ].contains { $0 > 0 }
        
        if hasData {
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        } else {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
            tableView.isHidden = true
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .ypWhite
        [titleLabel, placeholderImage, placeholderLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderImage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -273),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Extension: UITableViewDelegate

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

// MARK: - Extension: UITableViewDataSource

extension StatisticViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.statisticsCellIdentifier, for: indexPath) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        let titles = [
            NSLocalizedString("bestPeriod", comment: "Best period"),
            NSLocalizedString("idealDays", comment: "Ideal days"),
            NSLocalizedString("numberOfCompletedTrackers", comment: "Trackers completed"),
            NSLocalizedString("average", comment: "Average value")
        ]
        
        let counts = [
            statisticsData?.longestStreak ?? 0,
            statisticsData?.perfectDays ?? 0,
            statisticsData?.completedCount ?? 0,
            statisticsData?.averagePerDay ?? 0
        ]
        
        if indexPath.row < titles.count && indexPath.row < counts.count {
            cell.configureCell(with: titles[indexPath.row], count: counts[indexPath.row])
        }
        
        return cell
    }

}

// MARK: - Extension: TrackerStoreDelegate

extension StatisticViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        reloadStatistics()
    }
}

// MARK: - Extension: TrackerRecordStoreDelegate

extension StatisticViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ update: TrackerCategoryStoreUpdate) {
        reloadStatistics()
    }
    
}



