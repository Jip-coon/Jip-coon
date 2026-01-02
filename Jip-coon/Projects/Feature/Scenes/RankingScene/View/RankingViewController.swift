//
//  RankingViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/2/26.
//

import Core
import UIKit
import Combine

public final class RankingViewController: UIViewController {
    private let viewModel: RankingViewModel
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.register(RankingTableViewCell.self, forCellReuseIdentifier: RankingTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization
    public init(userService: UserServiceProtocol, familyService: FamilyServiceProtocol) {
        self.viewModel = RankingViewModel(userService: userService, familyService: familyService)
        self.userService = userService
        self.familyService = familyService
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        loadData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 화면이 나타날 때마다 데이터 새로고침
        refreshData()
    }

    // MARK: - Setup
    private func setupUI() {
        title = "가족 랭킹"
        view.backgroundColor = .systemGroupedBackground

        // TableView 설정
        view.addSubview(tableView)
        tableView.refreshControl = refreshControl

        // Loading Indicator 설정
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center

        // 제약조건 설정
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupBindings() {
        // ViewModel의 데이터 변경을 감지하여 UI 업데이트
        Task {
            await viewModel.$familyMembers
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.tableView.reloadData()
                }
                .store(in: &cancellables)
        }

        Task {
            await viewModel.$isLoading
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isLoading in
                    if isLoading {
                        self?.loadingIndicator.startAnimating()
                    } else {
                        self?.loadingIndicator.stopAnimating()
                        self?.refreshControl.endRefreshing()
                    }
                }
                .store(in: &cancellables)
        }

        Task {
            await viewModel.$errorMessage
                .receive(on: DispatchQueue.main)
                .sink { [weak self] errorMessage in
                    if let errorMessage = errorMessage {
                        self?.showErrorAlert(message: errorMessage)
                    }
                }
                .store(in: &cancellables)
        }
    }

    // MARK: - Data Loading
    private func loadData() {
        Task {
            await viewModel.loadRankingData()
        }
    }

    @objc private func refreshData() {
        viewModel.refreshData()
    }

    // MARK: - Helpers
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
}

// MARK: - UITableViewDataSource
extension RankingViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.familyMembers.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RankingTableViewCell.identifier, for: indexPath) as? RankingTableViewCell else {
            return UITableViewCell()
        }

        let member = viewModel.familyMembers[indexPath.row]
        let rank = indexPath.row + 1
        let isCurrentUser = member.id == viewModel.currentUser?.id

        cell.configure(with: member, rank: rank, isCurrentUser: isCurrentUser)

        return cell
    }
}

// MARK: - UITableViewDelegate
extension RankingViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 랭킹 항목 선택 시 추가 동작 (필요시 구현)
    }
}

// MARK: - RankingTableViewCell
private class RankingTableViewCell: UITableViewCell {
    static let identifier = "RankingTableViewCell"

    private let rankLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let pointsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .systemBlue
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let roleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(rankLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(pointsLabel)
        contentView.addSubview(roleLabel)

        NSLayoutConstraint.activate([
            rankLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            roleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            pointsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pointsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    func configure(with user: User, rank: Int, isCurrentUser: Bool) {
        rankLabel.text = user.rankEmoji(rank: rank)
        nameLabel.text = user.name
        pointsLabel.text = user.formattedPoints
        roleLabel.text = user.role.displayName

        // 현재 사용자 강조 표시
        if isCurrentUser {
            contentView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            nameLabel.textColor = .systemBlue
        } else {
            contentView.backgroundColor = .systemBackground
            nameLabel.textColor = .label
        }
    }
}
