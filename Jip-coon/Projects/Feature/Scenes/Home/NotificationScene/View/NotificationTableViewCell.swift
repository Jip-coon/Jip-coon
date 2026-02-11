//
//  NotificationTableViewCell.swift
//  Feature
//
//  Created by 예슬 on 2/11/26.
//

import UI
import UIKit

final class NotificationTableViewCell: UITableViewCell {
    
    static let identifier: String = NotificationTableViewCell.self.description()
    
    private let emojiContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 28
        view.clipsToBounds = true
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray2
        label.numberOfLines = 1
        return label
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
        dummyData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  setup
    
    private func setupUI() {
        contentView.addSubview(emojiContainer)
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorView)
        emojiContainer.addSubview(emojiLabel)
        
        emojiContainer.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            emojiContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emojiContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 56),
            emojiContainer.heightAnchor.constraint(equalToConstant: 56),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: emojiContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: emojiContainer.trailingAnchor, constant: 19),
            titleLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -15),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: emojiContainer.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -27),
            
            separatorView.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 18),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configureUI() {
        
    }
    
    private func dummyData() {
        emojiContainer.backgroundColor = .blue1
        emojiLabel.text = "😀"
        titleLabel.text = "Hello, World!"
        bodyLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
        dateLabel.text = "1d ago"
    }
    
}
