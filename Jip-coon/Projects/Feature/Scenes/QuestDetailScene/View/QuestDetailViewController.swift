//
//  QuestDetailViewController.swift
//  Feature
//
//  Created by 예슬 on 11/14/25.
//

import Core
import UI
import UIKit

final class QuestDetailViewController: UIViewController {
    
    private var quest: Quest
    
    private var isEditingMode: Bool = false {
        didSet {
            updateUIForEditingMode()
        }
    }
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let categoryCarouselView = CategoryCarouselView()
    private let titleEditTextField: UITextField = {
        let textField = UITextField()
        textField.font = .pretendard(ofSize: 20, weight: .semibold)
        textField.placeholder = "Placeholder"
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
    
    // 메모 영역
    private let memoLeadingLabel: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "text.page"))
        imageView.tintColor = .black
        return imageView
    }()
    
    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .pretendard(ofSize: 16, weight: .semibold)
        label.text = "메모"
        return label
    }()
    
    private let memoContentLabel = UILabel()
    private let memoEditTextField: UITextField = {
        let textField = UITextField()
        textField.font = .pretendard(ofSize: 16, weight: .regular)
        textField.placeholder = "Placeholder"
        textField.setPlaceholder(fontSize: 16)
        textField.layer.borderColor = UIColor.textFieldStroke.cgColor
        textField.layer.borderWidth = 0.7
        textField.layer.cornerRadius = 10
        textField.leftPadding()
        return textField
    }()
    
    // 하단 버튼
    private lazy var completeQuestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("퀘스트 완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .pretendard(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(completeQuestButtonTapped), for: .touchUpInside)
        button.backgroundColor = .mainOrange
        return button
    }()
    
    init(quest: Quest) {
        self.quest = quest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configureData()
    }
    
    private func setupLayout() {
        // MARK: - 뷰 계층 설정
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // 기본 모드 UI
        contentView.addSubview(categoryIcon)
        contentView.addSubview(titleLabel)
        
        // 수정 모드 UI
        contentView.addSubview(categoryCarouselView)
        contentView.addSubview(titleEditTextField)
        
        // 상세 내용
        contentView.addSubview(dateRowView)
        contentView.addSubview(timeRowView)
        contentView.addSubview(workerRowView)
        contentView.addSubview(starRowView)
        
        // 메모 섹션
        let memoStackView = UIStackView(arrangedSubviews: [memoLeadingLabel, memoTitleLabel])
        memoStackView.axis = .horizontal
        memoStackView.spacing = 8
        
        contentView.addSubview(memoStackView)
        contentView.addSubview(memoContentLabel)
        contentView.addSubview(memoEditTextField)
        
        view.addSubview(completeQuestButton)
        
        [scrollView, contentView, categoryIcon, titleLabel, categoryCarouselView, titleEditTextField,
         dateRowView, timeRowView, workerRowView, starRowView,
         memoStackView, memoContentLabel, memoEditTextField, completeQuestButton
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // MARK: - 제약 조건 설정
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            categoryIcon.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            categoryIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            categoryIcon.widthAnchor.constraint(equalToConstant: 80),
            categoryIcon.heightAnchor.constraint(equalToConstant: 80),
            
            categoryCarouselView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            categoryCarouselView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryCarouselView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            categoryCarouselView.heightAnchor.constraint(equalToConstant: 120),
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: categoryIcon.bottomAnchor, constant: 12),
            
            titleEditTextField.topAnchor.constraint(equalTo: categoryCarouselView.bottomAnchor, constant: 20),
            titleEditTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleEditTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            titleEditTextField.heightAnchor.constraint(equalToConstant: 35),
            
            dateRowView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 120),
            dateRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            timeRowView.topAnchor.constraint(equalTo: dateRowView.bottomAnchor, constant: 31),
            timeRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timeRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            workerRowView.topAnchor.constraint(equalTo: timeRowView.bottomAnchor, constant: 31),
            workerRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            workerRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            starRowView.topAnchor.constraint(equalTo: workerRowView.bottomAnchor, constant: 31),
            starRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            starRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            memoStackView.topAnchor.constraint(equalTo: starRowView.bottomAnchor, constant: 31),
            memoStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            memoContentLabel.topAnchor.constraint(equalTo: memoStackView.topAnchor),
            memoContentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            memoEditTextField.topAnchor.constraint(equalTo: memoStackView.bottomAnchor, constant: 12),
            memoEditTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            memoEditTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            memoEditTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            memoEditTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100),
            
            completeQuestButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            completeQuestButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            completeQuestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            completeQuestButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        // 초기 상태 UI 설정
        updateUIForEditingMode()
        
    }
    
    @objc private func editButtonTapped() {
        isEditingMode.toggle()
    }
    
    @objc private func completeQuestButtonTapped() {
        
    }
    
    private func setupInfoRowViewButtonAction() {
        dateRowView.onTap = { [weak self] in
            if self?.isEditingMode == true {
                //                    self?.presentDatePicker()
            }
        }
        timeRowView.onTap = { [weak self] in
            if self?.isEditingMode == true {
                //                    self?.presentTimePicker()
            }
        }
        
        // TODO: - 담당자
        // workerRowView.setupMenu(...)
        
        // TODO: - 별 개수
        // starRowView.setupMenu(...)
    }
    
    private func updateUIForEditingMode() {
        // 네비게이션 바 버튼 변경
        if isEditingMode {
            let saveButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = saveButton
            navigationItem.title = ""
        } else {
            let editButton = UIBarButtonItem(image: UIImage(systemName: "pencil"), style: .plain, target: self, action: #selector(editButtonTapped))
            navigationItem.rightBarButtonItem = editButton
            navigationItem.title = ""
        }
        
        // 중앙 UI 변경 (토글)
        categoryIcon.isHidden = isEditingMode
        titleLabel.isHidden = isEditingMode
        memoContentLabel.isHidden = isEditingMode
        
        categoryCarouselView.isHidden = !isEditingMode
        titleEditTextField.isHidden = !isEditingMode
        memoEditTextField.isHidden = !isEditingMode
        
        if isEditingMode {
            dateRowView.updateButtonStyle(.rightArrowAction, quest.dueDate?.yyyyMMdEE ?? "")
            timeRowView.updateButtonStyle(.rightArrowAction, quest.dueDate?.aHHmm ?? "")
            starRowView.updateButtonStyle(.rightArrowMenu, "\(quest.points) 개")
            categoryCarouselView.setInitialCategory(quest.category)
        } else {
            dateRowView.updateButtonStyle(.textOnly, quest.dueDate?.yyyyMMdEE ?? "")
            timeRowView.updateButtonStyle(.textOnly, quest.dueDate?.aHHmm ?? "")
            starRowView.updateButtonStyle(.textOnly, "\(quest.points) 개")
        }
        completeQuestButton.isHidden = isEditingMode ? true : false
    }
    
    // 날짜 버튼 -> DatePicker
    private func presentDatePicker() {
        let datePickerViewController = DatePickerViewController(datePickerMode: .date)
        
        datePickerViewController.onDidTapDone = { [weak self] date in
            self?.dateRowView.setValueText(date.yyyyMMdEE)
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
            self?.timeRowView.setValueText(date.aHHmm)
        }
        
        let navigationController = UINavigationController(rootViewController: timePickerViewController)
        
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationController, animated: true)
    }
    
    private func configureData() {
        titleLabel.text = quest.title
        titleEditTextField.text = quest.title
        memoContentLabel.text = quest.description
        memoEditTextField.text = quest.description
        categoryIcon.text = quest.category.emoji
        categoryIcon.backgroundColor = UIColor(named: quest.category.backgroundColor, in: uiBundle, compatibleWith: nil)
        dateRowView.setValueText(quest.dueDate?.yyyyMMdEE ?? "")
        timeRowView.setValueText(quest.dueDate?.aHHmm ?? "")
    }
}
