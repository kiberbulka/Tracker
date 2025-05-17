//
//  StatisticViewController.swift
//  Tracker
//
//  Created by User on 21.03.2025.
//

import Foundation
import UIKit

final class StatisticViewController: UIViewController {
    
    private let statisticsService = StatisticsService()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private var statisticsData: StatisticsService.StatisticsData?
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Статистика"
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
        label.text = "Анализировать пока нечего"
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
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
        reloadStatistics()
    }
    
    private func reloadStatistics() {
        statisticsData = statisticsService.fetchStatistics()
        
        // Проверяем, есть ли хотя бы один показатель > 0
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
        view.backgroundColor = .white
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

extension StatisticViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
}

extension StatisticViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.statisticsCellIdentifier, for: indexPath) as? StatisticsCell else {
            return UITableViewCell()
        }
        
        let titles = ["Лучший период", "Идеальные дни", "Трекеров завершено", "Среднее значение"]
        
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
extension StatisticViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        reloadStatistics()
    }
}

extension StatisticViewController: TrackerRecordStoreDelegate {
    func didUpdateRecords(_ update: TrackerCategoryStoreUpdate) {
        reloadStatistics()
    }
    
}



