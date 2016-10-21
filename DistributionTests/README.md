## What is this?

Each Swift project in this repository uses a different package manager to
satisfy dependency on the same library. A successful build of a project
indicates the library's support for the manager is working.

A *Makefile* is included to help automate the building process.

## Who can benefit from this?

Author of an open-source Swift 3 library. The library is distributed with any
combination of Cocoapods, Carthage and Swift Package Manager. They want to
ensure supports for them keep working throughout development.

## How does it work?

1. Download this project either directly or via `git clone`.
2. Specify the library to test. Three things about the library is required: its
   name, git URL and a major version number. The script `customize` takes
   these and inject them to each test projects. To test [Just][Just], for
   example:

    ```
    ./customize --name Just --git "https://github.com/JustHTTP/Just.git" --major 0
    ```
3. Run `make`. This will build projects for each aforementioned package
   manager by fetching the library and import it for various platforms that
   Xcode/Swift supports. There's a make command for each package
   manager/platform combination as well. For example, you can run `make
   test-integration-carthage-tvOS`.
4. Make this part of your library's continuous integration. Do step 1-3 as
   part of continoues integration script. Better yet, include it as part of
   your library structure. The *make* commands are going to be handy.

## Does it work for your library?

There are a few assumptions for the library being tested: it must have
a consistent name for the framework file (`Just`.framework) and import symbol
(import `Just`) on all platforms. So if the packager
build`Just-tvOS.framework` but user writes `import Just` in their code, that
won't work.

Out of the box, all three package managers (Cocoapods, Carthage, Swift Package
Manager) and four platforms (iOS, macOS, watchOS, tvOS) are tested.

Swift package manager projects tests against a major version number.

If your library can't fit in any of these assumptions, update it, or manually
edit content of projects here for your needs (don't forget to update the
Makefile as well, it's pretty straight forward). Examples:

* if you don't support Carthage, delete the Carthage folder and related
  contents in Makefile.
* if you don't support watchOS, open both `Example` in Xcode and delete the
  watchOS target. Then deleted everything related to watchOS in the Makefile.
* If your library get build to a name other than its import symbol, remove the
  pre-existing ones from the Xcode projects and add them manually.
* If you need to target a minor version number, add it in `SPM/Package.swift`.

[Just]: https://github.com/JustHTTP/Just.git
