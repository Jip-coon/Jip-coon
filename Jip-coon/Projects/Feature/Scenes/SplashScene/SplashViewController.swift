//
//  SplashViewController.swift
//  Feature
//
//  Created by 예슬 on 9/5/25.
//

import UIKit
import Lottie
import UI

public final class SplashViewController: UIViewController {
    private let animationView: LottieAnimationView = {
        let animationView = LottieAnimationView(name: "LaunchScreenText", bundle: uiBundle!)
        animationView.contentMode = .scaleAspectFit
        animationView.backgroundColor = .green
        animationView.play()
        return animationView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundWhite
        setupConstraints()
    }
    
    private func setupConstraints() {
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        let screenHeight = UIScreen.main.bounds.height
        let ratio: CGFloat = 185 / 874  // label topInset / iPhone 16Pro Height
        let topConstant: CGFloat = screenHeight * ratio
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topConstant),

        ])
        
        
    }

}
