//
//  NewSpecificListCollectionViewCell.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 02/11/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Action
import RxSwift
import RxCocoa
import NSObject_Rx


class NewSpecificListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var specificAddInfo: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func addNewSpecific(viewController: UIViewController, recentModel: SpecificDataModel, onComplete: @escaping (SpecificDataModel) -> ()) {
        
        let newCountry = recentModel.countries!.value
        let newCitiy = recentModel.cities!.value
        let newArea = recentModel.areas!.value
        let newStTime = recentModel.fnTime!.value
        let newFnTime = addOneHour(targetDate: recentModel.fnTime!.value)
        
        print(newCountry)
        print(newCitiy)
        print(newArea)
        
        let newSpecificComponents = SpecificDataModel(itemUid: ScheduleItem.makeUid(),
                                                      countries: BehaviorRelay<String>(value: newCountry),
                                                      cities: BehaviorRelay<String>(value: newCitiy),
                                                      areas: BehaviorRelay<String>(value: newArea),
                                                      stTime: BehaviorRelay<Date>(value: newStTime),
                                                      fnTime: BehaviorRelay<Date>(value: newFnTime),
                                                      placeCategory: BehaviorRelay<PlaceCategoryRepository>(value: PlaceCategoryRepository.Select),
                                                      placeName: BehaviorRelay<String>(value: ""),
                                                      activityCategory: BehaviorRelay<ActivityCategoryRepository>(value: ActivityCategoryRepository.Select),
                                                      activityName: BehaviorRelay<String>(value: ""))
        onComplete(newSpecificComponents)
    }
    
    private func addOneHour(targetDate: Date) -> Date {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .hour, value: 1, to: targetDate)
        
        return date!
    }
}
