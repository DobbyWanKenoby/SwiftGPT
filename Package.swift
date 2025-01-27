// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGPT",
    platforms: [.iOS(.v18), .macOS(.v15), .tvOS(.v18), .watchOS(.v11)],
    products: [
        .library(
            name: "SwiftGPT",
            targets: ["SwiftGPT"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.4.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
        .package(url: "https://github.com/swift-server/swift-openapi-async-http-client", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-http-types", from: "1.2.0"),
    ],
    targets: [
        .target(
            name: "SwiftGPT",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession",
                    condition: .when(platforms: [
                        .iOS, .macCatalyst, .macOS, .tvOS, .visionOS, .watchOS
                        ])),
                .product(name: "OpenAPIAsyncHTTPClient", package: "swift-openapi-async-http-client",
                    condition: .when(platforms: [.linux])
                ),
            ]
            // uncomment to generate new API files from OpenAPI.yaml
            // plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
            ),
        .testTarget(
            name: "SwiftGPTTests",
            dependencies: ["SwiftGPT"]),
    ]
)
