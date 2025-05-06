//
//  AddNewCategoryViewController.swift
//  Tracker
//
//  Created by Olya on 05.05.2025.
//

import UIKit

protocol AddCategoryViewControllerDelegate: AnyObject {
    func didAddCategory(_ category: TrackerCategory)
}

class AddCategoryViewController: UIViewController {
    
    weak var delegate: AddCategoryViewControllerDelegate?
    var categoryToEdit: TrackerCategory?
    var categoryUpdated: ((TrackerCategory) -> Void)?
    
    private lazy var categoryNameTF: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .ypGray
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 16
        textField.placeholder = "Введите название категории"
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
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        return label
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(doneButtonTap), for: .touchUpInside)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        
        if let category = categoryToEdit {
            categoryNameTF.text = category.title
        }
        doneButtonIsAvailable()
    }
    
    @objc private func doneButtonTap() {
        guard let title = categoryNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else { return }
        
        let updatedCategory = TrackerCategory(
            title: title,
            trackers: categoryToEdit?.trackers ?? []
        )
        
        if categoryToEdit != nil {
            categoryUpdated?(updatedCategory)
        } else {
            delegate?.didAddCategory(updatedCategory)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func clearButtonDidTap(){
        categoryNameTF.text = ""
        
    }
    
    private func doneButtonIsAvailable() {
        let trimmedText = categoryNameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isNotEmpty = !trimmedText.isEmpty
        doneButton.isEnabled = isNotEmpty
        doneButton.backgroundColor = isNotEmpty ? .black : .ypLightGray
    }
    
    
    
    private func setupUI(){
        [categoryNameTF, categoryLabel, doneButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 27),
            
            categoryNameTF.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryNameTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTF.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 38),
            categoryNameTF.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    
    
}

extension AddCategoryViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        doneButtonIsAvailable()
        return true
    }
}
