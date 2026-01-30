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
        let animationView = LottieAnimationView(
            name: "LaunchScreenText",
            bundle: uiBundle!
        )
        animationView.contentMode = .scaleAspectFit
        animationView.play()
        return animationView
    }()
    
    private let jipCoonLabel: UILabel = {
        let label = UILabel()
        label.text = "집쿤"
        label.font = .npsExtraBold(ofSize: 36)
        label.textColor = .mainOrange
        label.alpha = 0
        return label
    }()
    
    private let jipCoonIcon: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(
                named: "Jip-coon_Icon",
                in: uiBundle!,
                compatibleWith: nil
            )
        )
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        jipCoonLabelAnimation()
    }
    
    private func setupConstraints() {
        view.backgroundColor = .backgroundWhite
        
        view.addSubview(jipCoonLabel)
        view.addSubview(animationView)
        view.addSubview(jipCoonIcon)
        
        jipCoonLabel.translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        jipCoonIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let screenHeight = UIScreen.main.bounds.height
        let ratio: CGFloat = 239 / 874  // label topInset / iPhone 16Pro Height
        let topConstant: CGFloat = screenHeight * ratio
        
        NSLayoutConstraint.activate(
[
            jipCoonLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jipCoonLabel.topAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: topConstant
                ),
            
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.bottomAnchor
                .constraint(equalTo: jipCoonLabel.topAnchor, constant: 20),
            
            jipCoonIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            jipCoonIcon.topAnchor
                .constraint(equalTo: jipCoonLabel.bottomAnchor, constant: 10),
            jipCoonIcon.widthAnchor.constraint(equalToConstant: 287),
            jipCoonIcon.heightAnchor.constraint(equalToConstant: 287)
]
        )
    }
    
    private func jipCoonLabelAnimation() {
        jipCoonLabel.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        
        UIView
            .animate(withDuration: 0.5, delay: 1.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: [], animations: {
                self.jipCoonLabel.alpha = 1
                self.jipCoonLabel.transform = .identity
            })
    }
    
}
