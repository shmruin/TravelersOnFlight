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
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.navigationItem.title = "Travel Flow"
        return viewController
    }()
    
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
        case .travelIsSelected(let travel):
            return navigateToDayScehduleScreen(with: travel)
        default:
            return .none
        }
    }
    
    private func navigateToTravelScreen() -> FlowContributors {
        let viewController = TravelListViewController.instantiate(withViewModel: TravelListViewModel(), andServices: self.services)
        viewController.title = "Travels"
        self.rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
    
    private func navigateToDayScehduleScreen(with travel: TravelDataModel) -> FlowContributors {
        let dayScheduleFlow = DayScheduleFlow(withServices: self.services)
        
        Flows.whenReady(flow1: dayScheduleFlow) { [unowned self] root in
            self.rootViewController.present(root, animated: true, completion: nil)
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: dayScheduleFlow, withNextStepper: OneStepper(withSingleStep: TravelStep.dayScheduleScreenIsRequired(withTravel: travel))))
    }
}
