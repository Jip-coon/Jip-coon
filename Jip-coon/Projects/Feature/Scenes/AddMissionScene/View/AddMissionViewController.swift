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
    private let categoryCarouselView = CategoryCarouselView()   // 카테고리 뷰
    
    // 제목, 메모 섹션
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
    
    // 날짜
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
    
    // 시간
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
    
    // 담당
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
    
    // 별
    private let starInfoRowView: InfoRowView = {
        let imageView = UIImageView(image: UIImage(named: "Star", in: uiBundle, compatibleWith: nil))
        imageView.contentMode = .scaleAspectFit
        return InfoRowView(
            leading: imageView,
            title: "별",
            value: "10 개",
            buttonStyle: .plainMenu
        )
    }()
    
    // 반복
    private let scheduleRepeatView: ScheduleRepeatView = {
        let view = ScheduleRepeatView()
        return view
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()  // UI 설정
        bindViewModel()     // ViewModel
        hideKeyboardWhenTappedAround()  // 키보드 관련
        setupInfoRowViewButtonAction()  // 버튼 액션 관리
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
            starInfoRowView,
            scheduleRepeatView
            
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
            starInfoRowView,
            scheduleRepeatView
            
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
            
            starInfoRowView.topAnchor.constraint(equalTo: workerInfoRowView.bottomAnchor, constant: 31),
            starInfoRowView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            starInfoRowView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            scheduleRepeatView.topAnchor.constraint(equalTo: starInfoRowView.bottomAnchor, constant: 42),
            scheduleRepeatView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scheduleRepeatView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            scheduleRepeatView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$selectedWorkerName
            .sink { [weak self] name in
                self?.workerInfoRowView.setValueText(name)
            }
            .store(in: &cancellables)
    }
    
    // 화면 탭하면 키보드 숨기기
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
        // 날짜
        dateInfoRowView.onTap = { [weak self] in
            self?.presentDatePicker()
        }
        
        // 시간
        timeInfoRowView.onTap = { [weak self] in
            self?.presentTimePicker()
        }
        
        setupWorkerSelectionMenu()  // 담당
        setupStarSelectionMenu()    // 별
        
        // 반복
        scheduleRepeatView.onDayButtonTapped = { [weak self] days in
            self?.viewModel.updateSelectedRepeatDays(days)
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
    
    // 담당 버튼 -> UIMenu(담당자 선택)
    private func setupWorkerSelectionMenu() {
        // TODO: - fetch 부분 수정
        viewModel.fetchFamilyMembers(for: "123")
        
        let menuActions = viewModel.familyMembers.map { member in
            UIAction(title: member.name) { [weak self] _ in
                self?.viewModel.selectWorker(with: member.name) // 선택된 이름으로 뷰모델의 상태 변경
            }
        }
        
        let menu = UIMenu(title: "누구와 할까요?", children: menuActions)
        
        workerInfoRowView.setupMenu(menu)
    }
    
    // 별 개수 선택
    private func setupStarSelectionMenu() {
        let menuActions = stride(from: 10, through: 50, by: 10).map { starCount in
            let title = "\(starCount) 개"
            return UIAction(title: title) { [weak self] _ in
                self?.starInfoRowView.setValueText(title)
            }
        }
        
        let menu = UIMenu(title: "별의 개수", children: menuActions)
        
        starInfoRowView.setupMenu(menu)
    }
}
