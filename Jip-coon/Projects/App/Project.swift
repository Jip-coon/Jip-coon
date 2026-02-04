//
//  Project.swift
//  Config
//
//  Created by 예슬 on 8/18/25.
//

import ProjectDescription

let project = Project(
    name: "Jip-coon",
    targets: [
        .target(
            name: "Jip-coon",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Jip-coon",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "Launch Screen.storyboard",
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
                                ],
                            ]
                        ]
                    ],
                    "CFBundleURLTypes": [
                        [
                            "CFBundleTypeRole": "Editor",
                            "CFBundleURLSchemes": ["com.googleusercontent.apps.930536285317-qhv64s0qc5u0peoi1j32vipm75msseau"]
                        ]
                    ],
                    "UIBackgroundModes": ["remote-notification"],
                    "NSUserNotificationsUsageDescription": "퀘스트 알림을 위해 알림 권한이 필요합니다."
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            entitlements: "Jip-coon.entitlements",
            dependencies: [
                .project(target: "Feature", path: .relativeToRoot("Projects/Feature")),
                .external(name: "FirebaseCore"),
                .external(name: "GoogleSignIn"),
                .external(name: "FirebaseMessaging")
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": "$(inherited) -ObjC",
                    "ENABLE_USER_SCRIPT_SANDBOXING": "NO"
                ]
            )
        ),
        .target(
            name: "Jip-coonTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Jip-coonTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Jip-coon")]
        ),
    ]
)
