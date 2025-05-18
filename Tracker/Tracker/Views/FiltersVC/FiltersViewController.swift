//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Olya on 18.05.2025.
//

import UIKit

enum FilterType: String, CaseIterable {
    case all
    case today
    case completed
    case notCompleted
    
    var title: String {
        switch self {
        case .all: return "Все трекеры"
        case .today: return "Трекеры на сегодня"
        case .completed: return "Завершённые"
        case .notCompleted: return "Незавершённые"
        }
    }
    
    var isDefault: Bool {
        return self == .all
    }
}

class FiltersViewController: UIViewController {
    
    var selectedFilter: FilterType = .all
    var onFilterSelected: ((FilterType) -> Void)?
    
    // MARK: - Private properties
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Фильтры"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.bounces = false
        return tableView
    }()
    
    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Private func
    
    private func setupUI() {
        [titleLabel, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    // MARK: - Navigation

}

extension FiltersViewController: UITableViewDelegate {
    
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let filter = FilterType.allCases[indexPath.row]
        cell.textLabel?.text = filter.title
        cell.accessoryType = filter == selectedFilter ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = FilterType.allCases[indexPath.row]
        onFilterSelected?(selected)
        dismiss(animated: true)
    }
    
    
}
