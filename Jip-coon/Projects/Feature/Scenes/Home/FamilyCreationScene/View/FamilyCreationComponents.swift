//
//  FamilyCreationComponents.swift
//  Feature
//
//  Created by 심관혁 on 1/19/26.
//

import Core
import UI
import UIKit

final class FamilyCreationComponents: NSObject {
    
    // MARK: - Delegate
    
    weak var delegate: FamilyCreationComponentsDelegate?
    
    // MARK: - UI Components
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.backgroundWhite
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundWhite
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = UIColor.textGray
        label.textAlignment = .center
        return label
    }()
    
    lazy var modeSegmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["가족 만들기", "가족 참여하기"])
        control.selectedSegmentIndex = 0
        control.backgroundColor = .white
        control.selectedSegmentTintColor = UIColor.mainOrange
        control.setTitleTextAttributes([.foregroundColor: UIColor.textGray], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        return control
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var familyNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "가족 이름을 입력하세요"
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.textColor = UIColor.textGray
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.returnKeyType = .done
        return textField
    }()
    
    lazy var inviteCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "초대코드를 입력하세요 (6자리 숫자)"
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.textColor = UIColor.textGray
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.keyboardType = .numberPad
        textField.returnKeyType = .done
        textField.isHidden = true
        return textField
    }()
    
    lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가족 생성하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.mainOrange
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var joinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가족 참여하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.mainOrange
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowRadius = 6
        button.addTarget(self, action: #selector(joinButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var inviteCodeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.mainOrange.cgColor
        view.isHidden = true
        return view
    }()
    
    lazy var inviteCodeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "초대코드"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.mainOrange
        return label
    }()
    
    lazy var inviteCodeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = UIColor.mainOrange
        label.textAlignment = .center
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("📤 공유하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = UIColor.mainOrange
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(UIColor.mainOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor.mainOrange
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Actions
    
    @objc private func modeChanged(_ sender: UISegmentedControl) {
        delegate?.didChangeMode(to: sender.selectedSegmentIndex)
    }
    
    @objc private func createButtonTapped() {
        delegate?.didTapCreateButton()
    }
    
    @objc private func joinButtonTapped() {
        delegate?.didTapJoinButton()
    }
    
    @objc private func shareButtonTapped() {
        delegate?.didTapShareButton()
    }
    
    @objc private func doneButtonTapped() {
        delegate?.didTapDoneButton()
    }
}

// MARK: - Delegate Protocol

protocol FamilyCreationComponentsDelegate: AnyObject {
    func didChangeMode(to index: Int)
    func didTapCreateButton()
    func didTapJoinButton()
    func didTapShareButton()
    func didTapDoneButton()
}
