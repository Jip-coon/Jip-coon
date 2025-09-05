//
//  Project.swift
//  Config
//
//  Created by 예슬 on 8/18/25.
//

import ProjectDescription

let project = Project(
    name: "Feature",
    targets: [
        .target(
            name: "Feature",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jipcoon.Feature",
            infoPlist: .default,
            sources: "Scenes/**",
            dependencies: [
                .project(target: "Core", path: .relativeToRoot("Projects/Core")),
                .project(target: "UI", path: .relativeToRoot("Projects/UI")),
                .external(name: "FirebaseFirestore"),
                .external(name: "GoogleSignIn"),
                .external(name: "Lottie")
            ],
            settings: .settings(
                base: [
                    "ENABLE_USER_SCRIPT_SANDBOXING": "NO"
                ]
            )
        ),
        .target(
            name: "FeatureTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jipcoon.featureTests",
            infoPlist: .default,
            dependencies: [.target(name: "Feature")]
        )
    ]
)
