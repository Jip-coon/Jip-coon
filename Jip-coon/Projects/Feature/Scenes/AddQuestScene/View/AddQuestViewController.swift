//
//  AddQuestViewController.swift
//  Feature
//
//  Created by 예슬 on 9/8/25.
//

import UIKit
import Combine
import UI
import Core

final class AddQuestViewController: UIViewController {
    private let viewModel: AddQuestViewModel
    private var cancellables = Set<AnyCancellable>()

    init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol,
        questService: QuestServiceProtocol
    ) {
        self.viewModel = AddQuestViewModel(
            userService: userService,
            familyService: familyService,
            questService: questService
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
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
            buttonStyle: .capsuleMenu
        )
    }()
    
    // 별
    private let starInfoRowView: InfoRowView = {
        let imageView = UIImageView(
            image: UIImage(named: "Star", in: uiBundle, compatibleWith: nil)
        )
        imageView.contentMode = .scaleAspectFit
        return InfoRowView(
            leading: imageView,
            title: "별",
            value: "10 개",
            buttonStyle: .rightArrowMenu
        )
    }()
    
    // 반복
    private let scheduleRepeatView: ScheduleRepeatView = {
        let view = ScheduleRepeatView()
        return view
    }()
    
    private let missionAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("퀘스트 추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.backgroundColor = .mainOrange
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()         // UI 설정
        bindViewModel()     // ViewModel
        hideKeyboardWhenTappedAround()  // 키보드 관련
        setupInfoRowViewButtonAction()  // 버튼 액션 관리
    }
    
    // MARK: - 함수들
    
    private func setupView() {
        view.backgroundColor = .backgroundWhite
        navigationItem.title = "퀘스트 추가"
        
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
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
            scheduleRepeatView,
            missionAddButton
            
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
            scheduleRepeatView,
            missionAddButton
            
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate(
[
            scrollView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            containerView.topAnchor
                .constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            containerView.leadingAnchor
                .constraint(
                    equalTo: scrollView.contentLayoutGuide.leadingAnchor
                ),
            containerView.trailingAnchor
                .constraint(
                    equalTo: scrollView.contentLayoutGuide.trailingAnchor
                ),
            containerView.bottomAnchor
                .constraint(
                    equalTo: scrollView.contentLayoutGuide.bottomAnchor
                ),
            containerView.widthAnchor
                .constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            categoryCarouselView.topAnchor
                .constraint(equalTo: containerView.topAnchor, constant: 26),
            categoryCarouselView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor),
            categoryCarouselView.trailingAnchor
                .constraint(equalTo: containerView.trailingAnchor),
            categoryCarouselView.heightAnchor.constraint(equalToConstant: 110),
            
            titleTextField.topAnchor
                .constraint(
                    equalTo: categoryCarouselView.bottomAnchor,
                    constant: 36
                ),
            titleTextField.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            titleTextField.heightAnchor.constraint(equalToConstant: 35),
            
            memoTextField.topAnchor
                .constraint(equalTo: titleTextField.bottomAnchor, constant: 11),
            memoTextField.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            memoTextField.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            memoTextField.heightAnchor.constraint(equalToConstant: 35),
            
            dateInfoRowView.topAnchor
                .constraint(equalTo: memoTextField.bottomAnchor, constant: 40),
            dateInfoRowView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            dateInfoRowView.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            
            timeInfoRowView.topAnchor
                .constraint(
                    equalTo: dateInfoRowView.bottomAnchor,
                    constant: 31
                ),
            timeInfoRowView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            timeInfoRowView.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            
            workerInfoRowView.topAnchor
                .constraint(
                    equalTo: timeInfoRowView.bottomAnchor,
                    constant: 31
                ),
            workerInfoRowView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            workerInfoRowView.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            
            starInfoRowView.topAnchor
                .constraint(
                    equalTo: workerInfoRowView.bottomAnchor,
                    constant: 31
                ),
            starInfoRowView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            starInfoRowView.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            
            scheduleRepeatView.topAnchor
                .constraint(
                    equalTo: starInfoRowView.bottomAnchor,
                    constant: 42
                ),
            scheduleRepeatView.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            scheduleRepeatView.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            scheduleRepeatView.heightAnchor.constraint(equalToConstant: 75),
            
            missionAddButton.topAnchor
                .constraint(
                    equalTo: scheduleRepeatView.bottomAnchor,
                    constant: 47
                ),
            missionAddButton.leadingAnchor
                .constraint(equalTo: containerView.leadingAnchor, constant: 20),
            missionAddButton.trailingAnchor
                .constraint(
                    equalTo: containerView.trailingAnchor,
                    constant: -20
                ),
            missionAddButton.bottomAnchor
                .constraint(equalTo: containerView.bottomAnchor, constant: -34),
            missionAddButton.heightAnchor.constraint(equalToConstant: 47)
]
        )
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
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - 버튼 관련 함수
    
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
        
        // 카테고리
        categoryCarouselView.onCategorySelected = { [weak self] category in
            self?.viewModel.category = category
        }
        
        missionAddButton
            .addTarget(
                self,
                action: #selector(missionAddButtonTapped),
                for: .touchUpInside
            )
    }
    
    // 날짜 버튼 -> DatePicker
    private func presentDatePicker() {
        let datePickerViewController = DatePickerViewController(
            datePickerMode: .date
        )
        
        datePickerViewController.onDidTapDone = { [weak self] date in
            self?.dateInfoRowView.setValueText(date.yyyyMMdEE)
            self?.viewModel.selectedDate = date
            self?.viewModel.combineDateAndTime()
        }
        
        let navigationController = UINavigationController(
            rootViewController: datePickerViewController
        )
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    // 시간 버튼 -> TimePicker
    private func presentTimePicker() {
        let timePickerViewController = DatePickerViewController(
            datePickerMode: .time
        )
        
        timePickerViewController.onDidTapDone = { [weak self] date in
            self?.timeInfoRowView.setValueText(date.aHHmm)
            self?.viewModel.selectedTime = date
            self?.viewModel.combineDateAndTime()
        }
        
        let navigationController = UINavigationController(
            rootViewController: timePickerViewController
        )
        
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
                self?.viewModel
                    .selectWorker(with: member.name) // 선택된 이름으로 뷰모델의 상태 변경
            }
        }
        
        let menu = UIMenu(title: "누구와 할까요?", children: menuActions)
        
        workerInfoRowView.setupMenu(menu)
    }
    
    // 별 개수 선택
    private func setupStarSelectionMenu() {
        let menuActions = stride(
            from: 10,
            through: 50,
            by: 10
        ).map { starCount in
            let title = "\(starCount) 개"
            return UIAction(title: title) { [weak self] _ in
                self?.starInfoRowView.setValueText(title)
                self?.viewModel.starCount = starCount
            }
        }
        
        let menu = UIMenu(title: "별의 개수", children: menuActions)
        
        starInfoRowView.setupMenu(menu)
    }
    
    // 퀘스트추가 버튼
    @objc private func missionAddButtonTapped() {
        view.endEditing(true)

        // TODO: - 모든 정보 입력했는지 확인

        viewModel.title = titleTextField.text ?? ""
        viewModel.description = memoTextField.text ?? ""
        viewModel.questCreateDate = Date()

        // 비동기로 퀘스트 저장
        Task {
            do {
                try await viewModel.saveMission()
                // 퀘스트 생성 성공 알림 전송
                NotificationCenter.default.post(
                    name: NSNotification.Name("QuestCreated"),
                    object: nil
                )
                // 저장 성공 시 이전 화면으로 돌아가기
                navigationController?.popViewController(animated: true)
            } catch {
                // 에러 처리
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }

    private func showErrorAlert(message: String) {
        showAlert(title: "오류", message: message)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TextFieldDelegate

extension AddQuestViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleTextField {
            viewModel.title = textField.text ?? ""
        } else {
            viewModel.description = textField.text ?? ""
        }
    }
}
