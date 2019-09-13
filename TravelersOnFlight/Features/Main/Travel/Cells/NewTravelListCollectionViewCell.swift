//
//  NewTravelListCollectionViewCell.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 11/09/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Action
import RxSwift
import NSObject_Rx

class NewTravelListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var travelMonth: UILabel!
    @IBOutlet weak var travelCity: UILabel!
    @IBOutlet weak var travelTheme: UILabel!
    @IBOutlet weak var travelSummary: UILabel!
    @IBOutlet weak var travelDates: UILabel!
    @IBOutlet weak var travelBackgroundImage: UIImageView!
    
    func addNewTravel(onComplete: (CreateModel) -> ()) {
        
    }
}
