//
//  ViewController.swift
//  Tracker
//
//  Created by User on 20.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private var trackers: [Tracker] = []
    private var tracker: Tracker?
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currenDate: Date?
    private let dataManager = DataManager.shared
    
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
        label.font = UIFont(name: "YSDisplay-Bold", size: 34)
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
        searchTextField.delegate = self
        searchTextField.clearButtonMode = .never
        searchTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.ypLightGray
        ]
        let attributedPlaceholder = NSAttributedString(
            string: "Поиск",
            attributes: attributes)
        searchTextField.attributedPlaceholder = attributedPlaceholder
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
        placeholderLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        return placeholderLabel
    }()
    
    // MARK: - Initializers
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    @objc private func handleDidCreateTracker() {
        reloadData()
        collectionView.reloadData()
        showPlaceholder()
    }
    
    private func showPlaceholder(){
        if visibleCategories.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
            placeholderImage.isHidden = true
        }
    }
    
    private func reloadData(){
        categories = dataManager.categories
        datePickerValueChanged()
        collectionView.reloadData()
        showPlaceholder()
    }
    
    private func setupUI() {
        
        [datePicker, collectionView, trackerLabel, searchStackView, placeholderImage, placeholderLabel, addTrackerButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            addTrackerButton.heightAnchor.constraint(equalToConstant: 42),
            addTrackerButton.widthAnchor.constraint(equalToConstant: 42),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: addTrackerButton.bottomAnchor, constant: 1),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -16),
            searchStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 92),
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
        let calendar = Calendar.current
        let filteredWeekday = calendar.component(.weekday, from: datePicker.date)
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.contains { weekDay in
                    weekDay.numberValue == filteredWeekday
                } == true
            }
            
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(title: category.title, trackers: trackers)
        }
        
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
    
}

extension TrackerViewController: UICollectionViewDelegate {
    
}

extension TrackerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else {
            return 0
        }
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

extension TrackerViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
    }
}

extension TrackerViewController: TrackerCellDelegate {
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(trackerID: id, date: datePicker.date)
        completedTrackers.append(trackerRecord)
        
        collectionView.reloadItems(at: [indexPath])
    }
    
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll() { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.trackerID == id && isSameDay
        }
        collectionView.reloadItems(at: [indexPath])
    }
}

extension TrackerViewController: NewHabitOrEventViewControllerDelegate {
    func didCreateTrackerOrEvent(tracker: Tracker) {
        trackers.append(tracker)
        reloadData()
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout{
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




