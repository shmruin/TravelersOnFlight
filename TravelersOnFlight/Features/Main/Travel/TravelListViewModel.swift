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
import RxRealm
import NSObject_Rx

typealias TravelSection = AnimatableSectionModel<String, TravelDataModel>

class TravelListViewModel: ServicesViewModel, Stepper, HasDisposeBag {
    typealias Services = HasTravelService
    
    let steps = PublishRelay<Step>()
    var services: Services!
    
    var collectionItems: Observable<[TravelSection]> {
        return self.services.travelService.travels()
            .map { results in
                let travelItems = results.sorted(byKeyPath: "createdDate", ascending: false)
                let travelData = travelItems.toArray().map { (item: TravelItem) -> TravelDataModel in
                    
                    return TravelDataModel(itemUid: item.uid,
                                           travelDataSource: self.services.travelService.getTravelFromObject(travelUid: item.uid),
                                           countryDataSource: self.services.travelService.getCountriesFromObject(travelUid: item.uid),
                                           cityDataSource: self.services.travelService.getCitiesFromObject(travelUid: item.uid))
                }
                
                return [TravelSection(model: "Travels", items: travelData),
                        TravelSection(model: "NewTravel", items: [DummyTravelData])]
            }
    }
    
    init() { }
    
    public func selectToSchedule(travelData: TravelDataModel) {
        self.steps.accept(TravelStep.travelIsSelected(withTravelData: travelData))
    }
    
    public func createItemOfTravel(model: TravelDataModel) {
        self.services.travelService.createTravel(uid: model.itemUid,
                                                 country: model.countries.value[0],
                                                 city: model.cities.value[0],
                                                 stDate: model.stDate.value,
                                                 fnDate: model.fnDate.value,
                                                 eTheme: model.theme.value)
            .take(1)
            .subscribe(onNext: { _ in
                print("Travel created")
            })
            .disposed(by: self.disposeBag)
    }
    
    public func deleteItemOfTravel(model: TravelDataModel) {
        self.services.travelService.getTravel(travelUid: model.itemUid)
            .take(1)
            .flatMapLatest { travelItem in
                return self.services.travelService.deleteTravel(travel: travelItem)
            }
            .subscribe(onNext: { deletedUid in
                print("Travel is deleted")
            })
            .disposed(by: self.disposeBag)
    }
}
