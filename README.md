# ![localbume-logo](https://raw.githubusercontent.com/coshkun/localbume/master/Resources/Icon/Icon-40.png) Localbume 
Localbume is a location based iOS app, what makes you collect and archive your personal location history tagged by photos. You can collect and share your best places with your best moments as an album style, and you can plan or record your own adventures.

#### Version 1.0
* Position Finder Added
* Error Handlers Added

#### Compatibility
Xcode v7.0 - v7.2.1
Swift 2.2

#### Known Issues
CoreData Framework has known issues on FetchRequestController and tableViews on this version of Xcode and iOS.
i was unable to work it out, and i was have to protect backward compatiblity since iOS.9.0. To develop a workaround, i had to use 2 different data-binding operation on same model. it may cause performance issues for huge amounts of records (like 1000s of lines of location records) on the data model.

#### Screenshot
![localbume-launch-image](https://raw.githubusercontent.com/coshkun/localbume/master/Resources/Launch%20Images/Launch%20Image%202x.png)
