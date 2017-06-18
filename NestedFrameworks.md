# Nested frameworks problem

The links

* https://github.com/Carthage/Carthage/issues/416
* https://github.com/Carthage/Carthage/issues/844
* https://github.com/Carthage/Carthage/issues/1927
* https://github.com/Flinesoft/CSVImporter/pull/18
* https://github.com/Carthage/Carthage/issues/844#issuecomment-147783855
* https://github.com/Carthage/Carthage/issues/688
* https://github.com/JohnEstropia/CoreStore/issues/27
* https://stackoverflow.com/questions/35748933/error-itms-90206-invalid-bundle-contains-disallowed-file-frameworks
* https://github.com/Carthage/Carthage/issues/353

# Conclusion

If the framework you want to add to your project has dependencies explicitly listed in a Cartfile, Carthage will automatically retrieve them for you. You will then have to drag them yourself into your project from the Carthage/Build folder.

If the embedded framework in your project has dependencies to other frameworks you must link them to application target (even if application target does not have dependency to that frameworks and never uses them).
