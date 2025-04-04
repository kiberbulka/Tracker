//
//  ViewController.swift
//  Tracker
//
//  Created by User on 20.03.2025.
//

import UIKit

class TrackerViewController: UIViewController {
    
    private var trackers: [Tracker] = []
    private var tracker: Tracker?
    
    
    private lazy var addTrackerButton: UIButton = {
        let addTrackerButton = UIButton()
        addTrackerButton.setImage(UIImage(named: "addTracker"), for: .normal)
        addTrackerButton.addTarget(self, action: #selector(createTrackerOrHabit), for: .touchUpInside)
        return addTrackerButton
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trackers = [
              Tracker(id: UUID(), name: "Трекер 1", emoji: "😊", color: .red, schedule: [], type: .habit),
              Tracker(id: UUID(), name: "Трекер 2", emoji: "😎", color: .blue, schedule: [], type: .habit)
          ]
        setupUI()
        showPlaceholder()
        view.backgroundColor = .white
        
    }
    
    private func showPlaceholder(){
        if trackers.isEmpty {
            placeholderImage.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
            placeholderImage.isHidden = true
        }
    }
    
    private func setupUI() {
        
        [datePicker, collectionView, addTrackerButton, trackerLabel, searchStackView, placeholderImage, placeholderLabel].forEach{
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
            collectionView.topAnchor.constraint(equalTo: searchStackView.bottomAnchor, constant: 54),
                        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)

            
        ])
    }
    
    @objc private func datePickerValueChanged(){
        
    }
    
    @objc private func createTrackerOrHabit(){
        let createTrackerVC = CreateTrackerViewController()
        createTrackerVC.delegate = self
        present(createTrackerVC, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    
    
    
}

extension TrackerViewController: UICollectionViewDelegate {
    
}

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.trackerCellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let tracker = trackers[indexPath.row]
        cell.configureCell(tracker: tracker, isCompletedToday: <#T##Bool#>)
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
    
}

extension TrackerViewController: NewHabitOrEventViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
          trackers.append(tracker)
          collectionView.reloadData()
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
}

    
    

#Preview {
    TrackerViewController()
}

