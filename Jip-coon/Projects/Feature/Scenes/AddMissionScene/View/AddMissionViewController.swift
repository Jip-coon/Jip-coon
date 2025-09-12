//
//  AddMissionViewController.swift
//  Feature
//
//  Created by 예슬 on 9/8/25.
//

import UIKit
import Combine
import UI

// TODO: - 나중에 public 지우기
public final class AddMissionViewController: UIViewController {
    private let viewModel = AddMissionViewModel()
    private var cancellables = Set<AnyCancellable>()
    
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
    
    private let dateInfoRowView: InfoRowView = {
        let label = UILabel()
        label.text = "📅"
        label.font = .systemFont(ofSize: 15)
        return InfoRowView(
            leading: label,
            title: "날짜",
            value: Date.now.yyyyMMdEE
        )
    }()
    
    private let timeInfoRowView: InfoRowView = {
        let label = UILabel()
        label.text = "⏰"
        label.font = .systemFont(ofSize: 15)
        return InfoRowView(
            leading: label,
            title: "시간",
            value: Date.now.aHHmm
        )
    }()
    
    private let workerInfoRowView: InfoRowView = {
        let label = UILabel()
        label.text = "👤"
        label.font = .systemFont(ofSize: 15)
        return InfoRowView(
            leading: label,
            title: "담당",
            value: "선택해 주세요",
            buttonStyle: .capsule
        )
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        bindViewModel()
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
            timeInfoRowView,
            workerInfoRowView,
            
        ].forEach(containerView.addSubview)
        
        [
            scrollView,
            containerView,
            categoryCarouselView,
            titleTextField,
            memoTextField,
            dateInfoRowView,
            timeInfoRowView,
            workerInfoRowView,
            
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
            
            timeInfoRowView.topAnchor.constraint(equalTo: dateInfoRowView.bottomAnchor, constant: 31),
            timeInfoRowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            timeInfoRowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            workerInfoRowView.topAnchor.constraint(equalTo: timeInfoRowView.bottomAnchor, constant: 31),
            workerInfoRowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            workerInfoRowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
    }
    
    private func bindViewModel() {
        viewModel.$selectedWorkerName
            .sink { [weak self] name in
                // 선택된 이름이 변경되면 workerInfoRowView의 값 업데이트
                self?.workerInfoRowView.setValueText(name)
            }
            .store(in: &cancellables)
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
    
    // 각 버튼 액션 정의
    private func setupInfoRowViewButtonAction() {
        dateInfoRowView.onTap = { [weak self] in
            self?.presentDatePicker()
        }
        timeInfoRowView.onTap = { [weak self] in
            self?.presentTimePicker()
        }
        workerInfoRowView.onTap = { [weak self] in
            self?.presentWorkerSelectionMenu()
        }
    }
    
    // 날짜 버튼 -> DatePicker
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
    
    // 시간 버튼 -> TimePicker
    private func presentTimePicker() {
        let timePickerViewController = DatePickerViewController(datePickerMode: .time)
        
        timePickerViewController.onDidTapDone = { [weak self] date in
            self?.timeInfoRowView.setValueText(date.aHHmm)
        }
        
        let navigationController = UINavigationController(rootViewController: timePickerViewController)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    // 담당 버튼 -> Alert ActionSheet(담당자 선택)
    private func presentWorkerSelectionMenu() {
        viewModel.fetchFamilyMembers(for: "123")
        let alertController = UIAlertController(title: "누구와 할까요?", message: nil, preferredStyle: .actionSheet)
        
        // ViewModel에서 가족 구성원 목록을 가져와서 액션시트에 추가
        for member in viewModel.familyMembers {
            let action = UIAlertAction(title: member.name, style: .default) { [weak self] _ in
                self?.viewModel.selectWorker(with: member.name)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}
