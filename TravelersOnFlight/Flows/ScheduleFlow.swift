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
    
    var screenTitle: String = "Schedules"
    
    init(withServices services: AppServices, withTitle title: String) {
        self.services = services
        self.screenTitle = title
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func makeTitle(view: UIViewController) {
        view.title = screenTitle
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TravelStep else { return .none }
        
        switch step {
        case .scheduleScreenIsRequired(let day):
            return navigateToFirstScheduleScreen(day: day)
        default:
            return .none
        }
    }
    
    private func navigateToFirstScheduleScreen(day: Int) -> FlowContributors {
        let viewController = SchedulePageContentViewController.instantiate(withViewModel: SchedulePageContentViewModel(day: day), andServices: self.services)
        makeTitle(view: viewController)
        self.rootViewController.pushViewController(viewController, animated: false)
        return .one(flowContributor: .contribute(withNextPresentable: viewController, withNextStepper: viewController.viewModel))
    }
}
