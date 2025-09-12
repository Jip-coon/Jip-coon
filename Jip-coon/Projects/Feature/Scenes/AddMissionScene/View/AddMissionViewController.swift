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
    
    private let dateInfoRowView = InfoRowView(
        leading: {
            let label = UILabel()
            label.text = "📅"
            label.font = .systemFont(ofSize: 15)
            return label
        }(),
        title: "날짜",
        value: Date.now.yyyyMMdEE
    )
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        hideKeyboardWhenTappedAround()
        setupInfoRowViewButtonAction()
    }
    
    private func setupConstraints() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        [
            categoryCarouselView,
            titleTextField,
            memoTextField,
            dateInfoRowView,
            
        ].forEach(containerView.addSubview)
        
        [
            scrollView,
            containerView,
            categoryCarouselView,
            titleTextField,
            memoTextField,
            dateInfoRowView,
            
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
            
            dateInfoRowView.topAnchor.constraint(equalTo: memoTextField.bottomAnchor, constant: 40),
            dateInfoRowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateInfoRowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
    }
    
    // 키보드 숨기기
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupInfoRowViewButtonAction() {
        dateInfoRowView.onTap = { [weak self] in
            self?.presentDatePicker()
        }
    }
    
    private func presentDatePicker() {
        let datePickerViewController = DatePickerViewController(datePickerMode: .date)
        
        datePickerViewController.onDidTapDone = { [weak self] date in
            self?.dateInfoRowView.setValueText(date.yyyyMMdEE)
        }
        
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
}
