//
//  QuickActionCollectionViewCell.swift
//  Feature
//
//  Created by 심관혁 on 9/17/25.
//

import Core
import UI
import UIKit

// MARK: - 빠른 액션 컬렉션뷰 셀

public class QuickActionCollectionViewCell: UICollectionViewCell {

    static let identifier = "QuickActionCollectionViewCell"

    var onTap: (() -> Void)?

    // MARK: - UI 구성요소

    private let iconLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.mainOrange
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    // MARK: - 초기화

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupTapGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 설정

    private func setupUI() {
        contentView.backgroundColor = UIColor.mainOrange.withAlphaComponent(0.1)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.mainOrange.withAlphaComponent(0.3).cgColor

        contentView.addSubview(iconLabel)
        contentView.addSubview(titleLabel)

        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconLabel.bottomAnchor, constant: 4),
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tapGesture)
        contentView.isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.contentView.alpha = 0.6
            }
        ) { _ in
            UIView.animate(withDuration: 0.1) {
                self.contentView.alpha = 1.0
            }
        }

        onTap?()
    }

    // MARK: - 구성

    func configure(with action: QuickAction, onTap: @escaping () -> Void) {
        self.onTap = onTap

        iconLabel.text = action.icon
        titleLabel.text = action.title
    }
}

// MARK: - 빠른 액션 모델

public struct QuickAction {
    let icon: String
    let title: String
    let type: ActionType

    enum ActionType {
        case newQuest
        case search
        case invite
        case approval
    }

    static let defaultActions: [QuickAction] = [
        QuickAction(icon: "➕", title: "새 퀘스트", type: .newQuest),
        QuickAction(icon: "🔍", title: "검색", type: .search),
        QuickAction(icon: "👥", title: "초대", type: .invite),
        QuickAction(icon: "✅", title: "승인", type: .approval),
    ]
}
