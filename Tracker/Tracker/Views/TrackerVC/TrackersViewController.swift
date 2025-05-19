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
    private let pinnedTrackersKey = "pinnedTrackersIDs"
    private var currentDate: Date?
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let colors = Colors()
    
    private var selectedFilter: FilterType = .all {
        didSet {
            updateUIForSelectedFilter()
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Фильтры", for: .normal)
        button.backgroundColor = .ypBlue
        button.setTitleColor(colors.filterLabelColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filtersButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        let labelText = NSLocalizedString("trackers.title", comment: "Заголовок на главном экране трекеров")
        label.text = labelText
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .ypBlack
        
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
        collectionView.backgroundColor = .ypWhite
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
        searchTextField.textColor = .ypBlack
        searchTextField.tintColor = .ypBlack
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
        placeholderLabel.textColor = .ypBlack
        return placeholderLabel
    }()
    
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationAppearance()
        setupNavigationItem()
        setupUI()
        showPlaceholder()
        view.backgroundColor = .ypWhite
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidCreateTracker), name: Notification.Name("DidCreateTracker"), object: nil)
        trackerCategoryStore.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    // MARK: -  Setup UI
    
    private func setupUI() {
        
        [datePicker, collectionView, trackerLabel, searchStackView, placeholderImage, placeholderLabel, filterButton].forEach{
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
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant:  -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
            
            
        ])
    }
    
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
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func showPlaceholder() {
        let hasAnyTrackers = categories.contains { !$0.trackers.isEmpty }

        if !hasAnyTrackers {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
            placeholderImage.image = UIImage(named: "placeholder")
            placeholderLabel.text = NSLocalizedString("emptyState.title", comment: "Заглушка если трекеров совсем нет")
        } else if visibleCategories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
            placeholderImage.image = UIImage(named: "placeholder2")
            placeholderLabel.text = NSLocalizedString("emptySearchResult", comment: "Заглушка если выдача нулевая")
        } else {
            placeholderImage.isHidden = true
            placeholderLabel.isHidden = true
            filterButton.isHidden = false
        }
    }

    // MARK: -  Objc Private Properties
    
    @objc private func filtersButtonDidTap() {
        let filtersVC = FiltersViewController()
        filtersVC.selectedFilter = selectedFilter
        filtersVC.onFilterSelected = { [weak self] filter in
            self?.selectedFilter = filter
        }
        present(filtersVC, animated: true)
    }
    
    @objc private func handleDidCreateTracker() {
        reloadData()
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.reloadData()
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
    
    // MARK: - Private Methods Filters
    
    private func trackerPassesAllFilters(_ tracker: Tracker, on date: Date, searchText: String) -> Bool {
        let calendar = Calendar.current
        
        let textCondition = searchText.isEmpty || tracker.name.lowercased().contains(searchText.lowercased())
        
        let dateCondition: Bool
        if tracker.isHabit {
            let weekday = calendar.component(.weekday, from: date)
            let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
            dateCondition = tracker.schedule.contains { $0.numberValue == adjustedWeekday }
        } else {
            if let record = completedTrackers.first(where: { $0.trackerID == tracker.id }) {
                dateCondition = calendar.isDate(record.date, inSameDayAs: date)
            } else {
                dateCondition = calendar.isDateInToday(date) || date > Date()
            }
        }
        
        let filterCondition: Bool
        switch selectedFilter {
        case .completed:
            filterCondition = isTrackerCompleted(tracker, on: date)
        case .notCompleted:
            filterCondition = !isTrackerCompleted(tracker, on: date)
        default:
            filterCondition = true
        }
        return textCondition && dateCondition && filterCondition
    }
    
    private func reloadVisibleCategories() {
        if selectedFilter == .today {
            let today = Date()
            datePicker.setDate(today, animated: false)
            currentDate = today
        }

        guard let currentDate = currentDate else { return }

        let searchText = (searchTextField.text ?? "").lowercased()

        // Проверка наличия трекеров на текущую дату без фильтров
        let hasTrackersForDate = filteredCategories.contains { category in
            category.trackers.contains { tracker in
                isTrackerActiveOnDate(tracker, date: currentDate)
            }
        }
        filterButton.isHidden = !hasTrackersForDate

        // ---- Основная фильтрация для отображения ----

        // Фильтруем закреплённые трекеры
        let pinnedFilteredTrackers = pinnedTrackers.filter {
            trackerPassesAllFilters($0, on: currentDate, searchText: searchText)
        }

        visibleCategories = []

        if !pinnedFilteredTrackers.isEmpty {
            visibleCategories.append(TrackerCategory(title: "Закрепленные", trackers: pinnedFilteredTrackers))
        }

        let otherCategories = filteredCategories.compactMap { category -> TrackerCategory? in
            let trackers = category.trackers.filter { tracker in
                !pinnedTrackers.contains(where: { $0.id == tracker.id }) &&
                trackerPassesAllFilters(tracker, on: currentDate, searchText: searchText)
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }

        visibleCategories.append(contentsOf: otherCategories)

        collectionView.reloadData()
        showPlaceholder()
    }

    
    private func isTrackerActiveOnDate(_ tracker: Tracker, date: Date) -> Bool {
        let calendar = Calendar.current

        if tracker.isHabit {
            let weekday = calendar.component(.weekday, from: date)
            let adjustedWeekday = weekday == 1 ? 7 : weekday - 1
            return tracker.schedule.contains { $0.numberValue == adjustedWeekday }
        } else {
            // Просто считаем все не привычные трекеры активными на любую дату
            return true
        }
    }

    private func isCurrentDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
    
    // MARK: - Private Methods
    
    private func updateUIForSelectedFilter() {
        if selectedFilter == .today {
            datePicker.setDate(Date(), animated: true)
            currentDate = Date()
        }
        reloadVisibleCategories()
        showPlaceholder()
        
    }
    
    private func savePinnedTrackers() {
        let pinnedIDs = pinnedTrackers.map { $0.id.uuidString }
        UserDefaults.standard.set(pinnedIDs, forKey: pinnedTrackersKey)
    }
    
    private func loadPinnedTrackers() {
        guard let pinnedIDs = UserDefaults.standard.array(forKey: pinnedTrackersKey) as? [String] else {
            pinnedTrackers = []
            return
        }
        
        pinnedTrackers = trackers.filter { pinnedIDs.contains($0.id.uuidString) }
    }
    
    private func reloadData(){
        trackers = trackerStore.fetchTrackers()
        categories = trackerCategoryStore.fetchCategories()
        filteredCategories = categories
        completedTrackers = trackerRecordStore.fetch()
        loadPinnedTrackers()
        datePickerValueChanged()
        reloadVisibleCategories()
        showPlaceholder()
    }
    
    private func isTrackerCompletedToday(id:UUID) -> Bool {
        
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerID == id && isSameDay
        }
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        let calendar = Calendar.current
        return completedTrackers.contains {
            $0.trackerID == tracker.id && calendar.isDate($0.date, inSameDayAs: date)
        }
    }
    
    private func openEditScreen(with tracker: Tracker) {
        let editVC = NewHabitOrEventViewController()
        editVC.isEditingTracker = true
        editVC.trackerToEdit = tracker
        
        editVC.isHabit = tracker.isHabit
        self.present(editVC, animated: true)
    }
    
    // MARK: - UIContextMenu Methods
    
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
            pinnedTrackers.remove(at: index)
        } else {
            pinnedTrackers.append(tracker)
        }
        savePinnedTrackers()
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
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            let shouldRemove = trackerRecord.trackerID == id && isSameDay

            if shouldRemove {
                do {
                    try trackerRecordStore.delete(trackerRecord: trackerRecord)
                } catch {
                    print("Failed to delete tracker record: \(error)")
                }
            }
            return shouldRemove
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







