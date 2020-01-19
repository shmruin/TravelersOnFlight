//
//  SchedulePageContentViewController.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 25/10/2019.
//  Copyright © 2019 ruin09. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxDataSources
import RxCocoa
import RxRealm

class SchedulePageContentViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet weak var dayTitle: UILabel!
    @IBOutlet weak var dateAndDay: UILabel!
    @IBOutlet weak var specificsCollectionView: UICollectionView!
    
    var viewModel: SchedulePageContentViewModel!
    var dataSource: RxCollectionViewSectionedAnimatedDataSource<SpecificSection>!

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        bindViewModel()
        layoutSetting()
    }
    
    func bindViewModel() {
        viewModel.collectionItems
            .bind(to: specificsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: self.rx.disposeBag)
        
        specificsCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let specific = try! self.dataSource.model(at: indexPath) as! SpecificDataModel
                if specific.itemUid != DummySpecificData.itemUid {
                    // TODO : Something with touch cell event?
                } else {
                    let realValueNums = self.specificsCollectionView.numberOfItems(inSection: 0)
                    var prevSpecific = specific
                    if realValueNums > 0 {
                        prevSpecific = try! self.dataSource.model(at: IndexPath(row: realValueNums - 1, section: 0)) as! SpecificDataModel
                    }
                    if let cell = self.specificsCollectionView.cellForItem(at: indexPath) as? NewSpecificListCollectionViewCell {
                        cell.addNewSpecific(viewController: self, recentModel: prevSpecific, onComplete: self.viewModel.createItemOfSpecificSchedule(model:))
                    } else {
                        print("#ERROR - Selected cell is not converted to NewSpecificListCollectionViewCell")
                    }
                }
            })
            .disposed(by: self.rx.disposeBag)
    }

    func configureDataSource() {
        dataSource = RxCollectionViewSectionedAnimatedDataSource<SpecificSection>(configureCell: { [weak self] dataSource, collectionView, indexPath, item -> UICollectionViewCell in
            
            if item.itemUid == DummySpecificData.itemUid {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newSpecificCollectionViewCell", for: indexPath) as! NewSpecificListCollectionViewCell
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 1
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "specificCollectionViewCell", for: indexPath) as! SpecificListCollectionViewCell
                cell.configure(viewController: self!, with: item, superViewModel: self!.viewModel)
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 1
                return cell
            }
        })
    }
    
    func layoutSetting() {
        let collectionViewLayout = specificsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        collectionViewLayout?.estimatedItemSize = CGSize(width: specificsCollectionView.bounds.width, height: (collectionViewLayout?.collectionViewContentSize.height)!)
        
        collectionViewLayout?.invalidateLayout()
    }
}
