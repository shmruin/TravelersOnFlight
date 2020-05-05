//
//  DayScheduleFlow.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 01/02/2020.
//  Copyright © 2020 ruin09. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift
import NSObject_Rx

class DayScheduleFlow: Flow, HasDisposeBag {
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
    
    func makeTitle(view: UIViewController, travel: TravelDataModel) {
        travel.travelTitleObservable
            .bind(to: view.rx.title)
            .disposed(by: self.disposeBag)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TravelStep else { return .none }
        
        switch step {
        case .dayScheduleScreenIsRequired(let travel):
            return navigateToDayScheduleScreen(travel: travel)
        case .dayIsSelected(let day):
            return navigateToSpecificScheduleScreen(with: day)
        default:
            return .none
        }
    }
    
    private func navigateToDayScheduleScreen(travel: TravelDataModel) -> FlowContributors {
        let viewController = DayTimelineViewController.instantiate(withViewModel: DayTimelineViewModel(thisTravelUid: travel.itemUid), andServices: self.services)
        makeTitle(view: viewController, travel: travel)
        self.rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
    
    private func navigateToSpecificScheduleScreen(with day: DayDataModel) -> FlowContributors {
        let scheduleFlow = ScheduleFlow(withServices: self.services)

        Flows.whenReady(flow1: scheduleFlow) { [unowned self] root in
            self.rootViewController.present(root, animated: true, completion: nil)
        }

        return .one(flowContributor: .contribute(withNextPresentable: scheduleFlow,
                                                 withNextStepper: OneStepper(withSingleStep: TravelStep.speicificScheduleScreenIsRequired(withDay: day))))
    }
}
