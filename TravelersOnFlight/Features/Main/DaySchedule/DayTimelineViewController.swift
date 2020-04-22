//
//  DayTimelineViewController.swift
//  TravelersOnFlight
//
//  Created by ruin09 on 01/02/2020.
//  Copyright © 2020 ruin09. All rights reserved.
//

import UIKit
import Reusable
import RxFlow
import RxSwift
import RxDataSources
import RxCocoa
import RxRealm
import TimelineTableViewCell
import NSObject_Rx


class DayTimelineViewController: UIViewController, StoryboardBased, ViewModelBased  {
    
    @IBOutlet weak var dayTimelineTableView: UITableView!
    
    var viewModel: DayTimelineViewModel!
    var dataSource: RxTableViewSectionedAnimatedDataSource<DaySection>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let bundle = Bundle(for: TimelineTableViewCell.self)
        let nibUrl = bundle.url(forResource: "TimelineTableViewCell", withExtension: "bundle")
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell",
            bundle: Bundle(url: nibUrl!)!)
        dayTimelineTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: "TimelineTableViewCell")
        
        setTableOptions()
        
        configureDataSource()
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.collectionItems
            .bind(to: dayTimelineTableView.rx.items(dataSource: dataSource))
            .disposed(by: self.rx.disposeBag)
        
        dayTimelineTableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let dayItem = try! self.dataSource.model(at: indexPath) as! DayDataModel
                if dayItem.itemUid != dummyDayData.itemUid {
                    self.viewModel.selectToSpecificSchedule(dayData: dayItem)
                } else {
                    /**
                     * Add or Insert day to day timeline - insert should be diversed with add in case that days are not serialized
                     */
                    Common.alertOptionPicker(viewController: self, title: "Appending Day Type?", message: "", options: [AddDayOption.Insert, AddDayOption.New])
                        .filter { result in
                            if let res = result.1 {
                                if res == AddDayOption.New {
                                    self.viewModel.createItemOfDayScehdule()
                                    print("Day Created")
                                    return false
                                } else {
                                    return true
                                }
                            } else {
                                return false
                            }
                        }
                        .flatMapLatest { _ in
                            return Common.alertDateSelect(viewController: self, dateOrder: .First)
                        }
                        .filter { result in
                            if let res = result.1 {
                                self.viewModel.insertItemOfDaySchedule(res, onFailure: self.failureAlert)
                                return true
                            } else {
                                return false
                            }
                        }
                    .subscribe(onNext: { _ in
                        print("Day Created")
                    })
                    .disposed(by: self.rx.disposeBag)
                }
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func configureDataSource() {
        dataSource = RxTableViewSectionedAnimatedDataSource<DaySection>(configureCell: { [weak self] dataSource, tableView, indexPath, item -> UITableViewCell in
            if item.itemUid == dummyDayData.itemUid {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
                
                 cell.timelinePoint = TimelinePoint(color: UIColor.black, filled: false)
                 cell.timeline.frontColor = UIColor.gray
                 cell.timeline.backColor = UIColor.clear
                 cell.titleLabel.text = "ADD A NEW DAY"
                 cell.descriptionLabel.text = ""
                 cell.lineInfoLabel.text = nil
                 cell.bubbleColor = UIColor.green

//                 if let thumbnails = thumbnails {
//                     cell.viewsInStackView = thumbnails.map { thumbnail in
//                         return UIImageView(image: UIImage(named: thumbnail))
//                     }
//                 }
//                 else {
                     cell.viewsInStackView = []
//                 }

//                 if let illustration = illustration {
//                     cell.illustrationImageView.image = UIImage(named: illustration)
//                 }
//                 else {
                     cell.illustrationImageView.image = nil
//                 }
                
                 cell.selectionStyle = UITableViewCell.SelectionStyle.none

                 return cell
            } else {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

                 let timelineFrontColor = UIColor.gray
                
                 cell.timelinePoint = TimelinePoint()
                 cell.timeline.frontColor = timelineFrontColor
                 cell.timeline.backColor = UIColor.gray
                 cell.descriptionLabel.text = item.description.value
                 cell.lineInfoLabel.text = Common.convertDateFormaterToYYMMDD(item.date.value)
                
                /**
                 * Day observer as delete makes day label changed
                 */
                 item.day
                    .asObservable()
                    .map {
                        print("binding!! = " + String($0))
                        return  "Day " + String($0)
                     }
                    .bind(to: cell.titleLabel.rx.text)
                    .disposed(by: item.disposeBag)

//                 if let thumbnails = thumbnails {
//                     cell.viewsInStackView = thumbnails.map { thumbnail in
//                         return UIImageView(image: UIImage(named: thumbnail))
//                     }
//                 }
//                 else {
                     cell.viewsInStackView = []
//                 }

//                 if let illustration = illustration {
//                     cell.illustrationImageView.image = UIImage(named: illustration)
//                 }
//                 else {
                     cell.illustrationImageView.image = nil
//                 }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                /**
                * Cell long press to delete - capture datasource with indexPath
                */
                cell
                .rx
                .longPressGesture()
                .when(.began)
                .subscribe(onNext: { [weak dataSource] _ in
                    let alert = UIAlertController(title: "Wanna delete this day schedule?", message: "It cannot be undoable!", preferredStyle: .alert)
                    alert.addAction(title: "OK", style: .default) { (action) in
                        if let model = dataSource?.sectionModels[0].items[indexPath.row] {
                            print(model.itemUid)
                            self!.viewModel.deleteItemOfDaySchedule(model: model)
                        } else {
                            print("dataSource of cell longPressGuesture is nil")
                        }
                    }
                    alert.addAction(title: "Cancel", style: .cancel)

                    self!.present(alert, animated: true, completion: nil)
                })
                .disposed(by: cell.disposeBag)

                return cell
            }
        })
    }
    
    func setTableOptions() {
        dayTimelineTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width:  dayTimelineTableView.frame.size.width, height: 1)

        border.borderWidth = width
        dayTimelineTableView.layer.addSublayer(border)
        dayTimelineTableView.layer.masksToBounds = true
    }
    
    func failureAlert() {
        let alert = UIAlertController(title: "Insert day failed", message: "That day already exists!", preferredStyle: .alert)
        alert.addAction(title: "OK", style: .default)
        
        self.present(alert, animated: true, completion: nil)
    }

}
