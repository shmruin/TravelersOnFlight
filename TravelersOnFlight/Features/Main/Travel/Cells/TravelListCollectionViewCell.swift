//
//  TravelListCollectionViewCell.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 27/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Action
import RxSwift
import NSObject_Rx
import RLBAlertsPickers

class TravelListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var travelTitle: UILabel!
    @IBOutlet weak var travelSummary: UILabel!
    @IBOutlet weak var travelStDate: UILabel!
    @IBOutlet weak var travelFnDate: UILabel!
    @IBOutlet weak var travelBackgroundImage: UIImageView!
    @IBOutlet weak var travelDeleteBtn: UIButton!
    
    func configure(viewController: UIViewController, with item: TravelDataModel, onDelete: @escaping (TravelDataModel) -> ()) {
        self.travelTitle.text = item.makeTravelTitle()
        self.travelSummary.text = item.makeTravelSummary()
        self.travelStDate.text = item.makeTravelDates(.First)
        self.travelFnDate.text = item.makeTravelDates(.End)
        
        travelDeleteBtn
            .rx
            .tap
            .subscribe(onNext: {
                let alert = UIAlertController(title: "Wanna delete this travel?", message: "It cannot be undoable!", preferredStyle: .alert)
                alert.addAction(title: "OK", style: .default) { (action) in
                    onDelete(item)
                }
                alert.addAction(title: "Cancel", style: .cancel)
                
                viewController.present(alert, animated: true, completion: nil)
            })
            .disposed(by: rx.disposeBag)
            
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
