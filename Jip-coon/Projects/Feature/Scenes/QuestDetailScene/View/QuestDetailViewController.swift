//
//  QuestDetailViewController.swift
//  Feature
//
//  Created by 예슬 on 11/14/25.
//

import Core
import Combine
import UI
import UIKit

final class QuestDetailViewController: UIViewController {
    
    private var quest: Quest
    private let viewModel: QuestDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private var isEditingMode: Bool = false {
        didSet {
            applyEditingModeState()
        }
    }
    
    // MARK: - View
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryCarouselView = CategoryCarouselView()
    private let titleEditTextField: UITextField = {
        let textField = UITextField()
        textField.font = .pretendard(ofSize: 20, weight: .semibold)
        textField.placeholder = "제목을 입력하세요"
        textField.textAlignment = .center
        textField.setPlaceholder(fontSize: 16)
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 10
        return textField
    }()
    
    private let categoryIcon: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 20, weight: .regular)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.cornerRadius = 12
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private lazy var dateRowView = InfoRowView(
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "calendar"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "마감일",
        value: quest.dueDate?.yyyyMMdEE ?? "",
        buttonStyle: isEditingMode ? .rightArrowAction : .textOnly
    )
    
    private lazy var timeRowView = InfoRowView(
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "clock"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "마감시간",
        value: quest.dueDate?.aHHmm ?? "",
        buttonStyle: isEditingMode ? .rightArrowAction : .textOnly
    )
    
    private lazy var workerRowView = InfoRowView(
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "person"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "사람",
        value: viewModel.selectedWorkerName,
        buttonStyle: .capsuleMenu
    )
    
    private lazy var starRowView = InfoRowView(
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "star"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "별",
        value: "\(quest.points) 개",
        buttonStyle: isEditingMode ? .rightArrowMenu : .textOnly
    )
    
    // 메모
    private let memoIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "text.page"))
        imageView.tintColor = .black
        return imageView
    }()
    
    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .regular)
        label.text = "메모"
        return label
    }()
    
    private let memoTextView: UITextView = {
        let textView = UITextView()
        textView.font = .pretendard(ofSize: 16, weight: .regular)
        textView.layer.borderColor = UIColor.textFieldStroke.cgColor
        textView.layer.borderWidth = 0.7
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }()
    
    private let memoTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "메모를 입력하세요"
        return label
    }()
    
    // 하단 버튼
    private let completeQuestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("퀘스트 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 12
        button.backgroundColor = .mainOrange
        return button
    }()
    
    // 반복
    private let scheduleRepeatView: ScheduleRepeatView = {
        let view = ScheduleRepeatView()
        return view
    }()
    
    // 종료일
    private lazy var scheduleEndDateView = InfoRowView (
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "calendar"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "반복 종료일",
        value: quest.recurringEndDate?.yyyyMMdEE ?? "",
        buttonStyle: isEditingMode ? .rightArrowAction : .textOnly
    )
    
    private let questDeleteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
        let image = UIImage(systemName: "trash", withConfiguration: symbolConfig)
        
        config.title = "퀘스트 삭제"
        config.image = image
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = .textRed
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .pretendard(ofSize: 16, weight: .regular)
        
        return button
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        return view
    }()
    
    // MARK: - init
    
    init(
        quest: Quest,
        questService: QuestServiceProtocol,
        userService: UserServiceProtocol
    ) {
        self.quest = quest
        self.viewModel = QuestDetailViewModel(
            quest: quest,
            questService: questService,
            userService: userService
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupBindings()
        observeTextChanges()
        setupRowViewActions()
        setupButtonActions()
        applyEditingModeState()
    }
    
    // MARK: - 뷰 계층 설정
    
    private func setupLayout() {
        view.backgroundColor = .backgroundWhite
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(categoryIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryCarouselView)
        contentView.addSubview(titleEditTextField)
        contentView.addSubview(dateRowView)
        contentView.addSubview(timeRowView)
        contentView.addSubview(workerRowView)
        contentView.addSubview(starRowView)
        
        // 메모 섹션
        let memoStackView = UIStackView(arrangedSubviews: [memoIconImageView, memoTitleLabel])
        
        memoStackView.axis = .horizontal
        memoStackView.spacing = 8
        
        contentView.addSubview(memoStackView)
        contentView.addSubview(memoTextView)
        memoTextView.addSubview(memoTextViewPlaceholder)
        contentView.addSubview(scheduleRepeatView)
        contentView.addSubview(scheduleEndDateView)
        contentView.addSubview(questDeleteButton)
        view.addSubview(bottomContainerView)
        bottomContainerView.addSubview(completeQuestButton)
        
        [
            scrollView,
            contentView,
            categoryIcon,
            titleLabel,
            categoryCarouselView,
            titleEditTextField,
            dateRowView,
            timeRowView,
            workerRowView,
            starRowView,
            memoStackView,
            memoTextView,
            bottomContainerView,
            completeQuestButton,
            memoTextViewPlaceholder,
            scheduleRepeatView,
            scheduleEndDateView,
            questDeleteButton
            
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // MARK: - 제약 조건 설정
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
                
                contentView.topAnchor
                    .constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                contentView.leadingAnchor
                    .constraint(
                        equalTo: scrollView.contentLayoutGuide.leadingAnchor
                    ),
                contentView.trailingAnchor
                    .constraint(
                        equalTo: scrollView.contentLayoutGuide.trailingAnchor
                    ),
                contentView.bottomAnchor
                    .constraint(
                        equalTo: scrollView.contentLayoutGuide.bottomAnchor
                    ),
                contentView.widthAnchor
                    .constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                
                categoryIcon.centerXAnchor
                    .constraint(equalTo: contentView.centerXAnchor),
                categoryIcon.topAnchor
                    .constraint(equalTo: contentView.topAnchor, constant: 20),
                categoryIcon.widthAnchor.constraint(equalToConstant: 80),
                categoryIcon.heightAnchor.constraint(equalToConstant: 80),
                
                categoryCarouselView.topAnchor
                    .constraint(equalTo: contentView.topAnchor, constant: 20),
                categoryCarouselView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor),
                categoryCarouselView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor),
                categoryCarouselView.heightAnchor.constraint(equalToConstant: 120),
                
                titleLabel.centerXAnchor
                    .constraint(equalTo: contentView.centerXAnchor),
                titleLabel.topAnchor
                    .constraint(equalTo: categoryIcon.bottomAnchor, constant: 12),
                
                titleEditTextField.topAnchor
                    .constraint(
                        equalTo: categoryCarouselView.bottomAnchor,
                        constant: 20
                    ),
                titleEditTextField.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                titleEditTextField.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                titleEditTextField.heightAnchor.constraint(equalToConstant: 35),
                
                dateRowView.topAnchor
                    .constraint(equalTo: titleEditTextField.bottomAnchor, constant: 20),
                dateRowView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                dateRowView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                timeRowView.topAnchor
                    .constraint(equalTo: dateRowView.bottomAnchor, constant: 31),
                timeRowView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                timeRowView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                workerRowView.topAnchor
                    .constraint(equalTo: timeRowView.bottomAnchor, constant: 31),
                workerRowView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                workerRowView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                starRowView.topAnchor
                    .constraint(equalTo: workerRowView.bottomAnchor, constant: 31),
                starRowView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                starRowView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                memoStackView.topAnchor
                    .constraint(equalTo: starRowView.bottomAnchor, constant: 31),
                memoStackView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                
                memoTextView.topAnchor
                    .constraint(equalTo: memoStackView.bottomAnchor, constant: 12),
                memoTextView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor, constant: 20),
                memoTextView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor, constant: -20),
                memoTextView.heightAnchor
                    .constraint(equalToConstant: 100),
                
                memoTextViewPlaceholder
                    .topAnchor.constraint(equalTo: memoTextView.topAnchor, constant: 8),
                memoTextViewPlaceholder
                    .leadingAnchor.constraint(equalTo: memoTextView.leadingAnchor, constant: 8),
                
                scheduleRepeatView
                    .topAnchor.constraint(equalTo: memoTextView.bottomAnchor, constant: 20),
                scheduleRepeatView
                    .leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scheduleRepeatView
                    .trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                scheduleRepeatView
                    .heightAnchor.constraint(equalToConstant: 75),
                
                scheduleEndDateView
                    .topAnchor.constraint(equalTo: scheduleRepeatView.bottomAnchor, constant: 20),
                scheduleEndDateView
                    .leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                scheduleEndDateView
                    .trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                
                questDeleteButton
                    .topAnchor.constraint(equalTo: scheduleEndDateView.bottomAnchor, constant: 65),
                questDeleteButton
                    .centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                questDeleteButton
                    .bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
                
                bottomContainerView.topAnchor
                    .constraint(equalTo: completeQuestButton.topAnchor, constant: -10),
                bottomContainerView.leadingAnchor
                    .constraint(equalTo: view.leadingAnchor),
                bottomContainerView.trailingAnchor
                    .constraint(equalTo: view.trailingAnchor),
                bottomContainerView.bottomAnchor
                    .constraint(equalTo: view.bottomAnchor),
                
                completeQuestButton.leadingAnchor
                    .constraint(equalTo: bottomContainerView.leadingAnchor, constant: 20),
                completeQuestButton.trailingAnchor
                    .constraint(equalTo: bottomContainerView.trailingAnchor, constant: -20),
                completeQuestButton.bottomAnchor
                    .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                completeQuestButton.heightAnchor
                    .constraint(equalToConstant: 50),
            ]
        )
    }
    
    // MARK: - ViewModel Binding
    
    private func setupBindings() {
        viewModel.$quest
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedQuest in
                self?.applyEditingModeState()
            }
            .store(in: &cancellables)
        
        // 카테고리 변경 구독
        viewModel.$category
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryIcon.text = category.emoji
                self?.categoryIcon.backgroundColor = UIColor(
                    named: category.backgroundColor,
                    in: uiBundle,
                    compatibleWith: nil
                )
            }
            .store(in: &cancellables)
        
        // 날짜 변경 구독
        viewModel.$selectedDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] date in
                self?.dateRowView.setValueText(date.yyyyMMdEE)
            }
            .store(in: &cancellables)
        
        // 시간 변경 구독
        viewModel.$selectedTime
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.timeRowView.setValueText(time.aHHmm)
            }
            .store(in: &cancellables)
        
        // 가족 이름 가져오기
        viewModel.$familyMembers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] members in
                guard !members.isEmpty else { return }
                self?.setupWorkerRowMenu()
            }
            .store(in: &cancellables)
        
        // 담당자 변경 구독
        viewModel.$selectedWorkerName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                self?.workerRowView.setValueText(name)
            }
            .store(in: &cancellables)
        
        // 별 개수 변경 구독
        viewModel.$starCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] count in
                self?.starRowView.setValueText("\(count) 개")
            }
            .store(in: &cancellables)
        
        // 반복 요일 설정
        viewModel.$selectedRepeatDays
            .receive(on: DispatchQueue.main)
            .sink { [weak self] days in
                self?.scheduleRepeatView.updateDays(days)
            }
            .store(in: &cancellables)
        
        // 삭제 성공
        viewModel.deleteSuccess
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        // 에러 메시지 설정
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    self?.showErrorAlert(message: error)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - RowView Actions (날짜, 시간, 사람, 별)
    
    private func setupRowViewActions() {
        setupDateRowAction()
        setupTimeRowAction()
        setupStarRowMenu()
        setupCategorySelection()
        setupRepeatDaysRowAction()
        setupRecurringEndDateRowAction()
    }
    
    /// 날짜 설정
    private func setupDateRowAction() {
        dateRowView.onTap = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.presentDatePicker()
        }
    }
    
    /// 시간 설정
    private func setupTimeRowAction() {
        timeRowView.onTap = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.presentTimePicker()
        }
    }
    
    /// 담당 버튼 -> UIMenu(담당자 선택)
    private func setupWorkerRowMenu() {
        let menuActions = viewModel.familyMembers.map { member in
            UIAction(title: member.name) { [weak self] _ in
                self?.viewModel.updateWorker(member.name)
                self?.viewModel.selectedWorkerID = member.id
            }
        }
        
        let menu = UIMenu(title: "누구와 할까요?", children: menuActions)
        workerRowView.setupMenu(menu)
    }
    
    /// 별 개수 선택
    private func setupStarRowMenu() {
        let menuActions = stride(
            from: 10,
            through: 50,
            by: 10
        ).map { starCount in
            let title = "\(starCount) 개"
            return UIAction(title: title) { [weak self] _ in
                self?.viewModel.updateStarCount(starCount)
            }
        }
        
        let menu = UIMenu(title: "별의 개수", children: menuActions)
        starRowView.setupMenu(menu)
    }
    
    /// 카테고리 선택
    private func setupCategorySelection() {
        categoryCarouselView.onCategorySelected = { [weak self] category in
            guard let self = self, self.isEditingMode else { return }
            self.viewModel.updateCategory(category)
        }
    }
    
    /// 반복 퀘스트 요일 선택
    private func setupRepeatDaysRowAction() {
        scheduleRepeatView.onDayButtonTapped = { [weak self] days in
            guard let self = self, self.isEditingMode else { return }
            self.viewModel.updateSelectedRepeatDays(days)
        }
    }
    
    /// 종료일 선택
    private func setupRecurringEndDateRowAction() {
        scheduleEndDateView.onTap = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.presentScheduleEndDatePicker()
        }
    }
    
    /// 날짜 버튼 -> DatePicker
    private func presentDatePicker() {
        let datePickerViewController = DatePickerViewController(datePickerMode: .date)
        
        datePickerViewController.onDidTapDone = { [weak self] date in
            self?.viewModel.updateDate(date)
        }
        
        let navigationController = UINavigationController(rootViewController: datePickerViewController)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    /// 시간 버튼 -> TimePicker
    private func presentTimePicker() {
        let timePickerViewController = DatePickerViewController(datePickerMode: .time)
        
        timePickerViewController.onDidTapDone = { [weak self] date in
            self?.viewModel.updateTime(date)
        }
        
        let navigationController = UINavigationController(rootViewController: timePickerViewController)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    /// 종료 날짜 버튼 -> DatePicker
    private func presentScheduleEndDatePicker() {
        let datePickerViewController = DatePickerViewController(
            datePickerMode: .date
        )
        
        datePickerViewController.onDidTapDone = { [weak self] date in
            self?.scheduleEndDateView.setValueText(date.yyyyMMdEE)
            self?.viewModel.recurringEndDate = date
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
    
    // MARK: - Button, TextField Actions
    
    /// 텍스트필드, 텍스트뷰 setup
    private func observeTextChanges() {
        titleEditTextField.addTarget(
            self,
            action: #selector(titleTextFieldChanged),
            for: .editingChanged
        )
        memoTextView.delegate = self
    }
    
    /// Button setup
    private func setupButtonActions() {
        completeQuestButton.addTarget(
            self,
            action: #selector(completeQuestButtonTapped),
            for: .touchUpInside
        )
        
        questDeleteButton.addTarget(
            self,
            action: #selector(questDeleteButtonTapped),
            for: .touchUpInside
        )
    }
    
    /// 수정 버튼 눌렸을 때
    @objc private func editButtonTapped() {
        isEditingMode = true
    }
    
    /// 수정 모드에서 완료 버튼 눌렸을 때
    @objc private func doneButtonTapped() {
        Task {
            try await viewModel.saveChanges()
        }
        isEditingMode = false
    }
    
    /// 퀘스트 완료 버튼 눌렸을 때
    @objc private func completeQuestButtonTapped() {
        Task {
            do {
                try await viewModel.completeQuest()
                // 성공 시 메인 화면으로 돌아가기
                navigationController?.popViewController(animated: true)
            } catch {
                showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    /// 퀘스트 삭제 버튼 눌렀을 때
    @objc private func questDeleteButtonTapped() {
        presentDeleteAlert()
    }
    
    /// 제목 텍스트필드 내용 바뀔 때
    @objc private func titleTextFieldChanged() {
        viewModel.updateTitle(titleEditTextField.text ?? "")
    }
    
    func presentDeleteAlert() {
        // 1. 반복 퀘스트인 경우
        if quest.templateId != nil {
            let actionSheet = UIAlertController(
                title: "반복 퀘스트 삭제",
                message: "이 퀘스트는 반복 일정입니다. 삭제 범위를 선택해주세요.",
                preferredStyle: .actionSheet
            )
            
            // 옵션 1: 이 일정만 삭제
            let deleteSingleAction = UIAlertAction(
                title: "이 일정만 삭제",
                style: .destructive
            ) { [weak self] _ in
                guard let self = self else { return }
                // 현재 반복 퀘스트 중에서 이 일정이 마지막인지 확인
                if viewModel.isLastRecurringQuest() {
                    // 마지막 일정일 경우 두 번째 알림창 생성
                    let lastAlert = UIAlertController(
                        title: "마지막 일정 삭제",
                        message: "이 일정을 삭제하면 더 이상 화면에 이 반복 퀘스트가 나타나지 않습니다.",
                        preferredStyle: .alert
                    )
                    
                    lastAlert.addAction(
                        UIAlertAction(title: "삭제 진행", style: .destructive) { _ in
                            self.viewModel.deleteQuest(mode: .all)
                        }
                    )
                    lastAlert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    
                    self.present(lastAlert, animated: true)
                } else {
                    // 마지막이 아니라면 바로 삭제
                    self.viewModel.deleteQuest(mode: .single)
                }
            }
            
            // 옵션 2: 반복 일정 모두 삭제
            let deleteAllAction = UIAlertAction(
                title: "반복 일정 모두 삭제",
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.deleteQuest(mode: .all)
            }
            
            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel
            )
            
            actionSheet.addAction(deleteSingleAction)
            actionSheet.addAction(deleteAllAction)
            actionSheet.addAction(cancelAction)
            
            // iPad 대응 (iPad는 actionSheet를 띄울 때 popover 설정이 필요함)
            if let popoverController = actionSheet.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(
                    x: self.view.bounds.midX,
                    y: self.view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popoverController.permittedArrowDirections = []
            }
            
            self.present(actionSheet, animated: true)
        }
        // 2. 일반 퀘스트인 경우 (단순 Alert 사용)
        else {
            let alert = UIAlertController(
                title: "퀘스트 삭제",
                message: "정말로 이 퀘스트를 삭제하시겠습니까?",
                preferredStyle: .alert
            )
            
            let deleteAction = UIAlertAction(
                title: "삭제",
                style: .destructive
            ) { [weak self] _ in
                self?.viewModel.deleteQuest(mode: .all)
            }
            
            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel
            )
            
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - EditMode에 따른 UI 변경 (수정모드)
    
    /// 수정 모드 또는 읽기 모드 적용
    private func applyEditingModeState() {
        if isEditingMode {
            applyEditModeUI()
        } else {
            applyReadModeUI()
        }
    }
    
    /// (수정모드) UI 변경
    private func applyEditModeUI() {
        updateNavigationBarForEdit()
        updateRowViewsForEdit()
        updateContentForEdit()
    }
    
    /// (수정모드) 네비게이션 UI 변경
    private func updateNavigationBarForEdit() {
        let saveButton = UIBarButtonItem(
            title: "완료",
            style: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        saveButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.title = ""
    }
    
    /// (수정모드) 날짜, 시간, 별 UI 변경
    private func updateRowViewsForEdit() {
        dateRowView.updateButtonStyle(.rightArrowAction, viewModel.selectedDate.yyyyMMdEE)
        timeRowView.updateButtonStyle(.rightArrowAction, viewModel.selectedTime.aHHmm)
        starRowView.updateButtonStyle(.rightArrowMenu, "\(viewModel.starCount) 개")
        scheduleEndDateView.updateButtonStyle(.rightArrowAction, viewModel.recurringEndDate?.yyyyMMdEE ?? Date().yyyyMMdEE)
        workerRowView.isUserInteractionEnabled = true
    }
    
    /// (수정모드) 모드에 맞게 UI 숨기기 또는 보이기
    private func updateContentForEdit() {
        categoryIcon.isHidden = true
        titleLabel.isHidden = true
        completeQuestButton.isHidden = true
        bottomContainerView.isHidden = true
        
        categoryCarouselView.isHidden = false
        titleEditTextField.isHidden = false
        
        memoTextView.isEditable = true
        memoTextView.isSelectable = true
        
        titleEditTextField.text = viewModel.title
        categoryCarouselView.setInitialCategory(viewModel.category)
        
        if let memo = viewModel.description {
            memoTextView.text = memo
            memoTextViewPlaceholder.isHidden = true
        }
        
        scheduleRepeatView.setEnabled(true)
    }
    
    // MARK: - EditMode에 따른 UI 변경 (읽기모드)
    
    /// (읽기모드) UI 변경
    private func applyReadModeUI() {
        updateNavigationBarForRead()
        updateRowViewsForRead()
        updateContentForRead()
    }
    
    /// (읽기모드) 네비게이션 UI 변경
    private func updateNavigationBarForRead() {
        let editButton = UIBarButtonItem(
            image: UIImage(systemName: "pencil"),
            style: .plain,
            target: self,
            action: #selector(editButtonTapped)
        )
        navigationItem.rightBarButtonItem = editButton
        navigationItem.title = ""
    }
    
    /// (읽기모드) 날짜, 시간, 별 UI 변경
    private func updateRowViewsForRead() {
        dateRowView.updateButtonStyle(.textOnly, viewModel.selectedDate.yyyyMMdEE)
        timeRowView.updateButtonStyle(.textOnly, viewModel.selectedTime.aHHmm)
        starRowView.updateButtonStyle(.textOnly, "\(viewModel.starCount) 개")
        scheduleEndDateView.updateButtonStyle(.textOnly, viewModel.recurringEndDate?.yyyyMMdEE ?? Date().yyyyMMdEE)
        workerRowView.isUserInteractionEnabled = false
    }
    
    /// (읽기모드) 모드에 맞게 UI 숨기기 또는 보이기
    private func updateContentForRead() {
        categoryIcon.isHidden = false
        titleLabel.isHidden = false
        completeQuestButton.isHidden = false
        bottomContainerView.isHidden = false
        
        categoryCarouselView.isHidden = true
        titleEditTextField.isHidden = true
        
        memoTextView.isEditable = false
        memoTextView.isSelectable = true
        memoTextView.isUserInteractionEnabled = true
        
        titleLabel.text = viewModel.title
        categoryIcon.text = viewModel.category.emoji
        categoryIcon.backgroundColor = UIColor(
            named: viewModel.category.backgroundColor,
            in: uiBundle,
            compatibleWith: nil
        )
        
        if let memo = viewModel.description {
            memoTextView.text = memo
            memoTextViewPlaceholder.isHidden = true
        }
        
        scheduleRepeatView.setEnabled(false)
    }
    
    /// 에러 메시지 알림창
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension QuestDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateDescription(textView.text)
        memoTextViewPlaceholder.isHidden = !textView.text.isEmpty
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        memoTextViewPlaceholder.isHidden = true
    }
}
