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
      infoPlist: .default,
      sources: "Sources/**",
      resources: "Resources/**",
      dependencies: []
    ),
    .target(
        name: "UITests",
        destinations: .iOS,
        product: .unitTests,
        bundleId: "com.jipcoon.uiTests",
        infoPlist: .default,
        dependencies: [.target(name: "UI")]
    )
  ]
)
