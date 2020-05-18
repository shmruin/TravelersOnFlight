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
    @IBOutlet weak var specificArea: UILabel!
    @IBOutlet weak var specificCity: UILabel!
    @IBOutlet weak var specificCountry: UILabel!
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
    
    func configure(viewController: UIViewController, with item: SpecificDataModel, superViewModel: SchedulePageContentViewModel,
                   onComplete: @escaping (String, SpecificDataModel) -> (), onDelete: @escaping (SpecificDataModel) -> ()) {
        
        item.makeStTime()
            .bind(to: specificStTime.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeFnTime()
            .bind(to: specificFnTime.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeArea()
            .bind(to: specificArea.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeCity()
            .bind(to: specificCity.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeCountry()
            .bind(to: specificCountry.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makePlaceCategory()
            .bind(to: specificPlaceCategory.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makePlaceName()
            .bind(to: specificPlaceName.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeActivityCategory()
            .bind(to: specificActivityCategory.rx.text)
            .disposed(by: rx.disposeBag)
        
        item.makeActivityName()
            .bind(to: specificActivityName.rx.text)
            .disposed(by: rx.disposeBag)
            
        var tStDate = Date()
        var tFnDate = Date()
        var tArea = ""
        var tCity = ""
        var tCountry = ""
        var tPlaceCategory = PlaceCategoryRepository.None
        var tPlaceName = ""
        var tActivityCategory = ActivityCategoryRepository.None
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
                print("Time alert activate")
                print(tStDate.timeString(ofStyle: .full))
                print(tFnDate.timeString(ofStyle: .full))
                
                item.stTime?.accept(tStDate)
                item.fnTime?.accept(tFnDate)
                
                onComplete(item.itemUid, item)
            })
            .disposed(by: rx.disposeBag)
        
        // Tap specificCountry - Change Country
        specificCountry
            .rx
            .tapGesture()
            .when(.recognized)
            .flatMapLatest { _ in
                return self.addTapSpecificCountrySelect(viewController: viewController)
            }
            .filter { result in
                if let res = result {
                    tCountry = res
                    return true
                } else {
                    return false
                }
            }
            .subscribe(onNext: { _ in
                print("Country alert activate")
                print(tCountry)
                
                item.countries?.accept(tCountry)
                
                onComplete(item.itemUid, item)
            })
            .disposed(by: rx.disposeBag)
            
        
        // Tap specificCity - Change City
        specificCity
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
            .subscribe(onNext: { _ in
                print("City alert activate")
                print(tCity)
                
                item.cities?.accept(tCity)
                
                onComplete(item.itemUid, item)
            })
            .disposed(by: rx.disposeBag)
        
        // Tap specificArea - Change Area
        specificArea
            .rx
            .tapGesture()
            .when(.recognized)
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
                print("Area alert activate")
                print(tArea)
                
                item.areas?.accept(tArea)
                
                onComplete(item.itemUid, item)
            })
            .disposed(by: rx.disposeBag)
        
        
        // Tap specificPlaceCategory, specificPlaceCategory - Change places
        Observable.merge(specificPlaceCategory.rx.tapGesture().when(.recognized),
                         specificPlaceName.rx.tapGesture().when(.recognized))
            .flatMapLatest { _ in
                return self.addTapSpecificCategorySelect(viewController: viewController, title: "Select the place category", message: "", categories: PlaceCategoryRepository.userCases)
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
                print("Place category & place name alert activate")
                print(tPlaceCategory.rawValue)
                print(tPlaceName)
                
                item.placeCategory?.accept(tPlaceCategory)
                item.placeName?.accept(tPlaceName)
                
                onComplete(item.itemUid, item)
            })
            .disposed(by: rx.disposeBag)
        
        
        // Tap specificActivityCategory, specificActivityCategory - CHange actions
        Observable.merge(specificActivityCategory.rx.tapGesture().when(.recognized),
                     specificActivityName.rx.tapGesture().when(.recognized))
        .flatMapLatest { _ in
            return self.addTapSpecificCategorySelect(viewController: viewController, title: "Select the activity category", message: "", categories: ActivityCategoryRepository.userCases)
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
            print("Activity category & activity name alert activate")
            print(tActivityCategory.rawValue)
            print(tActivityName)
            
            item.activityCategory?.accept(tActivityCategory)
            item.activityName?.accept(tActivityName)
            
            onComplete(item.itemUid, item)
        })
        .disposed(by: rx.disposeBag)
        
        
        self
            .rx
            .longPressGesture()
            .when(.began)
            .subscribe(onNext: { _ in
                let alert = UIAlertController(title: "Wanna delete this specific schedule?", message: "It cannot be undoable!", preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default) { (action) in
                    onDelete(item)
                }
                alert.addAction(title: "Cancel", style: .cancel)
                
                viewController.present(alert, animated: true, completion: nil)
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
    
    private func addTapSpecificCountrySelect(viewController: UIViewController) -> Observable<String?> {
        return Observable.create { observer in
            let alert = UIAlertController(title: "Country of this Schedule?", message: "", preferredStyle: .actionSheet)

            alert.addLocalePicker(type: .country, selection: { (localeInfo) in
                observer.onNext(localeInfo?.country)
                observer.onCompleted()
            })

            alert.addAction(title: "Cancel", style: .cancel) { (action) in
                observer.onNext(nil)
                observer.onCompleted()
            }

            viewController.present(alert, animated: true, completion: nil)
            observer.onNext(nil)
            return Disposables.create()
        }
    }
    
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
