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
import NSObject_Rx

class TravelListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var travelTitle: UILabel!
    @IBOutlet weak var travelSummary: UILabel!
    @IBOutlet weak var travelDates: UILabel!
    @IBOutlet weak var travelBackgroundImage: UIImageView!
    
    func configure(with item: TravelItem) {
        // TODO : Long press to change info - with action parameter
        
        let itemFirstCityObservable = item.rx.observe(String.self, "firstCity")
        let itemNumCountriesObservable = item.rx.observe(Int.self, "numCountries")
        let itemNumCitiesObservable = item.rx.observe(Int.self, "numCities")
        let itemStDateObservable = item.rx.observe(Date.self, "stDate")
        let itemFnDateObservable = item.rx.observe(Date.self, "fnDate")
        let itemThemeObservable = item.rx.observe(String.self, "theme")
            
        Observable.combineLatest(itemFirstCityObservable, itemNumCountriesObservable, itemNumCitiesObservable, itemStDateObservable,
                                 itemFnDateObservable, itemThemeObservable, resultSelector: { (firstCity, numCountries, numCities, stDate, fnDate, theme) in
            return (firstCity, numCountries, numCities, stDate, fnDate, theme)
        }).subscribe(onNext: { [weak self] (firstCity, numCountries, numCities, stDate, fnDate, theme) in
            self?.travelTitle.text = self?.makeTravelTitle(firstCity: firstCity!, stDate: stDate!, theme: theme!)
            self?.travelSummary.text = self?.makeTravelSummary(stDate: stDate!, fnDate: fnDate!, numCountries: numCountries!, numCities: numCities!)
            self?.travelDates.text = self?.makeTravelDates(stDate: stDate!, fnDate: fnDate!)
        })
        .disposed(by: self.rx.disposeBag)
        
    }
    
    private func makeTravelTitle(firstCity: String, stDate: Date, theme: String) -> String {
        return "\(stDate.formatMonth), \(firstCity), \(theme)"
    }
    
    private func makeTravelSummary(stDate: Date, fnDate: Date, numCountries: Int, numCities: Int) -> String {
        let days = fnDate.days(sinceDate: stDate)!

        let suffixDays = days > 1 ? "days" : "day"
        let suffixCountries = numCountries > 1 ? "countries" : "country"
        let suffixCities = numCities > 1 ? "cities" : "city"

        return "\(days) \(suffixDays) on \(numCountries) \(suffixCountries), \(numCities) \(suffixCities)"
    }
    
    private func makeTravelDates(stDate: Date, fnDate: Date) -> String {
        let stringStDate = stDate.formatString(with: "yy.MM.dd")
        let stringFnDate = fnDate.formatString(with: "yy.MM.dd")

        return "\(stringStDate) - \(stringFnDate)"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
