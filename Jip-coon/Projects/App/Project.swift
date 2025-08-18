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
                ]
            ),
            sources: ["Sources/**"],
            resources: ["Resources/**"],
            dependencies: []
        ),
        .target(
            name: "Jip-coonTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.Jip-coonTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "Jip-coon")]
        ),
    ]
)
