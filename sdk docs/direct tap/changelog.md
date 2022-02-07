# Changelog of Direct Tap Framework

All notable changes to this project will be documented in this file.

## 3.0.0 - 2022-02-03

### Changed

- removed **None** option from **BrowserMode** enum
- protocol **CoreDelegate** parameter to closure in both **checkout** and **checkoutWithinSameScreen** functions to make calling of the functions easier and more convenient

### Added

- separate function **retrieveCheckoutURL** to get the URL instead of launching within the internal WebView. This is a replacement to the **None** Option from **BrowserMode**
- internal calling of **Retrieve Transaction** API Service to return the **Transaction** object every after Tap Web Session
- **getSourceBanks()** function to retrieve all available source banks for the specified destination bank

## 2.7.0 - 2022-01-26

### Changed

- made **terminate()** function private and explicitly called when Internal WebView is destroyed

## 2.6.0 - 2022-01-13

### Added

- function for retrieving the current Framework Version
- function for retrieving the Mobile Application Signature (Bundle Identifier and Seed ID)
- support for transactional retries within the WebView

## 2.5.0 - 2022-01-07

### Fixed

- End of transaction (success or failure) detection within the WebView for the new URL Format

## 2.4.0 - 2021-11-22

### Added

- option to hide the Back Button on the Navigation Bar

### Fixed

- setting of source bank code in Account constructor

## 2.3.0 - 2021-10-26

### Changed

- Minimum **iOS Version** from **11** to **12**

### Added

- BPI and BDO **errorCode** to **onResult** function from **CoreDelegate**

## 2.2.2 - 2021-09-10

### Added

- http and https support for Fail URL

## 2.2.1 - 2021-08-27

### Fixed

- **expiryDate** being passed to the Tap Web Application

### Changed

- renamed all classes, methods and packages containing the name 'Tap' to 'DirectTap'
- TapSF -> DirectTapSF
- TapRequest -> DirectTapRequest

## 2.2.0 - 2021-08-10

### Added

- **expiryDate** parameter inside TapRequest to change expiry date of created invoice
- **uniqueAmount** parameter inside TapRequest to enable centavo reconciliation workaround logic

## 2.1.0 - 2021-06-11

### Added

- added **initSecurityCheck** function to add simple detection for jailbroken devices

## 2.0.0 - 2021-05-31

### Changed

- renamed all classes, methods and packages containing the name 'IDP' to 'Tap'
- IdpSF -> TapSF
- IdpRequest -> TapRequest

## 1.4.0 - 2021-05-21

### Fixed

- Framework Import Error for future Xcode Version

## 1.3.0 - 2021-02-22

### Added

- support for *'Remember Me'* feature of pIDP Web Application
- **useRememberMe** parameter in **IDPRequest** to optionally use *Remember Me*  Feature
- **clearRememberMe** function to clear the currently saved encrypted credentials

### Changed

- Removed **showWithinSameScreen** option within checkout function 
- Created a separate **checkoutWithinSameScreen** function that allows the user to show the WKWebView within a child view controller

## 1.2.3 - 2021-02-02

### Changed

- Removed BitCode Flag from the generated Framework

## 1.2.2 - 2021-02-01

### Fixed

- Automatic closing of WKWebView when **Done** Button is clicked within the pIDP Web Application

## 1.2.1 - 2021-01-29

### Added

- **showWithinSameScreen** option within checkout function that allows to show WKWebView as a child ViewController of the current ViewController

## 1.2.0 - 2020-12-17

### Added

- **cancel()** function to prevent WebView from showing after calling **checkout()**
- option to show UIAlertView when closing the WebView via **dismissAlert** component of **IDPRequest**
- error throwing in **checkout()** function to check if the return and fail url's passed are the same

### Fixed
- assigning **country** to the source account (Indonesia and Philippines have been interchanged)

## 1.1.0 - 2020-12-11

### Added

- Internal WKWebView for easier detection of successful and failed transactions
- **browserMode** to give developer several options in showing the IDP Web Application 
1. **None** - developer may create his own WebView to show the IDP Web Application through a checkout URL returned
2. **Safari** - IDP Web Application will be launched through Safari Web Browser
3. **WebView** - IDP Web Application will be launched through built-in WKWebView from the SDK
- Automatic closing of IDP Web Application Session when Safari has been closed

### Changed

- **num** to **numInCents** and its format from **Float** to **String** from **Amount** struct
- **showInBrowser** to **browserMode** and its format from **Bool** to **BrowserMode enum**

### Changed

- **initialize()** function can now accept API key besides the client name and secret

## 1.0.0 - 2020-12-07

### Added

- The whole IDP Framework (includes **checkout()** function and **IDPRequest** components - **Account**, **Address**, **Amount**, **BankCode**, **Client**,  **Customer**, **Country**, **Currency**)
