//
//  FamilyCreationLayout+Constraints.swift
//  Feature
//
//  Created by 심관혁 on 1/19/26.
//

import UI
import UIKit

// MARK: - Constraints Setup

extension FamilyCreationViewController {
    
    internal func setupConstraints() {
        [components.scrollView, components.contentView, components.modeSegmentControl, components.titleLabel, components.subtitleLabel,
         components.familyNameTextField, components.inviteCodeTextField, components.createButton, components.joinButton,
         components.inviteCodeView, components.doneButton, components.activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // ScrollView
            components.scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            components.scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            components.scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            components.scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // ContentView
            components.contentView.topAnchor.constraint(equalTo: components.scrollView.topAnchor),
            components.contentView.leadingAnchor.constraint(equalTo: components.scrollView.leadingAnchor),
            components.contentView.trailingAnchor.constraint(equalTo: components.scrollView.trailingAnchor),
            components.contentView.bottomAnchor.constraint(equalTo: components.scrollView.bottomAnchor),
            components.contentView.widthAnchor.constraint(equalTo: components.scrollView.widthAnchor),
            
            // Mode Segment Control
            components.modeSegmentControl.topAnchor.constraint(equalTo: components.contentView.topAnchor, constant: 40),
            components.modeSegmentControl.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.modeSegmentControl.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.modeSegmentControl.heightAnchor.constraint(equalToConstant: 36),
            
            // Title
            components.titleLabel.topAnchor.constraint(equalTo: components.modeSegmentControl.bottomAnchor, constant: 40),
            components.titleLabel.centerXAnchor.constraint(equalTo: components.contentView.centerXAnchor),
            
            // Subtitle
            components.subtitleLabel.topAnchor.constraint(equalTo: components.titleLabel.bottomAnchor, constant: 12),
            components.subtitleLabel.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.subtitleLabel.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            
            // TextFields
            components.familyNameTextField.topAnchor.constraint(equalTo: components.subtitleLabel.bottomAnchor, constant: 40),
            components.familyNameTextField.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.familyNameTextField.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.familyNameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            components.inviteCodeTextField.topAnchor.constraint(equalTo: components.subtitleLabel.bottomAnchor, constant: 40),
            components.inviteCodeTextField.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.inviteCodeTextField.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.inviteCodeTextField.heightAnchor.constraint(equalToConstant: 56),
            
            // Buttons
            components.createButton.topAnchor.constraint(equalTo: components.familyNameTextField.bottomAnchor, constant: 24),
            components.createButton.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.createButton.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.createButton.heightAnchor.constraint(equalToConstant: 56),
            
            components.joinButton.topAnchor.constraint(equalTo: components.inviteCodeTextField.bottomAnchor, constant: 24),
            components.joinButton.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.joinButton.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.joinButton.heightAnchor.constraint(equalToConstant: 56),
            
            // Activity Indicator
            components.activityIndicator.centerXAnchor.constraint(equalTo: components.contentView.centerXAnchor),
            components.activityIndicator.centerYAnchor.constraint(equalTo: components.contentView.centerYAnchor),
            
            // Invite Code View
            components.inviteCodeView.topAnchor.constraint(equalTo: components.createButton.bottomAnchor, constant: 40),
            components.inviteCodeView.leadingAnchor.constraint(equalTo: components.contentView.leadingAnchor, constant: 24),
            components.inviteCodeView.trailingAnchor.constraint(equalTo: components.contentView.trailingAnchor, constant: -24),
            components.inviteCodeView.heightAnchor.constraint(equalToConstant: 160),
            
            // Done Button
            components.doneButton.topAnchor.constraint(equalTo: components.inviteCodeView.bottomAnchor, constant: 40),
            components.doneButton.centerXAnchor.constraint(equalTo: components.contentView.centerXAnchor),
            components.doneButton.bottomAnchor.constraint(equalTo: components.contentView.bottomAnchor, constant: -40),
        ])
        
        // Invite Code View 내부 레이아웃
        [components.inviteCodeTitleLabel, components.inviteCodeLabel, components.shareButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            components.inviteCodeTitleLabel.topAnchor.constraint(equalTo: components.inviteCodeView.topAnchor, constant: 16),
            components.inviteCodeTitleLabel.centerXAnchor.constraint(equalTo: components.inviteCodeView.centerXAnchor),
            
            components.inviteCodeLabel.topAnchor.constraint(equalTo: components.inviteCodeTitleLabel.bottomAnchor, constant: 8),
            components.inviteCodeLabel.centerXAnchor.constraint(equalTo: components.inviteCodeView.centerXAnchor),
            
            components.shareButton.topAnchor.constraint(equalTo: components.inviteCodeLabel.bottomAnchor, constant: 16),
            components.shareButton.leadingAnchor.constraint(equalTo: components.inviteCodeView.leadingAnchor, constant: 24),
            components.shareButton.trailingAnchor.constraint(equalTo: components.inviteCodeView.trailingAnchor, constant: -24),
            components.shareButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}
