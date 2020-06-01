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
import RLBAlertsPickers
import Foundation

class TravelListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var travelTitle: UILabel!
    @IBOutlet weak var travelSummary: UILabel!
    @IBOutlet weak var travelStDate: UILabel!
    @IBOutlet weak var travelFnDate: UILabel!
    @IBOutlet weak var travelBackgroundImage: UIImageView!
    
    var disposeBag = DisposeBag()
    
    func configure(viewController: UIViewController, with item: TravelDataModel, onDelete: @escaping (TravelDataModel) -> ()) {
        
        /**
         * Title observable binded to text label
         */
        item.travelTitleObservable
            .bind(to: self.travelTitle.rx.text)
            .disposed(by: disposeBag)
        
        /**
        * Ssummary observable binded to text label
        */
        item.travelSummaryObservable
            .bind(to: self.travelSummary.rx.text)
            .disposed(by: disposeBag)
        
        /**
         * Date observable binded to text label
         */
        item.stDate
            .asObservable()
            .map { date in
                if let date = date {
                    return Common.convertDateFormaterToYYMMDD(date)
                } else {
                    print("#ERROR - stDate is nil")
                    return ""
                }
            }
            .bind(to: self.travelStDate.rx.text)
        .disposed(by: disposeBag)
        
        item.fnDate
        .asObservable()
        .map { date in
            if let date = date {
                return Common.convertDateFormaterToYYMMDD(date)
            } else {
                print("#ERROR - fnDate is nil")
                return ""
            }
        }
        .bind(to: self.travelFnDate.rx.text)
        .disposed(by: disposeBag)
        
        
        // Long press to delete travel
        self
        .rx
        .longPressGesture()
        .when(.began)
        .subscribe(onNext: { _ in
            let alert = UIAlertController(title: "Wanna delete this travel?", message: "It cannot be undoable!", preferredStyle: .alert)
            alert.addAction(title: "OK", style: .default) { (action) in
                onDelete(item)
                print("Item Count: " + String(CFGetRetainCount(item)))
            }
            alert.addAction(title: "Cancel", style: .cancel)
            
            viewController.present(alert, animated: true, completion: nil)
        })
        .disposed(by: disposeBag)
            
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    deinit {
        print("Deinit this cell")
    }
}
