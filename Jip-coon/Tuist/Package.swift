// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [
            "FirebaseCore": .staticLibrary,
            "FirebaseAuth": .staticLibrary,
            "FirebaseFirestore": .staticLibrary,
        ]
    )
#endif

let package = Package(
    name: "Jip-coon",
    dependencies: [
        // Add your own dependencies here:
      .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.1.0"),
      .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "9.0.0")
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)
