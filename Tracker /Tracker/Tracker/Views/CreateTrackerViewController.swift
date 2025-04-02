//
//  TrackOrHabitView.swift
//  Tracker
//
//  Created by User on 30.03.2025.
//

import Foundation
import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private lazy var createHabitButton: UIButton = {
        let createHabitButton = UIButton()
        createHabitButton.setTitle("Привычка", for: .normal)
        createHabitButton.backgroundColor = .black
        createHabitButton.setTitleColor(.white, for: .normal)
        createHabitButton.layer.masksToBounds = true
        createHabitButton.layer.cornerRadius = 16
        createHabitButton.addTarget(self, action: #selector(createHabitButtonDidTap), for: .touchUpInside)
        return createHabitButton
    }()
    
    private lazy var createEventButton: UIButton = {
        let createEventButton = UIButton()
        createEventButton.setTitle("Нерегулярное событие", for: .normal)
        createEventButton.backgroundColor = .black
        createEventButton.setTitleColor(.white, for: .normal)
        createEventButton.layer.masksToBounds = true
        createEventButton.layer.cornerRadius = 16
        createEventButton.addTarget(self, action: #selector(createEventButtonDidTap), for: .touchUpInside)
        return createEventButton
    }()
    
    private lazy var createLabel: UILabel = {
        let createLable = UILabel()
        createLable.text = "Создание трекера"
        createLable.font = UIFont(name: "YSDisplay-Medium", size: 16)
        createLable.textColor = .black
        return createLable
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    private func setupUI(){
        [createHabitButton, createEventButton, createLabel].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            createHabitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createHabitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createHabitButton.heightAnchor.constraint(equalToConstant: 60),
            createHabitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -357),
            createEventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            createEventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            createEventButton.heightAnchor.constraint(equalToConstant: 60),
            createEventButton.topAnchor.constraint(equalTo: createHabitButton.bottomAnchor, constant: 16),
            createLabel.bottomAnchor.constraint(equalTo: createHabitButton.topAnchor, constant: -295),
            createLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func createHabitButtonDidTap(){
        let createNewHabitVC = NewHabitOrEventViewController()
        createNewHabitVC.isHabit = true
        present(createNewHabitVC, animated: true)
    }
    
    @objc private func createEventButtonDidTap(){
        let createNewEventVC = NewHabitOrEventViewController()
        createNewEventVC.isHabit = false
        present(createNewEventVC, animated: true)
    }
}
#Preview{
    CreateTrackerViewController()
}
