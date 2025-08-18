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
      bundleId: "com.jipcoon.feature",
      infoPlist: .default,
      sources: "Scenes/**",
      dependencies: []
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
