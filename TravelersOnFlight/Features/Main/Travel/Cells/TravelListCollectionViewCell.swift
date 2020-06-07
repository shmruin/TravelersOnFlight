//
//  TravelListCollectionViewCell.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 27/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Action
import RxSwift
import RLBAlertsPickers
import Foundation

class TravelListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var travelTitle: UILabel!
    @IBOutlet weak var travelSummary: UILabel!
    @IBOutlet weak var travelStDate: UILabel!
    @IBOutlet weak var travelFnDate: UILabel!
    @IBOutlet weak var travelBackgroundImage: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func configure(viewController: UIViewController, with item: TravelDataModel, onDelete: @escaping (TravelDataModel) -> ()) {
        
        /**
         * Title observable binded to text label
         */
        Observable.combineLatest(item.stDate.asObservable(),
                                 item.cities.asObservable(),
                                 item.theme.asObservable())
                        .catchErrorJustComplete()
                        .map { (date, cities, theme)  in
                            return "\(date?.formatMonth ?? "-"), \(cities.first ?? "-"), \(theme)"
                        }
                        .bind(to: self.travelTitle.rx.text)
                        .disposed(by: disposeBag)
        
        /**
        * Ssummary observable binded to text label
        */
        Observable.combineLatest(item.stDate.asObservable(),
                                 item.fnDate.asObservable(),
                                 item.countries.asObservable(),
                                 item.cities.asObservable())
                    .catchErrorJustComplete()
                    .map { (stDate, fnDate, countries, cities) in
                        var nDay = 0
                        
                        if let sDate = stDate, let fDate = fnDate {
                            nDay = sDate.distanceIntOf(targetDate: fDate) + 1
                        } else {
                            print("#ERROR - stDate or fnDate is nil")
                        }
                        let nCountry = countries.count
                        let nCity = cities.count
                        
                        print("Countries: " + String(nCountry))
                        
                        let suffixDays = nDay > 1 ? "days" : "day"
                        let suffixCountries = nCountry > 1 ? "countries" : "country"
                        let suffixCities = nCity > 1 ? "cities" : "city"
                        
                        return "\(nDay) \(suffixDays) on \(nCountry) \(suffixCountries), \(nCity) \(suffixCities)"
                    }
                    .bind(to: self.travelSummary.rx.text)
                    .disposed(by: disposeBag)
        
        /**
         * Date observable binded to text label
         */
        item.stDate
            .asObservable()
            .map { date in
                if let date = date {
                    return Common.convertDateFormaterToYYMMDD(date)
                } else {
                    print("#ERROR - stDate is nil")
                    return ""
                }
            }
            .bind(to: self.travelStDate.rx.text)
        .disposed(by: disposeBag)
        
        item.fnDate
        .asObservable()
        .map { date in
            if let date = date {
                return Common.convertDateFormaterToYYMMDD(date)
            } else {
                print("#ERROR - fnDate is nil")
                return ""
            }
        }
        .bind(to: self.travelFnDate.rx.text)
        .disposed(by: disposeBag)
        
        
        // Long press to delete travel
        self
        .rx
        .longPressGesture()
        .when(.began)
        .subscribe(onNext: { _ in
            let alert = UIAlertController(title: "Wanna delete this travel?", message: "It cannot be undoable!", preferredStyle: .alert)
            alert.addAction(title: "OK", style: .default) { (action) in
                onDelete(item)
                print("Item Count: " + String(CFGetRetainCount(item)))
            }
            alert.addAction(title: "Cancel", style: .cancel)
            
            viewController.present(alert, animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
            
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("Deinit this cell")
    }
}
