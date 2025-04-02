//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by User on 31.03.2025.
//

import Foundation
import UIKit

final class NewHabitOrEventViewController: UIViewController, CategorySelectionDelegate {
    

    var isHabit: Bool = true
    var selectedCategories: [String] = []
    var categoryCellIndexPath: IndexPath?

    
    private lazy var newHabitLabel: UILabel = {
        let newHabitLabel = UILabel()
        newHabitLabel.text = "Новая привычка"
        newHabitLabel.font = UIFont(name: "YSDisplay-Medium", size: 16)
        newHabitLabel.textColor = .black
        return newHabitLabel
    }()
    
    private lazy var trackerNameTF: UITextField = {
        let trackerNameTF = UITextField()
        trackerNameTF.backgroundColor = .ypGray
        trackerNameTF.layer.masksToBounds = true
        trackerNameTF.layer.cornerRadius = 16
        trackerNameTF.placeholder = "Введите название трекера"
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: trackerNameTF.frame.height))
        trackerNameTF.leftView = leftPaddingView
        let clearButton = UIButton(type: .custom)
        clearButton.setImage(.xmark, for: .normal)
              clearButton.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
              clearButton.addTarget(self, action: #selector(clearButtonDidTap), for: .touchUpInside)
              
              let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: clearButton.frame.width + 12, height: clearButton.frame.height))
              rightPaddingView.addSubview(clearButton)
              trackerNameTF.rightView = rightPaddingView
              trackerNameTF.rightViewMode = .whileEditing
        trackerNameTF.leftViewMode = .always
        return trackerNameTF
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var characterLimitLabel: UILabel = {
        let characterLimitLabel = UILabel()
        characterLimitLabel.textColor = .ypRed
        characterLimitLabel.text = "Ограничение 38 символов"
        characterLimitLabel.font = UIFont(name: "YSDisplay-Medium", size: 17)
        characterLimitLabel.textAlignment = .center
        characterLimitLabel.isHidden = true
        return characterLimitLabel
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.backgroundColor = .ypLightGray
        createButton.layer.masksToBounds = true
        createButton.layer.cornerRadius = 16
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.textColor = .white
        createButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        return createButton
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.bounces = false
        return tableView
    }()
    
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        habitOrEventLabel()
        tableView.delegate = self
        tableView.dataSource = self
        trackerNameTF.delegate = self
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
    
    func didSelectCategory(_ category: String) {
        if !selectedCategories.contains(category) {
                    selectedCategories.append(category)
                }

                // Обновляем отображение категорий в subtitle
                if let indexPath = categoryCellIndexPath {
                    if let cell = tableView.cellForRow(at: indexPath) {
                        // Объединяем все категории в одну строку
                        cell.detailTextLabel?.text = selectedCategories.joined(separator: ", ")
                    }
                }

                // Перезагружаем таблицу, чтобы обновить все данные
                tableView.reloadData()
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
               cell.selectionStyle = .none

               if indexPath.row == 0 {
                   cell.textLabel?.text = "Категория"
                   // Показываем все выбранные категории через запятую
                   cell.detailTextLabel?.text = selectedCategories.isEmpty ? "" : selectedCategories.joined(separator: ", ")
               } else {
                   cell.textLabel?.text = "Расписание"
               }

               return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
                 // Сохраняем индекс выбранной ячейки
                 categoryCellIndexPath = indexPath
                 let categoryVC = CategoryViewController()
                 categoryVC.delegate = self // Передаем делегат
                 present(categoryVC, animated: true)
             } else {
                 let scheduleVC = ScheduleViewController()
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
}
#Preview{
    NewHabitOrEventViewController()
}
