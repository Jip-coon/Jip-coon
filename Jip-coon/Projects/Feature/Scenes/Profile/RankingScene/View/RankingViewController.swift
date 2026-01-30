//
//  RankingViewController.swift
//  Feature
//
//  Created by 심관혁 on 1/2/26.
//

import Core
import UIKit
import Combine

/// 가족 구성원들의 포인트 기반 랭킹을 표시하는 뷰 컨트롤러
/// - 가족 서비스와 사용자 서비스를 통해 랭킹 데이터를 조회하고 표시
/// - 실시간 데이터 업데이트를 위한 리프레시 컨트롤 제공
/// - 현재 사용자를 강조 표시하여 자신의 순위를 쉽게 확인할 수 있도록 함
public final class RankingViewController: UIViewController {
    private let viewModel: RankingViewModel
    private let userService: UserServiceProtocol
    private let familyService: FamilyServiceProtocol

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView
            .register(
                RankingTableViewCell.self,
                forCellReuseIdentifier: RankingTableViewCell.identifier
            )
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl
            .addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Initialization

    /// 의존성 주입을 통한 초기화
    /// - Parameters:
    ///   - userService: 사용자 데이터 관리를 위한 서비스
    ///   - familyService: 가족 데이터 관리를 위한 서비스
    /// - Note: ViewModel과 서비스들을 주입받아 의존성을 외부에서 관리하도록 설계
    public init(
        userService: UserServiceProtocol,
        familyService: FamilyServiceProtocol
    ) {
        // ViewModel 생성 시 필요한 서비스들을 전달하여 의존성 주입
        self.viewModel = RankingViewModel(
            userService: userService,
            familyService: familyService
        )
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
            tableView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor
                .constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor
                .constraint(equalTo: view.centerYAnchor)
        ])
    }

    /// ViewModel의 상태 변경을 UI에 바인딩하는 메소드
    /// - 가족 구성원 데이터 변경 시 테이블뷰 리로드
    /// - 로딩 상태 변경 시 인디케이터 표시/숨김 처리
    /// - 에러 발생 시 사용자에게 알림 표시
    /// - Combine의 Publisher-Subscriber 패턴을 사용하여 반응형 UI 구현
    private func setupBindings() {
        // 가족 구성원 데이터가 변경될 때마다 테이블뷰를 새로고침
        // 메인 스레드에서 UI 업데이트를 수행하도록 보장
        viewModel.$familyMembers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)

        // 로딩 상태에 따라 인디케이터 표시/숨김 및 리프레시 컨트롤 종료 처리
        viewModel.$isLoading
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

        // 에러 메시지가 발생하면 사용자에게 알림 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.showErrorAlert(message: errorMessage)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    /// 초기 데이터 로딩을 수행하는 메소드
    /// - ViewModel의 loadRankingData()를 비동기로 호출하여 가족 랭킹 데이터 조회
    /// - Task를 사용하여 Swift Concurrency 기반 비동기 처리
    private func loadData() {
        Task {
            await viewModel.loadRankingData()
        }
    }

    /// 사용자 풀다운 제스처나 viewWillAppear 시 데이터 새로고침을 위한 메소드
    /// - ViewModel의 refreshData()를 호출하여 캐시 무효화 및 최신 데이터 재조회
    /// - UIRefreshControl의 타겟 액션으로 연결되어 있음
    @objc private func refreshData() {
        viewModel.refreshData()
    }

    // MARK: - Helpers
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
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
    public func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        // 랭킹 항목 선택 시 추가 동작 (필요시 구현)
    }
}

// MARK: - RankingTableViewCell

/// 가족 랭킹을 표시하기 위한 커스텀 테이블뷰 셀
/// - 순위, 이름, 포인트, 역할을 표시하는 컴포넌트들로 구성
/// - 현재 사용자인 경우 배경색과 텍스트 색상을 변경하여 강조 표시
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
            rankLabel.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 16),
            rankLabel.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 40),

            nameLabel.leadingAnchor
                .constraint(equalTo: rankLabel.trailingAnchor, constant: 16),
            nameLabel.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 12),

            roleLabel.leadingAnchor
                .constraint(equalTo: nameLabel.leadingAnchor),
            roleLabel.topAnchor
                .constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            pointsLabel.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pointsLabel.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor),
            pointsLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }

    /// 셀을 사용자 데이터로 설정하는 메소드
    /// - Parameters:
    ///   - user: 표시할 사용자 정보
    ///   - rank: 사용자의 현재 랭킹 순위
    ///   - isCurrentUser: 현재 앱 사용자인지를 나타내는 플래그
    /// - Note: User 모델의 계산 속성들을 활용하여 포맷된 데이터 표시
    ///        현재 사용자인 경우 시각적 강조를 통해 쉽게 구분 가능하도록 처리
    func configure(with user: User, rank: Int, isCurrentUser: Bool) {
        // 순위에 따른 이모지 표시 (1위🏆, 2위🥈, 3위🥉, 그 외 등수 표시)
        rankLabel.text = user.rankEmoji(rank: rank)
        // 사용자 이름 표시
        nameLabel.text = user.name
        // 포인트를 읽기 쉽게 포맷하여 표시 (예: "1,250 P")
        pointsLabel.text = user.formattedPoints
        // 사용자 역할 표시 (부모/자녀)
        roleLabel.text = user.role.displayName

        // 현재 로그인한 사용자를 시각적으로 강조 표시
        if isCurrentUser {
            contentView.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            nameLabel.textColor = .systemBlue
        } else {
            contentView.backgroundColor = .systemBackground
            nameLabel.textColor = .label
        }
    }
}
