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
        title: "날짜",
        value: quest.dueDate?.yyyyMMdEE ?? "",
        buttonStyle: isEditingMode ? .rightArrowAction : .textOnly
    )
    
    private lazy var timeRowView = InfoRowView(
        leading: {
            let imageView = UIImageView(image: UIImage(systemName: "clock"))
            imageView.tintColor = .black
            return imageView
        }(),
        title: "시간",
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
        value: quest.assignedTo ?? "",
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
    private lazy var completeQuestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("퀘스트 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 12
        button
            .addTarget(
                self,
                action: #selector(completeQuestButtonTapped),
                for: .touchUpInside
            )
        button.backgroundColor = .mainOrange
        return button
    }()
    
    // TODO: - 반복타입 만들기
    
    // MARK: - Lifecycle
    
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupBindings()
        observeTextChanges()
        setupRowViewActions()
        applyEditingModeState()
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        // MARK: - 뷰 계층 설정
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
        view.addSubview(completeQuestButton)
        
        [scrollView, contentView, categoryIcon, titleLabel, categoryCarouselView, titleEditTextField,
         dateRowView, timeRowView, workerRowView, starRowView,
         memoStackView, memoTextView, completeQuestButton, memoTextViewPlaceholder
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
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 120),
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
            
            memoTextView.topAnchor.constraint(equalTo: memoStackView.bottomAnchor, constant: 12),
            memoTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            memoTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            memoTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            memoTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            memoTextViewPlaceholder.topAnchor.constraint(equalTo: memoTextView.topAnchor, constant: 8),
            memoTextViewPlaceholder.leadingAnchor.constraint(equalTo: memoTextView.leadingAnchor, constant: 8),
            
            completeQuestButton.leadingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20
                ),
            completeQuestButton.trailingAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20
                ),
            completeQuestButton.bottomAnchor
                .constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -20
                ),
            completeQuestButton.heightAnchor.constraint(equalToConstant: 50),
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
    }
    
    // MARK: - RowView Actions (날짜, 시간, 사람, 별)
    
    private func setupRowViewActions() {
        setupDateRowAction()
        setupTimeRowAction()
        setupWorkerRowMenu()
        setupStarRowMenu()
        setupCategorySelection()
    }
    
    private func setupDateRowAction() {
        dateRowView.onTap = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.presentDatePicker()
        }
    }
    
    private func setupTimeRowAction() {
        timeRowView.onTap = { [weak self] in
            guard let self = self, self.isEditingMode else { return }
            self.presentTimePicker()
        }
    }
    
    // 날짜 버튼 -> DatePicker
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
    
    // 시간 버튼 -> TimePicker
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
    
    // 담당 버튼 -> UIMenu(담당자 선택)
    private func setupWorkerRowMenu() {
        viewModel.fetchFamilyMembers()
        
        let menuActions = viewModel.familyMembers.map { member in
            UIAction(title: member.name) { [weak self] _ in
                self?.viewModel.updateWorker(member.name)
            }
        }
        
        let menu = UIMenu(title: "누구와 할까요?", children: menuActions)
        workerRowView.setupMenu(menu)
    }
    
    // 별 개수 선택
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
    
    // 카테고리 선택
    private func setupCategorySelection() {
        categoryCarouselView.onCategorySelected = { [weak self] category in
            self?.viewModel.updateCategory(category)
        }
    }
    
    // MARK: - Button, TextField Actions
    
    private func observeTextChanges() {
        titleEditTextField.addTarget(self, action: #selector(titleTextFieldChanged), for: .editingChanged)
        memoTextView.delegate = self
    }
    
    @objc private func editButtonTapped() {
        isEditingMode = true
    }
    
    @objc private func doneButtonTapped() {
        viewModel.saveChanges()
        isEditingMode = false
    }
    
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
    
    @objc private func titleTextFieldChanged() {
        viewModel.updateTitle(titleEditTextField.text ?? "")
    }
    
    // MARK: - EditMode에 따른 UI 변경
    
    private func applyEditingModeState() {
        if isEditingMode {
            applyEditModeUI()
        } else {
            applyReadModeUI()
        }
    }
    
    private func applyEditModeUI() {
        updateNavigationBarForEdit()
        updateRowViewsForEdit()
        updateContentForEdit()
    }
    
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
    
    private func updateRowViewsForEdit() {
        dateRowView.updateButtonStyle(.rightArrowAction, viewModel.selectedDate.yyyyMMdEE)
        timeRowView.updateButtonStyle(.rightArrowAction, viewModel.selectedTime.aHHmm)
        starRowView.updateButtonStyle(.rightArrowMenu, "\(viewModel.starCount) 개")
    }
    
    private func updateContentForEdit() {
        categoryIcon.isHidden = true
        titleLabel.isHidden = true
        completeQuestButton.isHidden = true
        
        categoryCarouselView.isHidden = false
        titleEditTextField.isHidden = false
        
        memoTextView.isEditable = true
        memoTextView.isSelectable = true
        
        titleEditTextField.text = viewModel.title
        categoryCarouselView.setInitialCategory(viewModel.category)
    }
    
    private func applyReadModeUI() {
        updateNavigationBarForRead()
        updateRowViewsForRead()
        updateContentForRead()
    }
    
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
    
    private func updateRowViewsForRead() {
        dateRowView.updateButtonStyle(.textOnly, viewModel.selectedDate.yyyyMMdEE)
        timeRowView.updateButtonStyle(.textOnly, viewModel.selectedTime.aHHmm)
        starRowView.updateButtonStyle(.textOnly, "\(viewModel.starCount) 개")
    }
    
    private func updateContentForRead() {
        categoryIcon.isHidden = false
        titleLabel.isHidden = false
        completeQuestButton.isHidden = false

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
    }
}

// MARK: - UITextViewDelegate

extension QuestDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updateDescription(textView.text)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        memoTextViewPlaceholder.isHidden = true
    }

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
