//
//  Common.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 08/02/2020.
//  Copyright © 2020 ruin09. All rights reserved.
//

import Action
import RxSwift
import RxCocoa
import NSObject_Rx
import RLBAlertsPickers


class Common {
    static func increaseOneDateFeature(targetDate: Date, feature: Calendar.Component, value: Int) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: feature, value: value, to: targetDate)
        
        return date!
    }
    
    static func convertDateFormaterToYYMMDD(_ date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "yy.MM.dd"
        let formattedDate = format.string(from: date)
        return formattedDate
    }
    
    static func setDateAtHM(targetDate: Date, hour: Int, minutes: Int) -> Date {
        return Calendar.current.date(bySettingHour: hour, minute: minutes, second: 0, of: targetDate)!
    }
    
    static func makeUid() -> String {
        return UUID().uuidString
    }

    static func alertMonthSelect(viewController: UIViewController) -> Observable<(UIAlertController, String?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "When do you want to go there?", message: "Choose the start month of your travel", preferredStyle: .actionSheet)
            let monthComponents = Calendar.current.monthSymbols
            let initialMonth: PickerViewViewController.Index = (column: 0, row: 3)
            var selectedMonth: String?
            
            alert.addPickerView(values: [monthComponents], initialSelection: initialMonth) { (vc, picker, index, values) in
                selectedMonth = monthComponents[index.row]
            }
            
            alert.addAction(title: "Select", style: .default) { (action) in
                observer.onNext((alert, selectedMonth))
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
    
    static func alertFirstCountrySelect(viewController: UIViewController) -> Observable<(UIAlertController, String?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "What is your first country to visit?", message: "Choose the first country you travel", preferredStyle: .actionSheet)

            alert.addLocalePicker(type: .country, selection: { (localeInfo) in
                observer.onNext((alert, localeInfo?.country))
                observer.onCompleted()
            })

            alert.addAction(title: "Cancel", style: .cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }

            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
    
    static func alertFirstCitySelect(viewController: UIViewController) -> Observable<(UIAlertController, String?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "What is your first city to visit?", message: "Choose the first city you travel", preferredStyle: .actionSheet)
            var selectedCity: String?

            let textField: TextField.Config = { textField in
                textField.leftViewPadding = 12
                textField.becomeFirstResponder()
                textField.layer.borderWidth = 1
                textField.layer.cornerRadius = 8
                textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                textField.backgroundColor = nil
                textField.textColor = .black
                textField.placeholder = "City name?"
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.action { textField in
                    selectedCity = textField.text!
                }
            }
            
            alert.addOneTextField(configuration: textField)
            
            alert.addAction(title: "Done", style: .default) { (action) in
                observer.onNext((alert, selectedCity))
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style: .cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }

            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
    
    static func alertThemeSelect(viewController: UIViewController) -> Observable<(UIAlertController, TravelTheme?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "What is the main theme of the travel?", message: "Choose the theme of your travel", preferredStyle: .actionSheet)
            let themeComponents = TravelTheme.allCases
            let initialMonth: PickerViewViewController.Index = (column: 0, row: 3)
            var selectedTheme = TravelTheme.getDefault()
            
            alert.addPickerView(values: [themeComponents.map { $0.rawValue }], initialSelection: initialMonth) { (vc, picker, index, values) in
                selectedTheme = themeComponents[index.row]
            }
            
            alert.addAction(title: "Select", style: .default) { (action) in
                observer.onNext((alert, selectedTheme))
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
    
    static func alertDateSelect(viewController: UIViewController, dateOrder: OrderOfTravelDate, initEndDate: Date? = nil) -> Observable<(UIAlertController, Date?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "When will your \(dateOrder.rawValue) travel be started?", message: "Choose the \(dateOrder.rawValue) date", preferredStyle: .actionSheet)
            var selectedDate = Date()
            
            if let initialDate = initEndDate { // if end date
                selectedDate = initialDate
                alert.addDatePicker(mode: .date, date: initialDate, minimumDate: initialDate) { date in
                    selectedDate = date
                }
            } else {    // if first date
                alert.addDatePicker(mode: .date, date: Date()) { date in
                    selectedDate = date
                }
            }
            
            alert.addAction(title: "Select", style: .default) { (action) in
                observer.onNext((alert, selectedDate))
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
    
    static func alertOptionPicker(viewController: UIViewController, title: String, message: String, options: [AddDayOption]) -> Observable<(UIAlertController, AddDayOption?)> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            for option in options {
                alert.addAction(image: nil, title: option.rawValue, style: .default, isEnabled: true) { (action) in
                    observer.onNext((alert, option))
                    observer.onCompleted()
                }
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext((alert, nil))
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext((alert, nil))
            return Disposables.create()
        }
    }
}
