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
    private var pinnedTrackers: [Tracker] = []

    private var currentDate: Date?
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        let labelText = NSLocalizedString("trackers.title", comment: "Заголовок на главном экране трекеров")
        label.text = labelText
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .black
        
        return label
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        // datePicker.locale = Locale(identifier: "ru_RU")
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
        let searchTextFieldText = NSLocalizedString("searchBar", comment: "Строка поиска")
        searchTextField.attributedPlaceholder = NSAttributedString(string: searchTextFieldText, attributes: attributes)
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
        let placeholderText = NSLocalizedString("emptyState.title", comment: "Заглушка если трекеров нет")
        placeholderLabel.text = placeholderText
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        return placeholderLabel
    }()
    
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAppearance()
        setupNavigationItem()
        setupUI()
        showPlaceholder()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidCreateTracker), name: Notification.Name("DidCreateTracker"), object: nil)
        trackerCategoryStore.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        [datePicker, collectionView, trackerLabel, searchStackView, placeholderImage, placeholderLabel].forEach{
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
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white // Или любой твой цвет
        appearance.shadowColor = .clear // Если не хочешь нижнюю тень
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
            let placeholderText = NSLocalizedString("emptySearchResult", comment: "Заглушка если выдача нулевая")
            placeholderLabel.text = placeholderText
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
        let today = Date()
        
        // Категория закрепленных трекеров
        let pinnedFilteredTrackers = pinnedTrackers.filter { tracker in
            let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
            var dateCondition = false
            
            if tracker.isHabit {
                let filterWeekDay = calendar.component(.weekday, from: currentDate)
                let adjustedWeekDay = filterWeekDay == 1 ? 7 : filterWeekDay - 1
                dateCondition = tracker.schedule.contains { $0.numberValue == adjustedWeekDay }
            } else {
                if let record = completedTrackers.first(where: { $0.trackerID == tracker.id }) {
                    dateCondition = calendar.isDate(record.date, inSameDayAs: currentDate)
                } else {
                    dateCondition = calendar.isDate(currentDate, inSameDayAs: today) || currentDate > today
                }
            }
            
            return textCondition && dateCondition
        }
        
        visibleCategories = []
        
        if !pinnedFilteredTrackers.isEmpty {
            visibleCategories.append(TrackerCategory(title: "Закрепленные", trackers: pinnedFilteredTrackers))
        }
        
        // Теперь остальные категории без закрепленных трекеров
        let otherCategories = filteredCategories.compactMap { category -> TrackerCategory? in
            let trackers = category.trackers.filter { tracker in
                // Пропускаем закрепленные
                if pinnedTrackers.contains(where: { $0.id == tracker.id }) {
                    return false
                }
                
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                var dateCondition = false
                
                if tracker.isHabit {
                    let filterWeekDay = calendar.component(.weekday, from: currentDate)
                    let adjustedWeekDay = filterWeekDay == 1 ? 7 : filterWeekDay - 1
                    dateCondition = tracker.schedule.contains { $0.numberValue == adjustedWeekDay }
                } else {
                    if let record = completedTrackers.first(where: { $0.trackerID == tracker.id }) {
                        dateCondition = calendar.isDate(record.date, inSameDayAs: currentDate)
                    } else {
                        dateCondition = calendar.isDate(currentDate, inSameDayAs: today) || currentDate > today
                    }
                }
                
                return textCondition && dateCondition
            }
            
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
        
        visibleCategories.append(contentsOf: otherCategories)
        
        collectionView.reloadData()
        showPlaceholder()
    }

    
    private func isCurrentDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    private func openEditScreen(with tracker: Tracker) {
        let editVC = NewHabitOrEventViewController()
        editVC.isEditingTracker = true
        editVC.trackerToEdit = tracker
        
        editVC.isHabit = tracker.isHabit
        self.present(editVC, animated: true)
    }
    
    private func deleteTracker(at indexPath: IndexPath) {
        let trackerToDelete = visibleCategories[indexPath.section].trackers[indexPath.item]
        trackerStore.deleteTracker(trackerToDelete)
        
        trackers = trackerStore.fetchTrackers()
        categories = trackerCategoryStore.fetchCategories()
        filteredCategories = categories
        
        reloadVisibleCategories()
        collectionView.reloadData()
        
        showPlaceholder()
    }
    
    private func togglePinTracker(_ tracker: Tracker) {
        if let index = pinnedTrackers.firstIndex(where: { $0.id == tracker.id }) {
            // Открепляем
            pinnedTrackers.remove(at: index)
        } else {
            // Закрепляем
            pinnedTrackers.append(tracker)
        }
        reloadVisibleCategories()
    }

    private func showDeleteConfirmation(for tracker: Tracker, at indexPath: IndexPath) {
        let alert = UIAlertController(title: "", message: "Уверены что хотите удалить трекер?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive) { _ in
            self.deleteTracker(at: indexPath)
        })
        present(alert, animated: true)
    }
}

// MARK: - Extension: UICollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                self?.openEditScreen(with: tracker)
            }
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { _ in
                        self.showDeleteConfirmation(for: tracker, at: indexPath)
                    }
            let pinTitle = self.pinnedTrackers.contains(where: { $0.id == tracker.id }) ? "Открепить" : "Закрепить"
                    let pinAction = UIAction(title: pinTitle) { [weak self] _ in
                        self?.togglePinTracker(tracker)
                    }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        return UITargetedPreview(view: cell.trackerCardView)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        return UITargetedPreview(view: cell.trackerCardView)
    }
    
    
}
// MARK: - Extension: UICollectionViewDataSource

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
        let isPinned = pinnedTrackers.contains { $0.id == tracker.id }
        cell.configureCell(tracker: tracker, isCompletedToday: isCompletedToday, completedDays: completedDays, indexPath: indexPath, isPinned: isPinned)
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

// MARK: - Extension: UITextFieldDelegate

extension TrackersViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        reloadVisibleCategories()
        return true
    }
}

// MARK: - Extension: TrackerCellDelegate

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

// MARK: - Extension: NewHabitOrEventViewControllerDelegate

extension TrackersViewController: NewHabitOrEventViewControllerDelegate {
    func didCreateTrackerOrEvent(tracker: Tracker) {
        trackers.append(tracker)
        reloadData()
    }
}

// MARK: - Extension: UICollectionViewDelegateFlowLayout

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

// MARK: - Extension: TrackersStoresDelegates

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
        categories = trackerCategoryStore.fetchCategories()
        filteredCategories = categories
        reloadVisibleCategories()
        collectionView.reloadData()
    }
}







