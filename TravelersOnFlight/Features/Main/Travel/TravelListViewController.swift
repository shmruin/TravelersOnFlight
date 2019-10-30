//
//  TravelViewController.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 26/08/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxDataSources
import RxCocoa
import RxRealm

class TravelListViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet private weak var travelsCollectionView: UICollectionView!
    
    var viewModel: TravelListViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<TravelSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
        bindViewModel()
        layoutSetting()
    }
    
    func bindViewModel() {
        viewModel.collectionItems
            .bind(to: travelsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.rx.disposeBag)
        
        travelsCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let travel = try! self.dataSource.model(at: indexPath) as! TravelDataModel
                if travel.itemUid != DummyTravelData.itemUid {
                    self.viewModel.selectToSchedule(travelData: travel)
                } else {
                    if let cell = self.travelsCollectionView.cellForItem(at: indexPath) as? NewTravelListCollectionViewCell {
                        cell.addNewTravel(viewController: self, onComplete: self.viewModel.createItemOfTravel(model:))
                    } else {
                        print("#ERROR - Selcted cell is not converted to NewTravelListCollectionViewCell")
                    }
                }
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func configureDataSource() {
        dataSource = RxCollectionViewSectionedAnimatedDataSource<TravelSection>(configureCell: { [weak self] dataSource, collectionView, indexPath, item -> UICollectionViewCell in
            
            if item.itemUid == DummyTravelData.itemUid {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newTravelCollectionViewCell", for: indexPath) as! NewTravelListCollectionViewCell
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "travelCollectionViewCell", for: indexPath) as! TravelListCollectionViewCell
                cell.configure(with: item)
                return cell
            }
        })
    }
    
    func layoutSetting() {
        let collectionViewLayout = travelsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        collectionViewLayout?.invalidateLayout()
    }
}
