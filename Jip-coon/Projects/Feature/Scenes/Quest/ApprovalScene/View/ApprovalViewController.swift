//
//  ApprovalViewController.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import UIKit
import Core
import Combine

/// 승인 대기 중인 퀘스트들을 표시하고 승인/거절할 수 있는 화면을 담당하는 뷰 컨트롤러
/// - 부모/관리자가 자녀들의 완료된 퀘스트를 검토하고 승인하거나 거절할 수 있는 인터페이스 제공
/// - Combine을 활용한 반응형 UI로 실시간 데이터 업데이트
/// - 빈 상태 표시와 로딩 상태 관리를 통해 사용자 경험 개선
final class ApprovalViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: ApprovalViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .headerBeige
        tableView.separatorStyle = .none
        tableView
            .register(
                PendingQuestCell.self,
                forCellReuseIdentifier: PendingQuestCell.identifier
            )
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true

        let imageView = UIImageView(
            image: UIImage(systemName: "checkmark.circle")
        )
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "승인 대기 중인 퀘스트가 없습니다"
        label.font = .pretendard(ofSize: 16, weight: .regular)
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor
                .constraint(equalTo: view.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48),

            label.topAnchor
                .constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - 초기화

    /// 의존성 주입을 통한 초기화
    /// - Parameters:
    ///   - questService: 퀘스트 상태 변경 및 조회를 위한 서비스
    ///   - userService: 사용자 정보 및 포인트 관리를 위한 서비스
    /// - Note: ApprovalViewModel을 생성하여 승인 로직을 분리하고
    ///         서비스들을 외부에서 주입받아 테스트 용이성을 확보
    init(questService: QuestServiceProtocol, userService: UserServiceProtocol) {
        self.viewModel = ApprovalViewModel(
            questService: questService,
            userService: userService
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }

    // MARK: - Setup

    private func setupUI() {
        title = "승인 대기"
        view.backgroundColor = .headerBeige

        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)

        [tableView, emptyStateView, loadingIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            tableView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor
                .constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -40),

            loadingIndicator.centerXAnchor
                .constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor
                .constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// ViewModel의 데이터 변경을 UI에 바인딩하는 메소드
    /// - 승인 대기 퀘스트 목록 변경 시 테이블뷰 리로드 및 빈 상태 표시
    /// - 로딩 상태 변경 시 인디케이터 표시/숨김 처리
    /// - 에러 발생 시 사용자에게 알림 표시
    /// - Combine의 Publisher-Subscriber 패턴을 통해 반응형 UI 구현
    private func setupBindings() {
        // 승인 대기 퀘스트 목록이 변경될 때 UI 업데이트
        viewModel.$pendingQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quests in
                self?.updateUI(with: quests)
            }
            .store(in: &cancellables)

        // 로딩 상태에 따라 인디케이터 표시/숨김
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        // 에러 메시지가 발생하면 사용자에게 알림 표시
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        Task {
            await viewModel.loadPendingQuests()
        }
    }

    private func updateUI(with quests: [Quest]) {
        tableView.reloadData()
        emptyStateView.isHidden = !quests.isEmpty
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

// MARK: - UITableViewDataSource

extension ApprovalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pendingQuests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PendingQuestCell.identifier, for: indexPath) as? PendingQuestCell else {
            return UITableViewCell()
        }

        let quest = viewModel.pendingQuests[indexPath.row]
        cell.configure(with: quest)

        cell.onApprove = { [weak self] quest in
            self?.showApproveConfirmation(for: quest)
        }

        cell.onReject = { [weak self] quest in
            self?.showRejectDialog(for: quest)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ApprovalViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - 승인/거절 액션 처리

extension ApprovalViewController {
    /// 퀘스트 승인 확인 다이얼로그를 표시하는 메소드
    /// - Parameter quest: 승인할 퀘스트
    /// - Note: 승인 시 지급될 포인트를 표시하여 사용자에게 확인 요청
    ///         승인 후에는 ViewModel을 통해 실제 승인 처리 수행
    private func showApproveConfirmation(for quest: Quest) {
        let alert = UIAlertController(
            title: "퀘스트 승인",
            message: "'\(quest.title)'을(를) 승인하시겠습니까?\n\(quest.points)포인트가 지급됩니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert
            .addAction(
                UIAlertAction(title: "승인", style: .default) { [weak self] _ in
                    Task {
                        await self?.viewModel.approveQuest(quest)
                    }
                })

        present(alert, animated: true)
    }

    /// 퀘스트 거절 다이얼로그를 표시하는 메소드
    /// - Parameter quest: 거절할 퀘스트
    /// - Note: 선택적으로 거절 사유를 입력받을 수 있는 텍스트 필드 제공
    ///         거절은 승인보다 엄격한 액션이므로 destructive 스타일 사용
    private func showRejectDialog(for quest: Quest) {
        let alert = UIAlertController(
            title: "퀘스트 거절",
            message: "'\(quest.title)'을(를) 거절하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "거절 사유 (선택사항)"
        }

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert
            .addAction(
                UIAlertAction(title: "거절", style: .destructive) { [weak self] _ in
                    let reason = alert.textFields?.first?.text
                    Task {
                        await self?.viewModel.rejectQuest(quest, reason: reason)
                    }
                })

        present(alert, animated: true)
    }
}
