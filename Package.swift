// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

fileprivate let firebaseVersion: Version = Version(9, 0, 0)
fileprivate let firebasePackageName: String = "firebase-ios-sdk"

let package = Package(
    name: "CBsFirebaseBoT",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "CBsFirebaseBoT",
            targets: ["CBsFirebaseBoT"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git",
                 from: firebaseVersion)
    ],
    targets: [
        .target(
            name: "CBsFirebaseBoT",
            dependencies: [
//                .product(name: "Firebase",
//                         package: firebasePackageName),
                .product(name: "FirebaseAuth",
                         package: firebasePackageName),
                .product(name: "FirebaseFirestore",
                         package: firebasePackageName),
                .product(name: "FirebaseFirestoreSwift",
                         package: firebasePackageName)
            ]),
        .testTarget(
            name: "CBsFirebaseBoTTests",
            dependencies: ["CBsFirebaseBoT"]),
    ]
)
