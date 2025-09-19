//
//  MainViewComponents.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import Core
import UI
import UIKit

public class MainViewComponents: NSObject {

    // MARK: - 데이터 소스

    public var urgentQuests: [Quest] = []
    public var onUrgentTaskTap: ((Quest) -> Void)?

    public var myTasks: [Quest] = []
    public var onMyTaskTap: ((Quest) -> Void)?

    public var categoryStats: [String: Int] = [:]
    public var onCategoryStatTap: ((String, Int) -> Void)?

    public var quickActions: [QuickAction] = QuickAction.defaultActions
    public var onQuickActionTap: ((QuickAction) -> Void)?

    public var recentActivities: [RecentActivity] = []
    public var onRecentActivityTap: ((RecentActivity) -> Void)?

    // MARK: - UI Components

    public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = UIColor.backgroundWhite
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.backgroundWhite
        return view
    }()

    public lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.headerBeige
        return view
    }()

    public lazy var userProfileView: UIView = {
        let view = UIView()
        return view
    }()

    public lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = UIColor.mainOrange
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()

    public lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "홍길동(부모)"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.textGray
        return label
    }()

    public lazy var pointsLabel: UILabel = {
        let label = UILabel()
        label.text = "0 포인트"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var familyInfoView: UIView = {
        let view = UIView()
        return view
    }()

    public lazy var familyNameLabel: UILabel = {
        let label = UILabel()
        label.text = "가족이름"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor.textGray
        return label
    }()

    public lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔔 2", for: .normal)
        button.setTitleColor(UIColor.mainOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()

    public lazy var urgentSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var urgentTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🚨 긴급 할일"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.textRed
        return label
    }()

    public lazy var urgentCountLabel: UILabel = {
        let label = UILabel()
        label.text = "3개"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textRed
        return label
    }()

    public lazy var myTasksSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var myTasksTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📌 내가 담당한 할일"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var statsSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var statsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📊 이번 주 현황"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = UIColor.mainOrange
        progressView.trackTintColor = UIColor.systemGray5
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        return progressView
    }()

    public lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.text = "75%"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var quickActionsSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var quickActionsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "⚡ 빠른 액션"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var recentActivitySectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var recentActivityTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "📰 최근 활동"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var achievementSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.applyCardStyle()
        return view
    }()

    public lazy var achievementTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "🏆 이번 주 성취"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor.mainOrange
        return label
    }()

    public lazy var achievementLabel: UILabel = {
        let label = UILabel()
        label.text = "🎉 5일 연속 할일 완료!\n💪 청소 마스터 달성!"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.textGray
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    // MARK: - Collection Views

    public lazy var urgentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0  // 셀 간 간격 제거
        layout.minimumLineSpacing = 12  // 페이지 간 간격
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false

        collectionView.isPagingEnabled = false  // 커스텀 페이징 사용
        collectionView.decelerationRate = .fast
        collectionView.contentInsetAdjustmentBehavior = .never  // 안전 영역 자동 조정 비활성화

        collectionView.register(
            UrgentTaskCollectionViewCell.self,
            forCellWithReuseIdentifier: UrgentTaskCollectionViewCell.identifier)
        collectionView.register(
            EmptyUrgentTaskCollectionViewCell.self,
            forCellWithReuseIdentifier: EmptyUrgentTaskCollectionViewCell.identifier)

        return collectionView
    }()

    // 긴급 할 일 페이지 인디케이터
    public lazy var urgentPageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = 0  // 동적으로 설정
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.textGray.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = UIColor.mainOrange
        pageControl.hidesForSinglePage = true
        pageControl.isUserInteractionEnabled = true
        return pageControl
    }()

    public lazy var myTasksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false

        collectionView.register(
            MyTasksCollectionViewCell.self,
            forCellWithReuseIdentifier: MyTasksCollectionViewCell.identifier)
        collectionView.register(
            EmptyMyTasksCollectionViewCell.self,
            forCellWithReuseIdentifier: EmptyMyTasksCollectionViewCell.identifier)

        return collectionView
    }()

    public lazy var categoryStatsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false

        collectionView.register(
            CategoryStatsCollectionViewCell.self,
            forCellWithReuseIdentifier: CategoryStatsCollectionViewCell.identifier)
        collectionView.register(
            EmptyCategoryStatsCollectionViewCell.self,
            forCellWithReuseIdentifier: EmptyCategoryStatsCollectionViewCell.identifier)

        return collectionView
    }()

    public lazy var quickActionsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false

        collectionView.register(
            QuickActionCollectionViewCell.self,
            forCellWithReuseIdentifier: QuickActionCollectionViewCell.identifier)

        return collectionView
    }()

    public lazy var recentActivityCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets.zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false

        collectionView.register(
            RecentActivityCollectionViewCell.self,
            forCellWithReuseIdentifier: RecentActivityCollectionViewCell.identifier)
        collectionView.register(
            EmptyRecentActivityCollectionViewCell.self,
            forCellWithReuseIdentifier: EmptyRecentActivityCollectionViewCell.identifier)

        return collectionView
    }()

    public override init() {
        super.init()
        setupCollectionViews()
    }

    // MARK: - Collection View Setup

    func setupCollectionViews() {
        urgentCollectionView.dataSource = self
        urgentCollectionView.delegate = self

        myTasksCollectionView.dataSource = self
        myTasksCollectionView.delegate = self

        categoryStatsCollectionView.dataSource = self
        categoryStatsCollectionView.delegate = self

        quickActionsCollectionView.dataSource = self
        quickActionsCollectionView.delegate = self

        recentActivityCollectionView.dataSource = self
        recentActivityCollectionView.delegate = self
    }
}
