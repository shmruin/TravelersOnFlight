//
//  TravelViewModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 26/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import RxFlow
import RxSwift
import RxSwiftExt
import RxDataSources
import RxCocoa
import NSObject_Rx

typealias TravelSection = AnimatableSectionModel<String, TravelDataModel>

class TravelListViewModel: ServicesViewModel, Stepper, HasDisposeBag {
    typealias Services = HasTravelService
    
    let steps = PublishRelay<Step>()
    var services: Services!
    
    var collectionItems: Observable<[TravelSection]> {
        return self.services.travelService.travels()
            .map { results in
                let travelItems = results.sorted(byKeyPath: "stDate", ascending: false)
                let travelData = travelItems.toArray().map { (item: TravelItem) in
                    return TravelDataModel(itemUid: item.uid,
                                           countries: BehaviorRelay<[String]>(value: item.countries.toArray()),
                                           cities: BehaviorRelay<[String]>(value: item.cities.toArray()),
                                           theme: BehaviorRelay<TravelTheme>(value: TravelTheme(rawValue: item.theme)!),
                                           stDate: BehaviorRelay<Date>(value: item.stDate),
                                           fnDate: BehaviorRelay<Date>(value: item.fnDate))
                }
                
                return [TravelSection(model: "Travels", items: travelData),
                        TravelSection(model: "NewTravel", items: [DummyTravelData])]
            }
    }
    
    init() { }
    
    public func getTravelItemFromTravelDate(travelData: TravelDataModel) -> BehaviorRelay<TravelItem?> {
        let result = BehaviorRelay<TravelItem?>(value: nil)
        self.services.travelService.getTravel(travelUid: travelData.itemUid)
            .share()
            .subscribe(onNext: { travel in
                result.accept(travel)
            })
            .disposed(by: self.disposeBag)
        
        return result
    }
    
    public func selectToSchedule(travelData: TravelDataModel) {
//        getTravelItemFromTravelDate(travelData: travelData)
//            .asObservable()
//            .unwrap()
//            .subscribe(onNext: { travelItem in
//                self.steps.accept(TravelStep.travelIsSelected(withTravel: travelItem))
//            })
//            .disposed(by: self.disposeBag)
        self.steps.accept(TravelStep.travelIsSelected(withTravelData: travelData))
    }
    
    public func createItemOfTravel(model: TravelDataModel) {
        self.services.travelService.createTravel(uid: model.itemUid,
                                                 countries: model.countries!.value,
                                                 cities: model.cities!.value,
                                                 stDate: model.stDate!.value,
                                                 fnDate: model.fnDate!.value,
                                                 eTheme: model.theme!.value)
        // TODO : Move to the created travel -> schedule
    }
}
