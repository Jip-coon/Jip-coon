//
//  MainViewLayout+HeaderConstraints.swift
//  Feature
//
//  Created by 심관혁 on 9/18/25.
//

import UI
import UIKit

// MARK: - Header Constraints Setup

extension MainViewLayout {

    internal func setupHeaderConstraints(in view: UIView) {
        NSLayoutConstraint.activate(
[
            // 헤더 제약조건
            components.headerView.topAnchor.constraint(equalTo: view.topAnchor),
            components.headerView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            components.headerView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            components.headerView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),

            // 사용자 프로필 뷰
            components.userProfileView.leadingAnchor.constraint(
                equalTo: components.headerView.leadingAnchor, constant: 20),
            components.userProfileView.centerYAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),

            components.profileImageView.leadingAnchor.constraint(
                equalTo: components.userProfileView.leadingAnchor),
            components.profileImageView.topAnchor.constraint(
                equalTo: components.userProfileView.topAnchor),
            components.profileImageView.widthAnchor
                .constraint(equalToConstant: 50),
            components.profileImageView.heightAnchor
                .constraint(equalToConstant: 50),

            components.userNameLabel.leadingAnchor.constraint(
                equalTo: components.profileImageView.trailingAnchor, constant: 12),
            components.userNameLabel.topAnchor
                .constraint(equalTo: components.userProfileView.topAnchor),
            components.userNameLabel.trailingAnchor.constraint(
                equalTo: components.userProfileView.trailingAnchor),

            components.pointsLabel.leadingAnchor.constraint(
                equalTo: components.profileImageView.trailingAnchor, constant: 12),
            components.pointsLabel.topAnchor.constraint(
                equalTo: components.userNameLabel.bottomAnchor, constant: 4),
            components.pointsLabel.trailingAnchor.constraint(
                equalTo: components.userProfileView.trailingAnchor),
            components.pointsLabel.bottomAnchor.constraint(
                equalTo: components.userProfileView.bottomAnchor),

            // 가족 정보 뷰
            components.familyInfoView.trailingAnchor.constraint(
                equalTo: components.headerView.trailingAnchor, constant: -20),
            components.familyInfoView.centerYAnchor.constraint(
                equalTo: components.userProfileView.centerYAnchor),

            // 스크롤뷰 제약조건
            components.scrollView.topAnchor
                .constraint(equalTo: components.headerView.bottomAnchor),
            components.scrollView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            components.scrollView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            components.scrollView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            // 콘텐츠뷰 제약조건
            components.contentView.topAnchor
                .constraint(
                    equalTo:components.scrollView.contentLayoutGuide.topAnchor
                ),
            components.contentView.leadingAnchor
                .constraint(
                    equalTo: components.scrollView.contentLayoutGuide.leadingAnchor
                ),
            components.contentView.trailingAnchor
                .constraint(
                    equalTo: components.scrollView.contentLayoutGuide.trailingAnchor
                ),
            components.contentView.bottomAnchor
                .constraint(
                    equalTo: components.scrollView.contentLayoutGuide.bottomAnchor
                ),
            components.contentView.widthAnchor
                .constraint(
                    equalTo: components.scrollView.frameLayoutGuide.widthAnchor
                ),

]
        )
    }
}
