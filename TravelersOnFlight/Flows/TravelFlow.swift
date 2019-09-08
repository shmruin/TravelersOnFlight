//
//  TravelFlow.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 26/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift
import NSObject_Rx

class TravelFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    let rootViewController = UINavigationController()
    private let services: AppServices
    
    init(withServices services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TravelStep else { return .none }
        
        switch step {
        case .travelScreenIsRequired:
            return navigateToTravelScreen()
        case .travelIsSelected(let travelId):
            return navigateToScheduleScreen(with: travelId)
        default:
            return .none
        }
    }
    
    private func navigateToTravelScreen() -> FlowContributors {
        let viewController = TravelListViewController.instantiate(withViewModel: TravelListViewModel(), andServices: self.services)
        self.rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
    
    private func navigateToScheduleScreen(with travelId: Int) -> FlowContributors {
        // TODO: Schedule later
        return .none
    }
}
