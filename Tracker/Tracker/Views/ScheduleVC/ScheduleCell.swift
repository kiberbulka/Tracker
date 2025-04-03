//
//  ScheduleCell.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation
import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func switchStateChanged(isOn: Bool, for day: String?)
}

final class ScheduleCell: UITableViewCell {
    
    static let scheduleCellIdentifier = "ScheduleCell"
    
    weak var delegate: ScheduleCellDelegate?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        return label
    }()
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(switchDidChanged), for: .touchUpInside)
        switchControl.isOn = false
        switchControl.onTintColor = .ypBlue
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        selectionStyle = .none
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchDidChanged(){
        delegate?.switchStateChanged(isOn: switchControl.isOn, for: titleLabel.text)
    }
    
    func configureCell(with weekdays: String, isOn: Bool) {
        titleLabel.text = weekdays
        switchControl.isOn = isOn
    }
    
    private func setupUI(){
        backgroundColor = .ypGray
        [switchControl, titleLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            switchControl.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
#Preview{
    ScheduleCell()
}
