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
      infoPlist: .default,
      sources: "Sources/**",
      dependencies: [
        .external(name: "FirebaseFirestore"),
        .external(name: "FirebaseAuth"),
        .external(name: "FirebaseCore")
      ]
    ),
    .target(
        name: "CoreTests",
        destinations: .iOS,
        product: .unitTests,
        bundleId: "com.jipcoon.coreTests",
        infoPlist: .default,
        dependencies: [.target(name: "Core")]
    )
  ]
)
