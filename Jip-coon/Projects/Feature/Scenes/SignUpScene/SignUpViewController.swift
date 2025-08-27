//
//  SignUpViewController.swift
//  Feature
//
//  Created by 예슬 on 8/27/25.
//

import UIKit
import UI

public final class SignUpViewController: UIViewController {
    private let signUpLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign Up"
        label.textColor = .mainOrange
        label.font = .systemFont(ofSize: 48, weight: .bold)
        return label
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = .backgroundWhite
        
        [signUpLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        [signUpLabel].forEach {
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            signUpLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 73),
            signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}
