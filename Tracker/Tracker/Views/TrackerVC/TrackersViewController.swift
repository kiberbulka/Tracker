//
//  ViewController.swift
//  Tracker
//
//  Created by User on 20.03.2025.
//

import UIKit

class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var trackers: [Tracker] = []
    private var tracker: Tracker?
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date?
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var addTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addTracker"), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(createTrackerOrHabit), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.trackerCellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var searchStackView: UIStackView = {
        let searchStackview = UIStackView(arrangedSubviews: [searchTextField])
        searchStackview.axis = .horizontal
        searchStackview.distribution = .fill
        searchStackview.spacing = 14
        return searchStackview
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let searchTextField = UISearchTextField()
        searchTextField.backgroundColor = .ypGray
        searchTextField.textColor = .black
        searchTextField.tintColor = .black
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.masksToBounds = true
        searchTextField.borderStyle = .none
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.ypLightGray,
            .font: UIFont.systemFont(ofSize: 15, weight: .regular)
        ]
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Поиск", attributes: attributes)
        searchTextField.clearButtonMode = .never
        searchTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchTextField.delegate = self
        return searchTextField
    }()
    
    
    private lazy var placeholderImage: UIImageView = {
        let placeholderImageView = UIImageView()
        placeholderImageView.image = UIImage(named: "placeholder")
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return placeholderLabel
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationItem()
        setupUI()
        showPlaceholder()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidCreateTracker), name: Notification.Name("DidCreateTracker"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationItem(){
        let image = UIImage(named: "addTracker")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: image,
            style: .plain,
            target: self,
            action: #selector(createTrackerOrHabit)
        )
        
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    @objc private func handleDidCreateTracker() {
        reloadData()
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.reloadData()
        showPlaceholder()
    }
    
    private func showPlaceholder() {
        if categories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else if visibleCategories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
            placeholderImage.image = UIImage(named: "placeholder2")
            placeholderLabel.text = "Ничего не найдено"
        } else {
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
    
    
    private func reloadData(){
        trackers = trackerStore.fetchTrackers()
        categories = trackerCategoryStore.fetchCategories()
        filteredCategories = categories
        completedTrackers = trackerRecordStore.fetch()
        datePickerValueChanged()
        reloadVisibleCategories()
        showPlaceholder()
    }
    
    private func setupUI() {
        
        [datePicker, collectionView, trackerLabel, searchStackView, placeholderImage, placeholderLabel, addTrackerButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            searchStackView.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 358),
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            
            
        ])
    }
    
    @objc private func datePickerValueChanged() {
        currentDate = datePicker.date
        reloadVisibleCategories()
        collectionView.reloadData()
    }
    
    @objc private func createTrackerOrHabit(){
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        present(createTrackerVC, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func isTrackerCompletedToday(id:UUID) -> Bool {
        
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerID == id && isSameDay
            
        }
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        guard let currentDate = currentDate else { return }
        let filterText = (searchTextField.text ?? "").lowercased()
        
        visibleCategories = filteredCategories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                var dateCondition = false
                
                if tracker.isHabit == true {
                    let filterWeekDay = calendar.component(.weekday, from: currentDate)
                    dateCondition = tracker.schedule.contains { dayOfWeek in
                        let dayOfWeekIndex = dayOfWeek.numberValue
                        let filterWeekDayAdjusted = filterWeekDay == 1 ? 7 : filterWeekDay - 1
                        return dayOfWeekIndex == filterWeekDayAdjusted
                    }
                } else {
                    if isCurrentDate(currentDate) {
                        let creationDate = Date()
                        dateCondition = calendar.isDate(creationDate, inSameDayAs: currentDate)
                    }
                }
                return textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        collectionView.reloadData()
        showPlaceholder()
    }
    
    
    private func isCurrentDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}

extension TrackersViewController: UICollectionViewDelegate {
    
}

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.isEmpty ? 0: visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.trackerCellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id}.count
        cell.configureCell(tracker: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard indexPath.section < visibleCategories.count else { return UICollectionReusableView()}
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as! SupplementaryView
            let category = visibleCategories[indexPath.section]
            
            header.configure(text: category.title)
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

extension TrackersViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        reloadVisibleCategories()
        return true
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        guard datePicker.date <= Date() else {
            return
        }
        
        let trackerRecord = TrackerRecord(trackerID: id, date: datePicker.date)
        do {
            try trackerRecordStore.add(trackerRecord: trackerRecord)
            completedTrackers.append(trackerRecord)
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Failed to add tracker record: \(error)")
        }
    }
    
    
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll() { trackerRecord in
            do {
                try trackerRecordStore.delete(trackerRecord: trackerRecord)
            } catch {
                print("Failed to delete tracker record: \(error)")
            }
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerID == id && isSameDay
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackersViewController: NewHabitOrEventViewControllerDelegate {
    func didCreateTrackerOrEvent(tracker: Tracker) {
        trackers.append(tracker)
        reloadData()
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemCount: CGFloat = 2
        let space: CGFloat = 9
        let width: CGFloat = (collectionView.bounds.width - space - 32) / itemCount
        let height: CGFloat = 148
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
}

extension TrackersViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate, TrackerCategoryStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPath = update.insertedIndexes.map { IndexPath(item: $0, section: $0) }
            let deletedIndexPath = update.deletedIndexes.map { IndexPath(item: $0, section: $0) }
            collectionView.insertItems(at: insertedIndexPath)
            collectionView.deleteItems(at: deletedIndexPath)
        }
    }
    
    func didUpdateRecords(_ update: TrackerCategoryStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPath = update.insertedIndexes.map { IndexPath(item: $0, section: $0) }
            let deletedIndexPath = update.deletedIndexes.map { IndexPath(item: $0, section: $0) }
            collectionView.insertItems(at: insertedIndexPath)
            collectionView.deleteItems(at: deletedIndexPath)
        }
    }
    
    func didUpdateCategories(_ update: TrackerCategoryStoreUpdate) {
        collectionView.performBatchUpdates {
            let insertedIndexPath = update.insertedIndexes.map { IndexPath(item: $0, section: $0) }
            let deletedIndexPath = update.deletedIndexes.map { IndexPath(item: $0, section: $0) }
            collectionView.insertItems(at: insertedIndexPath)
            collectionView.deleteItems(at: deletedIndexPath)
        }
    }
}







