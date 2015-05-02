Just is a client-side HTTP library inspired by [python-requests][] - HTTP for Humans.

*Caution: Just is subject to breaking changes before v1.0.*


[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


-   [Install](#install)
-   [Use](#use)
-   [Contribute](#contribute)
-   [License](#License)


[python-requests]: http://python-requests.org "python-requests"


#  Install

Just is a relatively simple project. Here are some ways to leverage it.

-   **Source File**: There's only one. Drop it in a playgronud or, if so desired, directly into
	your code base.

-   **Git Submodule**: Add this repository as a git submodule, drop `Just.xcodeproj` in to your 
	Xcode project so that you can make `Just.framework` a dependency and link to it.

-   **Dynamic Framework**: [Carthage][] can install Just because Just is a dynamic framework 
	for iOS and OS X, therefore other ways to use 3rd party dynamic framework also works.


[Carthage]: https://github.com/Carthage/Carthage "Carthage"


# Use


# Contribute

Pull requests are welcome. Here are some tips for code contributors:

You'll need [Carthage][] to install [Quick][], before you can run the tests.
For those who use editors other than Xcode, `make` command requires 
[xcpretty][].


[Quick]: https://github.com/Quick/Quick "Quick"
[xcpretty]: https://github.com/supermarin/xcpretty "xcpretty"

# License

MIT, see License.md.