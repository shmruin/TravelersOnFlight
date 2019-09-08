//
//  AppFlow.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import Foundation
import UIKit
import RxFlow
import RxCocoa
import RxSwift
import NSObject_Rx

class AppFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private lazy var rootViewController: UINavigationController = {
        let viewController = UINavigationController()
        viewController.setNavigationBarHidden(true, animated: false)
        return viewController
    }()
    
    private let services: AppServices
    
    init(services: AppServices) {
        self.services = services
    }
    
    deinit {
        print("\(type(of: self)): \(#function)")
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? TravelStep else { return .none }
        
        switch step {
        case .travelScreenIsRequired:
            return navigationToTravelScreen()
        default:
            return .none
        }
    }
    
    private func navigationToTravelScreen() -> FlowContributors {
        let travelFlow = TravelFlow(withServices: self.services)
        
        Flows.whenReady(flow1: travelFlow) { [unowned self] root in
            DispatchQueue.main.async {
                self.rootViewController.present(root, animated: true)
            }
        }
        
        return .one(flowContributor: .contribute(withNextPresentable: travelFlow,
                                                 withNextStepper: OneStepper(withSingleStep: TravelStep.travelScreenIsRequired)))
    }
    
}

class AppStepper: Stepper {
    
    let steps = PublishRelay<Step>()
    private let appService: AppServices
    private let disposeBag = DisposeBag()
    
    init(withServices services: AppServices) {
        self.appService = services
    }
    
    var initialStep: Step {
        return TravelStep.travelScreenIsRequired
    }
    
    func readyToEmitSteps() {
        steps
            .accept(TravelStep.travelScreenIsRequired)
    }
}
