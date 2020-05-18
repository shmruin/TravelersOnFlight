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
        let newPlaceCategory = PlaceCategoryRepository.Select
        let newActivityCategory = ActivityCategoryRepository.Select
        
        let newFnTime = Common.increaseOneDateFeature(targetDate: recentModel.fnTime!.value, feature: .hour, value: 1)
        
        
        let newSpecificComponents = SpecificDataModel(itemUid: Common.makeUid(),
                                                      countries: BehaviorRelay<String>(value: newCountry),
                                                      cities: BehaviorRelay<String>(value: newCitiy),
                                                      areas: BehaviorRelay<String>(value: newArea),
                                                      stTime: BehaviorRelay<Date>(value: newStTime),
                                                      fnTime: BehaviorRelay<Date>(value: newFnTime),
                                                      placeCategory: BehaviorRelay<PlaceCategoryRepository>(value: newPlaceCategory),
                                                      placeName: BehaviorRelay<String>(value: ""),
                                                      activityCategory: BehaviorRelay<ActivityCategoryRepository>(value: newActivityCategory),
                                                      activityName: BehaviorRelay<String>(value: ""))
        onComplete(newSpecificComponents)
    }
}
