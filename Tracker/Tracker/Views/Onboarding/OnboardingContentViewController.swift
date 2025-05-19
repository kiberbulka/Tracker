//
//  OnboardingContentViewController.swift
//  Tracker
//
//  Created by Olya on 03.05.2025.
//

import UIKit

class OnboardingContentViewController: UIViewController {
    
    private let imageName: String
    private let descriptionLabel: String
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlack
        
        let buttonText = NSLocalizedString("onboarding.button", comment: "Кнопка на экране онбординга")
        button.setTitle(buttonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        return button
    }()

    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: imageName))
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = descriptionLabel
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(imageName: String, descriptionLabel: String) {
        self.imageName = imageName
        self.descriptionLabel = descriptionLabel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        [imageView, label, button].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            button.heightAnchor.constraint(equalToConstant: 60),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
        
        
        
    }
}
