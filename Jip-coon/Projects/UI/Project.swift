//
//  Project.swift
//  AppManifests
//
//  Created by 예슬 on 8/18/25.
//

import ProjectDescription

let project = Project(
    name: "UI",
    targets: [
        .target(
            name: "UI",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.jipcoon.UI",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: "Sources/**",
            resources: "Resources/**",
            dependencies: [],
            settings: .settings(
                base: [
                    "ENABLE_USER_SCRIPT_SANDBOXING": "NO"
                ]
            )
        ),
        .target(
            name: "UITests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jipcoon.uiTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            dependencies: [.target(name: "UI")]
        )
    ]
)
