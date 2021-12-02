# Changelog of Statement Tap Framework

All notable changes to this project will be documented in this file.

## 1.2.0 - 2021-11-22

### Added

- option to hide the Back Button on the Navigation Bar

## 1.1.0 - 2021-10-26

### Changed

- Minimum **iOS Version** from **11** to **12**

### Added

- BPI and BDO **errorCode** to **onResult** function from **CoreDelegate**

## 1.0.2 - 2021-09-10

### Fixed

- closing of webview when transaction is cancelled or failed

## 1.0.1 - 2021-09-02

### Fixed

- **bankList** not reflecting on Tap Web Application if defined inside the **StatementTapRequest** constructor instead of using the accessor

## 1.0.0 - 2021-08-13

### Added

- initialize() function that accepts the API Key and the chosen environment to interact with (Sandbox or Production)
- checkout() function that is used to redirect the use the Tap Web Application for Statement Retrieval
- clearRememberMe() function that clears all credentials saved within the custom WKWebView
