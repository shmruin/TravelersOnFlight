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
                                           dataSource: self.services.travelService.getTravel(travelUid: item.uid))
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
        self.steps.accept(TravelStep.travelIsSelected(withTravelData: travelData))
    }
    
    public func createItemOfTravel(model: TravelDataModel) {
        self.services.travelService.createTravel(uid: model.itemUid,
                                                 countries: model.countries.value,
                                                 cities: model.cities.value,
                                                 stDate: model.stDate.value,
                                                 fnDate: model.fnDate.value,
                                                 eTheme: model.theme.value)
            .subscribe(onNext: { _ in
                print("Travel created")
            })
            .disposed(by: self.disposeBag)
    }
    
    public func deleteItemOfTravel(model: TravelDataModel) {
        self.services.travelService.getTravel(travelUid: model.itemUid)
            .flatMapLatest { travelItem in
                return self.services.travelService.deleteTravel(travel: travelItem)
            }
            .subscribe(onNext: { deletedUid in
                print("Travel is deleted")
            })
            .disposed(by: self.disposeBag)
    }
    
    public func getSummaryForm(model: TravelDataModel,
                               summaryFunc: @escaping ((_ nDay: Int, _ nCountry: Int, _ nCity: Int) -> String),
                               label: UILabel,
                               disposeBag: DisposeBag) {
        self.services.travelService.bindTravelToSummary(travelUid: model.itemUid,
                                                        summaryFunc: summaryFunc,
                                                        label: label,
                                                        disposeBag: disposeBag)
    }
}
