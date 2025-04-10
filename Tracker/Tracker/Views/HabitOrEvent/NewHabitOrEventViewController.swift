//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation
import UIKit

protocol NewHabitOrEventViewControllerDelegate: AnyObject {
    func didCreateTrackerOrEvent(tracker: Tracker)
}

final class NewHabitOrEventViewController: UIViewController, CategorySelectionDelegate {
    
    // MARK: - Public Properties
    
    var isHabit: Bool = true
    var selectedCategories :[String] = []
    var categoryCellIndexPath: IndexPath?
    var tracker: Tracker?
    
    weak var delegate: NewHabitOrEventViewControllerDelegate?
    
    // MARK: - Private Properties
    
    private var category: TrackerCategory? = TrackerCategory(title: "Домашний уют", trackers: [])
    private let dataManager = DataManager.shared
    private var schedule: [Weekday] = []
    
    private lazy var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = .black
        return label
    }()
    
    private lazy var trackerNameTF: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypGray
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(.xmark, for: .normal)
        clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        clearButton.addTarget(self, action: #selector(clearButtonDidTap), for: .touchUpInside)
        
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: clearButton.frame.width + 12, height: clearButton.frame.height))
        rightPaddingView.addSubview(clearButton)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .whileEditing
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.text = "Ограничение 38 символов"
        label.font = UIFont(name: "YSDisplay-Medium", size: 17)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypLightGray
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
        button.addTarget(self, action: #selector(createButtonDidTap), for: .touchUpInside)
        button.titleLabel?.textColor = .white
        button.isEnabled = false
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.bounces = false
        return tableView
    }()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        habitOrEventLabel()
        tableView.delegate = self
        tableView.dataSource = self
        trackerNameTF.delegate = self
    }
    
    // MARK: - Public Methods
    
    func didSelectCategory(_ category: String) {
        if !selectedCategories.contains(category) {
            selectedCategories.append(category)
        }
        if let indexPath = categoryCellIndexPath {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.detailTextLabel?.text = selectedCategories.joined(separator: ", ")
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    
    @objc private func createButtonDidTap() {
        let name = trackerNameTF.text ?? ""
        let id = UUID()
        let emoji = "🤪"
        let color = UIColor.colorSelection6
        let type = isHabit ? TrackerType.habit : TrackerType.irregularEvent

        let trackerSchedule: [Weekday]
        if isHabit {
            trackerSchedule = schedule
        } else {
            if let today = currentWeekday() {
                trackerSchedule = [today]
            } else {
                trackerSchedule = []
            }
        }

        let tracker = Tracker(id: id, name: name, emoji: emoji, color: color, schedule: trackerSchedule, type: type)

        for category in selectedCategories {
            dataManager.add(tracker: tracker, to: category)
        }


        delegate?.didCreateTrackerOrEvent(tracker: tracker)
        NotificationCenter.default.post(name: Notification.Name("DidCreateTracker"), object: nil)
        
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }

    
    private func currentWeekday() -> Weekday? {
        let weekdayNumber = Calendar.current.component(.weekday, from: Date())
        return Weekday.allCases.first(where: { $0.numberValue == weekdayNumber })
    }

    
    private func createButtonIsAvailable(){
        let isText = trackerNameTF.hasText
        let selectedScedule = !schedule.isEmpty
        let buttonIsAvailable: Bool
        let selectedCategories = !selectedCategories.isEmpty
        if isHabit{
            buttonIsAvailable = isText && selectedScedule && selectedCategories
        } else {
            buttonIsAvailable = isText && selectedCategories
        }
        createButton.isEnabled = buttonIsAvailable
        createButton.backgroundColor = buttonIsAvailable ? .black : .ypLightGray
        
    }
    
    private func setupUI(){
        view.backgroundColor = .white
        [newHabitLabel, trackerNameTF, cancelButton, createButton, tableView, characterLimitLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newHabitLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            trackerNameTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameTF.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 38),
            trackerNameTF.heightAnchor.constraint(equalToConstant: 75),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: view.frame.width / 2 - 24),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor,constant: -16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            characterLimitLabel.heightAnchor.constraint(equalToConstant: 32),
            characterLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            characterLimitLabel.topAnchor.constraint(equalTo: trackerNameTF.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    @objc private func cancelButtonDidTap(){
        dismiss(animated: true)
    }
    
    @objc private func clearButtonDidTap(){
        trackerNameTF.text = ""
        characterLimitLabel.isHidden = true
    }
    
    private func habitOrEventLabel(){
        if isHabit {
            newHabitLabel.text = "Новая привычка"
        } else {
            newHabitLabel.text = "Новое нерегулярное событие"
        }
        tableView.reloadData()
    }
    
    private func scheduleSubtitle()->String{
        if schedule.count == 7 {
            return "Каждый день"
        } else {
            let shortNames = schedule
                .sorted {
                    guard let firstIndex = Weekday.allCases.firstIndex(of: $0),
                          let secondIndex = Weekday.allCases.firstIndex(of: $1) else { return false }
                    return firstIndex < secondIndex
                }
                .map { $0.shortName }
            return shortNames.joined(separator: ", ")
        }
    }
    
}

extension NewHabitOrEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isHabit ? 2:1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        configureCornerRadius(for: cell, indexPath: indexPath, tableView: tableView)
        cell.backgroundColor = .ypGray
        cell.textLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
        cell.detailTextLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
        cell.detailTextLabel?.textColor = .ypLightGray
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.detailTextLabel?.text = selectedCategories.isEmpty ? "" : selectedCategories.joined(separator: ", ")
        } else {
            cell.textLabel?.text = "Расписание"
            cell.detailTextLabel?.text = scheduleSubtitle()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            categoryCellIndexPath = indexPath
            let categoryVC = CategoryViewController()
            categoryVC.delegate = self
            present(categoryVC, animated: true)
        } else {
            let scheduleVC = ScheduleViewController()
            scheduleVC.delegate = self
            present(scheduleVC, animated: true)
        }
    }
    
    private func configureCornerRadius(for cell: UITableViewCell, indexPath: IndexPath, tableView: UITableView) {
        let cornerRadius:CGFloat = 16
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        if numberOfRows == 1 {
            cell.layer.cornerRadius = cornerRadius
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            switch indexPath.row {
            case 0:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            case numberOfRows - 1:
                cell.layer.cornerRadius = cornerRadius
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            default:
                cell.layer.cornerRadius = 0
                cell.layer.maskedCorners = []
            }
        }
        
        cell.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        
        if isLastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
        }
    }
    
    
}

extension NewHabitOrEventViewController: UITableViewDelegate {
    
}

extension NewHabitOrEventViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        characterLimitLabel.isHidden = newText.count < 38
        
        return newText.count <= 39
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        createButtonIsAvailable()
        return true
    }
}

extension NewHabitOrEventViewController: ScheduleViewControllerDelegate {
    func didSelectDays(days: [Weekday]) {
        schedule = days
        tableView.reloadData()
    }
}
