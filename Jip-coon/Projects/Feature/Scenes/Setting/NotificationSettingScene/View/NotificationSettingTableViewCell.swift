//
//  NotificationSettingTableViewCell.swift
//  Feature
//
//  Created by 예슬 on 2/6/26.
//

import Core
import UI
import UIKit

final class NotificationSettingTableViewCell: UITableViewCell {
    
    static let identifier: String = NotificationSettingTableViewCell.self.description()
    
    private var type: NotificationSettingType?
    var onToggle: ((NotificationSettingType, Bool) -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 1
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .systemGray2
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let toggleSwitch: UISwitch = {
        let toggleSwitch = UISwitch()
        toggleSwitch.onTintColor = .blue1
        toggleSwitch.addTarget(
            self,
            action: #selector(toggleChanged),
            for: .valueChanged
        )
        return toggleSwitch
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        return view
    }()
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - configure UI
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(toggleSwitch)
        contentView.addSubview(separatorView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            toggleSwitch.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor),
            toggleSwitch.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            titleLabel.topAnchor
                .constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor
                .constraint(equalTo: toggleSwitch.leadingAnchor, constant: -30),
            
            descriptionLabel.topAnchor
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor
                .constraint(equalTo: toggleSwitch.leadingAnchor, constant: -30),
            
            separatorView.topAnchor
                .constraint(equalTo: descriptionLabel.bottomAnchor, constant: 15),
            separatorView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor, constant: 18),
            separatorView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor, constant: -18),
            separatorView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor
                .constraint(equalToConstant: 1)
        ])
    }
    
    func configureUI(type: NotificationSettingType, isOn: Bool) {
        self.type = type
        
        titleLabel.text = type.title
        descriptionLabel.text = type.description
        toggleSwitch.isOn = isOn
    }
    
    @objc private func toggleChanged(_ sender: UISwitch) {
        guard let type else { return }
        onToggle?(type, sender.isOn)
    }
    
}
