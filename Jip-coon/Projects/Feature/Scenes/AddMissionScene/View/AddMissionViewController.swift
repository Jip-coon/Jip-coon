//
//  AddMissionViewController.swift
//  Feature
//
//  Created by 예슬 on 9/8/25.
//

import UIKit
import UI

// TODO: - 나중에 public 지우기
public final class AddMissionViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let containerView = UIView()
    private let categoryCarouselView = CategoryCarouselView()
    
    private let titleTextField: TextFieldComponent = {
        let textFieldView = TextFieldComponent()
        textFieldView.configure(title: "제목", placeholder: "제목을 입력해 주세요")
        return textFieldView
    }()
    
    private let memoTextField: TextFieldComponent = {
        let textFieldView = TextFieldComponent()
        textFieldView.configure(title: "메모", placeholder: "(선택) 메모를 입력해 주세요")
        return textFieldView
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupConstraints() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [
            categoryCarouselView,
            titleTextField,
            memoTextField,
        ].forEach(containerView.addSubview)
        
        [
            scrollView,
            containerView,
            categoryCarouselView,
            titleTextField,
            memoTextField,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            categoryCarouselView.topAnchor.constraint(equalTo: containerView.topAnchor),
            categoryCarouselView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            categoryCarouselView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            categoryCarouselView.heightAnchor.constraint(equalToConstant: 110),
            
            titleTextField.topAnchor.constraint(equalTo: categoryCarouselView.bottomAnchor, constant: 36),
            titleTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            memoTextField.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 11),
            memoTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            memoTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            memoTextField.heightAnchor.constraint(equalToConstant: 35),
        ])
    }
    
    // 키보드 숨기기
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
