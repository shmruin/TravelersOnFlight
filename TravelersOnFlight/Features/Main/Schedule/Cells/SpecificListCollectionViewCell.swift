//
//  SpecificListCollectionViewCell.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 02/11/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Action
import RxSwift
import RxDataSources
import RxGesture
import RxCocoa
import NSObject_Rx
import RLBAlertsPickers


class SpecificListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var specificStTime: UILabel!
    @IBOutlet weak var specificFnTime: UILabel!
    @IBOutlet weak var specificAreaAndCity: UILabel!
    @IBOutlet weak var specificPlaceCategory: UILabel!
    @IBOutlet weak var specificPlaceName: UILabel!
    @IBOutlet weak var specificActivityCategory: UILabel!
    @IBOutlet weak var specificActivityName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configure(viewController: UIViewController, with item: SpecificDataModel, superViewModel: SchedulePageContentViewModel) {
        self.specificStTime.text = item.makeStTime()
        self.specificFnTime.text = item.makeFnTime()
        self.specificAreaAndCity.text = item.makeAreaAndCity()
        self.specificPlaceCategory.text = item.makePlaceCategory()
        self.specificPlaceName.text = item.makePlaceName()
        self.specificActivityCategory.text = item.makeActivityCategory()
        self.specificActivityName.text = item.makeActivityName()
        
        var tStDate = Date()
        var tFnDate = Date()
        var tArea = ""
        var tCity = ""
        var tPlaceCategory = PlaceCategoryRepository.Error
        var tPlaceName = ""
        var tActivityCategory = ActivityCategoryRepository.Error
        var tActivityName = ""
        
        // Add tap actions to modify inner info
        // Tap specificStTime, specificFnTime - Change duration
        Observable.merge(specificStTime.rx.tapGesture().when(.recognized),
                                 specificFnTime.rx.tapGesture().when(.recognized))
            .flatMapLatest { _ in
                return self.alertSpecificTimeSelect(viewController: viewController, title: "Select the start time", message: "", date: item.stTime!.value)
            }
            .filter { result in
                if let res = result {
                    tStDate = res
                    return true
                } else {
                    return false
                }
            }
            .flatMapLatest { _ in
                return self.alertSpecificTimeSelect(viewController: viewController, title: "Select the end times", message: "", date: item.fnTime!.value)
            }
            .filter { result in
                if let res = result {
                    tFnDate = res
                    return true
                } else {
                    return false
                }
            }
            .subscribe(onNext: { _ in
                // TODO : Write to real model
                print("Time alert activate")
                print(tStDate.timeString(ofStyle: .full))
                print(tFnDate.timeString(ofStyle: .full))
            })
            .disposed(by: rx.disposeBag)
        
        // Tap specificAreaAndCity - Change Area and City
        specificAreaAndCity
            .rx
            .tapGesture()
            .when(.recognized)
            .flatMapLatest { _ in
                return self.addTapSpecificLocationSelect(viewController: viewController, title: "City of this Schedule?", message: "", placeHolder: "Write the city")
            }
            .filter { result in
                if let res = result {
                    tCity = res
                    return true
                } else {
                    return false
                }
            }
            .flatMapLatest { _ in
                return self.addTapSpecificLocationSelect(viewController: viewController, title: "Area of this Schedule?", message: "", placeHolder: "Wrtie the area")
            }
            .filter { result in
                if let res = result {
                    tArea = res
                    return true
                } else {
                    return false
                }
            }
            .subscribe(onNext: { _ in
                // TODO : Write to real model
                print("City & area alert activate")
                print(tCity)
                print(tArea)
            })
            .disposed(by: rx.disposeBag)
        
        
        // Tap specificPlaceCategory, specificPlaceCategory - Change places
        Observable.merge(specificPlaceCategory.rx.tapGesture().when(.recognized),
                         specificPlaceName.rx.tapGesture().when(.recognized))
            .flatMapLatest { _ in
                return self.addTapSpecificCategorySelect(viewController: viewController, title: "Select the place category", message: "", categories: PlaceCategoryRepository.allCases)
            }
            .filter { result in
                if let res = result {
                    tPlaceCategory = res
                    return true
                } else {
                    return false
                }
            }
            .flatMapLatest { _ in
                return self.addTapSpecificNameSelect(viewController: viewController, title: "Place name of this schedule?", message: "", placeHolder: "Write the place name")
            }
            .filter { result in
                if let res = result {
                    tPlaceName = res
                    return true
                } else {
                    return false
                }
            }
            .subscribe(onNext: { _ in
                // TODO : Write to real model
                print("Place category & place name alert activate")
                print(tPlaceCategory.rawValue)
                print(tPlaceName)
            })
            .disposed(by: rx.disposeBag)
        
        
        // Tap specificActivityCategory, specificActivityCategory - CHange actions
        Observable.merge(specificActivityCategory.rx.tapGesture().when(.recognized),
                     specificActivityName.rx.tapGesture().when(.recognized))
        .flatMapLatest { _ in
            return self.addTapSpecificCategorySelect(viewController: viewController, title: "Select the activity category", message: "", categories: ActivityCategoryRepository.allCases)
        }
        .filter { result in
            if let res = result {
                tActivityCategory = res
                return true
            } else {
                return false
            }
        }
        .flatMapLatest { _ in
            return self.addTapSpecificNameSelect(viewController: viewController, title: "Activity name of this schedule?", message: "", placeHolder: "Write the activity name")
        }
        .filter { result in
            if let res = result {
                tActivityName = res
                return true
            } else {
                return false
            }
        }
        .subscribe(onNext: { _ in
            // TODO : Write to real model
            print("Activity category & activity name alert activate")
            print(tActivityCategory.rawValue)
            print(tActivityName)
        })
        .disposed(by: rx.disposeBag)
        
    }
    
    private func alertSpecificTimeSelect(viewController: UIViewController, title: String, message: String, date: Date) -> Observable<Date?> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            var selectedTime: Date? = nil
            
            alert.addDatePicker(mode: .time, date: date) { targetDate in
                selectedTime = targetDate
            }
            
            alert.addAction(title: "Select", style: .default) { (action) in
                observer.onNext(selectedTime)
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext(nil)
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext(nil)
            return Disposables.create()
        }
    }
    
    // TODO : Location should be map based alert
    private func addTapSpecificLocationSelect(viewController: UIViewController, title: String, message: String, placeHolder: String) -> Observable<String?> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            var selectedLocation: String?

            let textField: TextField.Config = { textField in
                textField.leftViewPadding = 12
                textField.becomeFirstResponder()
                textField.layer.borderWidth = 1
                textField.layer.cornerRadius = 8
                textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                textField.backgroundColor = nil
                textField.textColor = .black
                textField.placeholder = placeHolder
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.action { textField in
                    selectedLocation = textField.text!
                }
            }
            
            alert.addOneTextField(configuration: textField)
            
            alert.addAction(title: "Done", style: .default) { (action) in
                observer.onNext(selectedLocation)
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style: .cancel) { (action) in
                observer.onNext(nil)
                observer.onCompleted()
            }

            viewController.present(alert, animated: true, completion: nil)
            observer.onNext(nil)
            return Disposables.create()
        }
    }
    
    private func addTapSpecificCategorySelect<T: Category>(viewController: UIViewController, title: String, message: String, categories: [T]) -> Observable<T?> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let initialIdx: PickerViewViewController.Index = (column: 0, row: 0)
            var selectedCategory: T?
            
            alert.addPickerView(values: [categories.map { $0.rawValue as! String }], initialSelection: initialIdx) { (vc, picker, index, values) in
                selectedCategory = categories[index.row]
            }
            
            alert.addAction(title: "Select", style: .default) { (action) in
                observer.onNext(selectedCategory)
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style:.cancel) { (action) in
                observer.onNext(nil)
                observer.onCompleted()
            }
            
            viewController.present(alert, animated: true, completion: nil)
            observer.onNext(nil)
            return Disposables.create()
        }
    }
    
    private func addTapSpecificNameSelect(viewController: UIViewController, title: String, message: String, placeHolder: String) -> Observable<String?> {
        return Observable.create { observer in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            var selectedLocation: String?

            let textField: TextField.Config = { textField in
                textField.leftViewPadding = 12
                textField.becomeFirstResponder()
                textField.layer.borderWidth = 1
                textField.layer.cornerRadius = 8
                textField.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
                textField.backgroundColor = nil
                textField.textColor = .black
                textField.placeholder = placeHolder
                textField.keyboardAppearance = .default
                textField.keyboardType = .default
                textField.returnKeyType = .done
                textField.action { textField in
                    selectedLocation = textField.text!
                }
            }
            
            alert.addOneTextField(configuration: textField)
            
            alert.addAction(title: "Done", style: .default) { (action) in
                observer.onNext(selectedLocation)
                observer.onCompleted()
            }
            
            alert.addAction(title: "Cancel", style: .cancel) { (action) in
                observer.onNext(nil)
                observer.onCompleted()
            }

            viewController.present(alert, animated: true, completion: nil)
            observer.onNext(nil)
            return Disposables.create()
        }
    }
}
