//
//  MainViewLayout.swift
//  Feature
//
//  Created by 심관혁 on 9/5/25.
//

import UI
import UIKit

public class MainViewLayout {

    internal let components: MainViewComponents

    public init(components: MainViewComponents) {
        self.components = components
    }

    public func setupViewHierarchy(in view: UIView) {
        view.addSubview(components.scrollView)
        components.scrollView.addSubview(components.contentView)
        view.addSubview(components.headerView)
        setupHeaderHierarchy()
        setupContentHierarchy()
    }

    public func setupConstraints(in view: UIView) {
        // 모든 뷰에 대해 translatesAutoresizingMaskIntoConstraints = false 설정
        setTranslatesAutoresizingMaskIntoConstraintsFalse()
        setupHeaderConstraints(in: view)
        setupSectionConstraints()
    }
}
