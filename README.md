# TravelersOnFlight

![Alt text](screenshots/TravelersOnFlightDemo.PNG?raw=true "TravelersOnFlight Demo")
![Alt text](screenshots/TravelersOnFlightDemo2.PNG?raw=true "TravelersOnFlight Demo2")
![Alt text](screenshots/TravelersOnFlightDemo3.PNG?raw=true "TravelersOnFlight Demo2")

A simple travel scheduler iOS app for all busy travels!
This app is mainly focused on reactive and offline availability.
Without all complex scheduler features, this app has only 3 stage : Travel / Day Schedule / Specific Schedule.
So, one can use it on the airplane very easily - as I wish - and write down their sudden schedule on this small app.
That's what it does!

## Getting Started


### Prerequisites
Same or higher version of `iOS 11` is absolutely required.  
Running on `Xcode 11.5 & Swift5`(which is latest at this moment); Lower version has not been tested.
And Some additional `libraries & frameworks` that you can find in Cocoapods
 - RxSwift
 - RxCocoa
 - RxDataSource
 - RxSwiftExt
 - Action
 - NSObject+Rx
 - RxGesture
 - RxFlow
 - RealmSwift
 - RxRealm
 - RLBAlertsPickers
 - TimelineTableViewCell
 - Reusable

Please check all of specific versions of those on pod  file.
No other special prerequisites for this.


### Installing

1. This is a simple app that works with xcode & cocoapods
2. just `pod init` on your terminal to make the workspace, and try it on xcode

## Manipulation for users

### Common Actions
 - **Long press** to delete
 - **Tap** to change the value

### Travel Section
- Travel is the biggest unit in this app
- By adding a travel, you can specify your travel days, country, city, and the theme of the travel!
- The summary info of the travel - visited countries & cities - is also automatically reflected.

### Daytimeline Schedule Section
- `kf99916/TimelineTableViewCell` is adjusted here
- Days are related with the timelines in this view
- You can delete any day
- You can add day at the end or insert a day between any days

### Specific Schedule Section
- The smallest unit of this app
- This represents the partial unit of the schedule during a day
- Ready made categories. You can use them with your own options.
- Area, City, Country can be added on each schedule.

## Known bugs - must be fixed!
 - `TimelineTableViewCell` label constraint breaks when it hide on scroll area

## Need more improvement!
- More user endpoints to custom
- More feasible architecture to deal with UI and Data
- Flexibility

## Built With

 - All of the open source libraries on prerequisites
 - `kf99916/TimelineTableViewCell`
 - `loicgriffie/Alerts-Pickers`

## Contributing

Any Pull Request is fine, if it make sense and fully commented! 😝

## Versioning

1.0.0

## Authors

* **shmruin** - *Initial work*


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
