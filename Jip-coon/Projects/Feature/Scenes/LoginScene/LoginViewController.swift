//
//  LoginViewController.swift
//  Feature
//
//  Created by 예슬 on 8/21/25.
//

import UIKit
import UI

public class LoginViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let loginTitle: UILabel = {
        let label = UILabel()
        label.text = "Login"
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textColor = .mainOrange
        return label
    }()
    
    private let appleLoginButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "AppleLogin", in: uiBundle, compatibleWith: nil), for: .normal)
        return button
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpButtonAction()
    }
    
    private func setUpView() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(loginTitle)
        contentView.addSubview(appleLoginButton)
        
        [scrollView,
         contentView,
         loginTitle,
         appleLoginButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            loginTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            loginTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 91),
            
            appleLoginButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 706),
            appleLoginButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            appleLoginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -131)
        ])
    }
    
    private func setUpButtonAction() {
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
    }
    
    @objc private func appleLoginTapped() {
        print("apple login button tapped")
    }
    
}
