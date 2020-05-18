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
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 1
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "travelCollectionViewCell", for: indexPath) as! TravelListCollectionViewCell
                cell.layer.borderColor = UIColor.gray.cgColor
                cell.layer.borderWidth = 1
                cell.configure(viewController: self!, with: item, onDelete: self!.viewModel.deleteItemOfTravel(model:))
                
                if let bgImage = self!.setBackgroundImg(item.theme.value) {
                    cell.travelBackgroundImage.image = bgImage
                } else {
                    print("#ERROR - No background Image for this cell theme")
                }
                
                return cell
            }
        })
    }
    
    func layoutSetting() {
        let collectionViewLayout = travelsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        collectionViewLayout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
        collectionViewLayout?.invalidateLayout()
    }
    
    func setBackgroundImg(_ theme: TravelTheme) -> UIImage? {
        switch theme {
        case .AlwaysGood:
            return UIImage(named: "alwaysGoodTheme")
        case .DreamsComeTrue:
            return UIImage(named: "dreamsComeTrueTheme")
        case .JustWonderful:
            return UIImage(named: "justWonderfulTheme")
        case .Lonely:
            return UIImage(named: "lonelyTheme")
        case .LookingForHappiness:
            return UIImage(named: "lookingForHappinessTheme")
        case .Unexpected:
            return UIImage(named: "defaultTheme")
        case .Vacation:
            return UIImage(named: "vacationTheme")
        case .WithFamily:
            return UIImage(named: "withFamilyTheme")
        case .WithFriends:
            return UIImage(named: "withFriendsTheme")
        default:
            return UIImage(named: "defaultTheme")
        }
    }
}
