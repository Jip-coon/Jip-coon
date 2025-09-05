//
//  SplashViewController.swift
//  Feature
//
//  Created by 예슬 on 9/5/25.
//

import UIKit
import UI

public final class SplashViewController: UIViewController {
    private let havingFunHouseworkLabel: UILabel = {
       let label = UILabel()
        label.text = "집안일을 재밌게"
        label.font = UIFont.npsExtraBold(ofSize: 36)
        return label
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundWhite
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(havingFunHouseworkLabel)
        havingFunHouseworkLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let screenHeight = UIScreen.main.bounds.height
        let ratio: CGFloat = 185 / 874  // label topInset / iPhone 16Pro Height
        let topConstant: CGFloat = screenHeight * ratio
        
        NSLayoutConstraint.activate([
            havingFunHouseworkLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            havingFunHouseworkLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstant)
        ])
        
        
    }

}
