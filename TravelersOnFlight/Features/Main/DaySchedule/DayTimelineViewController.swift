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

class DayTimelineViewController: UIViewController, StoryboardBased, ViewModelBased  {
    
    @IBOutlet weak var dayTimelineTableView: UITableView!
    
    var viewModel: DayTimelineViewModel!
    var dataSource: RxTableViewSectionedAnimatedDataSource<DaySection>!
    
    // TimelinePoint, Timeline back color, title, description, lineInfo(total hours), thumbnails(activity icons), illustration(Remove Icon)
    let data:[Int: [(TimelinePoint, UIColor, String, String, String?, [String]?, String?)]] = [0:[
            (TimelinePoint(), UIColor.black, "Day 1", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", nil, nil, "Remove"),
            (TimelinePoint(), UIColor.black, "Day 2", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", nil, nil, "Remove"),
            (TimelinePoint(), UIColor.black, "Day 3", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.", "150 mins", ["Apple"], "Remove"),
            (TimelinePoint(), UIColor.clear, "Day 4", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", nil, nil, "Remove")
        ], 1:[
            (TimelinePoint(), UIColor.clear, "ADD A NEW DAY", "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", nil, nil, "Remove")
        ]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem()

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
                    self.viewModel.createItemOfDayScehdule()
                }
            })
            .disposed(by: self.rx.disposeBag)
    }
    
    func configureDataSource() {
        dataSource = RxTableViewSectionedAnimatedDataSource<DaySection>(configureCell: { [weak self] dataSource, tableView, indexPath, item -> UITableViewCell in
            if item.itemUid == dummyDayData.itemUid {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

                 let (timelinePoint, timelineBackColor, title, description, lineInfo, thumbnails, illustration) = item.getTupleSectionForm().value
                
                 cell.timelinePoint = TimelinePoint(color: UIColor.green, filled: false)
                 cell.timeline.frontColor = UIColor.green
                 cell.timeline.backColor = UIColor.clear
                 cell.titleLabel.text = "ADD A NEW DAY"
                 cell.descriptionLabel.text = ""
                 cell.lineInfoLabel.text = lineInfo

                 if let thumbnails = thumbnails {
                     cell.viewsInStackView = thumbnails.map { thumbnail in
                         return UIImageView(image: UIImage(named: thumbnail))
                     }
                 }
                 else {
                     cell.viewsInStackView = []
                 }

                 if let illustration = illustration {
                     cell.illustrationImageView.image = UIImage(named: illustration)
                 }
                 else {
                     cell.illustrationImageView.image = nil
                 }
                
                 cell.selectionStyle = UITableViewCell.SelectionStyle.none

                 return cell
            } else {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell

                 var (timelinePoint, timelineBackColor, title, description, lineInfo, thumbnails, illustration) = item.getTupleSectionForm().value
                 var timelineFrontColor = UIColor.gray
                
                 if (tableView.numberOfRows(inSection: 0) == indexPath.row + 1) {
                    timelineBackColor = UIColor.green
                 }
                
                 cell.timelinePoint = timelinePoint
                 cell.timeline.frontColor = timelineFrontColor
                 cell.timeline.backColor = timelineBackColor
                 cell.titleLabel.text = title
                 cell.descriptionLabel.text = description
                 cell.lineInfoLabel.text = lineInfo

                 if let thumbnails = thumbnails {
                     cell.viewsInStackView = thumbnails.map { thumbnail in
                         return UIImageView(image: UIImage(named: thumbnail))
                     }
                 }
                 else {
                     cell.viewsInStackView = []
                 }

                 if let illustration = illustration {
                     cell.illustrationImageView.image = UIImage(named: illustration)
                 }
                 else {
                     cell.illustrationImageView.image = nil
                 }
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none

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
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//         // #warning Incomplete implementation, return the number of sections
//         return data.count
//     }
//
//     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//         // #warning Incomplete implementation, return the number of rows
//         guard let sectionData = data[section] else {
//             return 0
//         }
//         return sectionData.count
//     }
//
//     override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//         return "Day " + String(describing: section + 1)
//     }
//
//     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//         let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
//
//         // Configure the cell...
//         guard let sectionData = data[indexPath.section] else {
//             return cell
//         }
//
//         let (timelinePoint, timelineBackColor, title, description, lineInfo, thumbnails, illustration) = sectionData[indexPath.row]
//         var timelineFrontColor = UIColor.clear
//         if (indexPath.row > 0) {
//             timelineFrontColor = sectionData[indexPath.row - 1].1
//         }
//         cell.timelinePoint = timelinePoint
//         cell.timeline.frontColor = timelineFrontColor
//         cell.timeline.backColor = timelineBackColor
//         cell.titleLabel.text = title
//         cell.descriptionLabel.text = description
//         cell.lineInfoLabel.text = lineInfo
//
//         if let thumbnails = thumbnails {
//             cell.viewsInStackView = thumbnails.map { thumbnail in
//                 return UIImageView(image: UIImage(named: thumbnail))
//             }
//         }
//         else {
//             cell.viewsInStackView = []
//         }
//
//         if let illustration = illustration {
//             cell.illustrationImageView.image = UIImage(named: illustration)
//         }
//         else {
//             cell.illustrationImageView.image = nil
//         }
//
//         return cell
//     }
//
//     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         guard let sectionData = data[indexPath.section] else {
//             return
//         }
//
//         print(sectionData[indexPath.row])
//     }
}
