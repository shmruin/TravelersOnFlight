//
//  TravelViewModel.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 26/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import RxFlow
import RxSwift
import RxDataSources
import RxCocoa

typealias TravelSection = AnimatableSectionModel<String, TravelItem>

class TravelListViewModel: ServicesViewModel, Stepper {
    typealias Services = HasTravelService
    
    let steps = PublishRelay<Step>()
    var services: Services!
    
    var collectionItems: Observable<[TravelSection]> {
        return self.services.travelService.travels()
            .map { results in
                let travelItems = results.sorted(byKeyPath: "stDate", ascending: false)
                
                return [TravelSection(model: "Travels", items: travelItems.toArray())]
            }
    }
    
    init(services: Services) {
        self.services = services
    }
    
    public func select(travel: TravelItem) {
        self.steps.accept(TravelStep.travelIsSelected(withTravel: travel))
    }
}
