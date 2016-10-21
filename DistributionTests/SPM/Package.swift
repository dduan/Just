import PackageDescription

let package = Package(
    name: "SPM",
    dependencies: [
      .Package(url: "https://github.com/JustHTTP/Just.git", majorVersion: 0)
    ]
)
