1. bump version number in Just.podspec
2. bump version number in Just.xcodeproj
3. run `make playground`.
4. create a new branch `release-[NEWVERSION]`
5. check in changes from step 1-3 in the new branch.
6. tag the last commit with new version number.
7. push the new branch to Github, make a pull request.
8. wait for CI to clear.
9. merge the branch.
10. create a new release with the version number being its name on Github.
11. push to Cocoapods trunk (`pod trunk push`).
