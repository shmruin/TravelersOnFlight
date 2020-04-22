//
//  ScheduleFlow.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 02/10/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift
import NSObject_Rx

class ScheduleFlow: Flow {
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
    
    func makeTitle(view: UIViewController, title: String = "") {
        view.title = title
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TravelStep else { return .none }
        
        switch step {
        case .speicificScheduleScreenIsRequired(let day):
            return navigateToFirstSpecificScheduleScreen(day: day)
        default:
            return .none
        }
    }
    
    private func navigateToFirstSpecificScheduleScreen(day: DayDataModel) -> FlowContributors {
        let viewController = SchedulePageContentViewController.instantiate(withViewModel: SchedulePageContentViewModel(thisDayUid: day.itemUid), andServices: self.services)
        makeTitle(view: viewController, title: "Day " + String(day.day.value))
        self.rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
}
