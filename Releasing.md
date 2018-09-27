1. bump version number in Just.podspec
2. bump version number in Just.xcodeproj
3. run `make playground`.
4. create a new branch `release-[NEWVERSION]`
5. run `pod lib lint` and make sure it passes validation.
6. run `carthage build --archive` to create Just.framework.zip
7. check in changes from step 1-3 in the new branch.
8. tag the last commit with new version number.
9. push the new branch to Github, make a pull request.
10. wait for CI to clear.
11. push to Cocoapods trunk (`pod trunk push`).
12. merge the branch.
13. create a new release with the version number being its name on Github, with the .zip frame step
    6 uploaded.
