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

class TravelListViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet private weak var travelsCollectionView: UICollectionView!
    
    var viewModel: TravelListViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<TravelSection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureDataSource()
    }
    
    func bindViewModel() {
        viewModel.collectionItems
            .bind(to: travelsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.rx.disposeBag)
        
        travelsCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let travel = try! self.dataSource.model(at: indexPath) as! TravelItem
                self.viewModel.select(travel: travel)
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func configureDataSource() {
        dataSource = RxCollectionViewSectionedAnimatedDataSource<TravelSection>(configureCell: { [weak self] dataSource, collectionView, indexPath, item -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "travelCollectionViewCell", for: indexPath) as! TravelListCollectionViewCell
            if let self = self { // for action later
                cell.configure(with: item)
            }
            return cell
        })
    }
}
