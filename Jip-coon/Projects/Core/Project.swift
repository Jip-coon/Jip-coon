//
//  Project.swift
//  AppManifests
//
//  Created by 예슬 on 8/18/25.
//

import ProjectDescription

let project = Project(
    name: "Core",
    targets: [
        .target(
            name: "Core",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.jipcoon.Core",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: "Sources/**",
            dependencies: [
                .external(name: "FirebaseFirestore"),
                .external(name: "FirebaseAuth"),
                .external(name: "FirebaseCore"),
                .external(name: "FirebaseMessaging"),
                .external(name: "GoogleSignIn"),
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                    "ENABLE_USER_SCRIPT_SANDBOXING": "NO"
                ]
            )
        ),
        .target(
            name: "CoreTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.jipcoon.coreTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            dependencies: [.target(name: "Core")]
        )
    ]
)
