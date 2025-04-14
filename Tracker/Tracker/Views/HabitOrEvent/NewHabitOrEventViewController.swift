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
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private let emojis = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                          "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                          "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colors: [UIColor] = [.colorSection1, .colorSection2, .colorSection3, .colorSection4, .colorSection5, .colorSection6, .colorSection7, .colorSection8, .colorSection9, .colorSection10, .colorSection11, .colorSection12, .colorSection13, .colorSection14, .colorSection15, .colorSection16, .colorSection17, .colorSection18]
    
    private lazy var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
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
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
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
        label.font = .systemFont(ofSize: 17, weight: .regular)
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
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.bounces = false
        return tableView
    }()
    
    private lazy var emojiCollection : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.cellIdentifier)
        collectionView.register(EmojiHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiHeader.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.tag = 1
        return collectionView
    }()
    
    private lazy var colorCollection : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.cellIdentifier)
        collectionView.register(ColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ColorHeader.identifier)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.isScrollEnabled = false
        collectionView.tag = 2
        return collectionView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
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
        let emoji = selectedEmoji ?? ""
        let color = selectedColor ?? .white
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
        let selectedEmoji = selectedEmoji != nil
        let selectedColor = selectedColor != nil
        if isHabit{
            buttonIsAvailable = isText && selectedScedule && selectedCategories && selectedEmoji && selectedColor
        } else {
            buttonIsAvailable = isText && selectedCategories && selectedColor && selectedEmoji
        }
        createButton.isEnabled = buttonIsAvailable
        createButton.backgroundColor = buttonIsAvailable ? .black : .ypLightGray
        
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [newHabitLabel, trackerNameTF, cancelButton, createButton, tableView, emojiCollection, colorCollection, characterLimitLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            newHabitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            newHabitLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 27),

            trackerNameTF.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTF.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameTF.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 38),
            trackerNameTF.heightAnchor.constraint(equalToConstant: 75),

            characterLimitLabel.heightAnchor.constraint(equalToConstant: 32),
            characterLimitLabel.widthAnchor.constraint(equalToConstant: 286),
            characterLimitLabel.topAnchor.constraint(equalTo: trackerNameTF.bottomAnchor, constant: 8),
            characterLimitLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            tableView.topAnchor.constraint(equalTo: characterLimitLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),

            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            emojiCollection.heightAnchor.constraint(equalToConstant: 204),

            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 16),
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            colorCollection.heightAnchor.constraint(equalToConstant: 204),

            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 24),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),

            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 2 - 24),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 16),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
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
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .medium)
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

extension NewHabitOrEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 1:
            return emojis.count
        case 2:
            return colors.count
        default:
            return 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView.tag {
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell else {return UICollectionViewCell()}
            cell.configureEmoji(emoji: emojis[indexPath.item]) 
            return cell
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell else {return UICollectionViewCell()}
            cell.updateColor(color: colors[indexPath.item])
            return cell
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        switch collectionView.tag {
        case 1:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: EmojiHeader.identifier,
                for: indexPath) as? EmojiHeader else {
                    return UICollectionReusableView()
            }
            header.configure(text: "Emoji")
            return header
            
        case 2:
            guard let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ColorHeader.identifier,
                for: indexPath) as? ColorHeader else {
                    return UICollectionReusableView()
            }
            header.configure(text: "Цвета")
            return header
            
        default:
            return UICollectionReusableView()
        }
    }

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(width: collectionView.frame.width, height: collectionView.frame.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView.tag{
        case 1:
            let selectedEmoji = emojis[indexPath.row]
            if let cell = emojiCollection.cellForItem(at: indexPath) as? EmojiCell {
                cell.updateBackgroundColor(color: .ypGray)
            }
            self.selectedEmoji = selectedEmoji
            createButtonIsAvailable()
        case 2:
            let selectedColor = colors[indexPath.row]
            if let cell = colorCollection.cellForItem(at: indexPath) as? ColorCell {
                cell.updateFrameColor(color: colors[indexPath.row], isHidden: false)
                self.selectedColor = selectedColor
                createButtonIsAvailable()
            }
        default:
            break
        }
    
    }
  

}

#Preview {
    NewHabitOrEventViewController()
}
