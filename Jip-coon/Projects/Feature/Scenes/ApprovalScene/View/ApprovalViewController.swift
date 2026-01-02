//
//  ApprovalViewController.swift
//  Feature
//
//  Created by 심관혁 on 12/31/25.
//

import UIKit
import Core
import Combine

final class ApprovalViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: ApprovalViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .headerBeige
        tableView.separatorStyle = .none
        tableView.register(PendingQuestCell.self, forCellReuseIdentifier: PendingQuestCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true

        let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle"))
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
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])

        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization

    init(questService: QuestServiceProtocol, userService: UserServiceProtocol) {
        self.viewModel = ApprovalViewModel(questService: questService, userService: userService)
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
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.$pendingQuests
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quests in
                self?.updateUI(with: quests)
            }
            .store(in: &cancellables)

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
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
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

// MARK: - Actions

extension ApprovalViewController {
    private func showApproveConfirmation(for quest: Quest) {
        let alert = UIAlertController(
            title: "퀘스트 승인",
            message: "'\(quest.title)'을(를) 승인하시겠습니까?\n\(quest.points)포인트가 지급됩니다.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "승인", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.approveQuest(quest)
            }
        })

        present(alert, animated: true)
    }

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
        alert.addAction(UIAlertAction(title: "거절", style: .destructive) { [weak self] _ in
            let reason = alert.textFields?.first?.text
            Task {
                await self?.viewModel.rejectQuest(quest, reason: reason)
            }
        })

        present(alert, animated: true)
    }
}
