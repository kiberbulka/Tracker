//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Olya on 17.05.2025.
//

import UIKit

class StatisticsCell: UITableViewCell {
    
    static let statisticsCellIdentifier = "statisticsCell"
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private lazy var gradientBorderView: GradientBorderView = {
        let view = GradientBorderView()
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .none
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func configureCell(with title: String, count: Int) {
        self.titleLabel.text = title
        self.countLabel.text = String(count)
    }
    
    private func setupUI() {
        
        [gradientBorderView,
         titleLabel,
         countLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            gradientBorderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            gradientBorderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            gradientBorderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            gradientBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            countLabel.topAnchor.constraint(equalTo: gradientBorderView.topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 12),
            
            titleLabel.leadingAnchor.constraint(equalTo: gradientBorderView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: gradientBorderView.bottomAnchor, constant: -12)
        ])
    }
}


