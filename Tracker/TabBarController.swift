//
//  TabBarController.swift
//  Tracker
//
//  Created by User on 21.03.2025.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = UINavigationController(rootViewController: TrackersViewController())
        let statisticViewController = StatisticViewController()
        
        let tabBarItemTextTrackers = NSLocalizedString("trackers.title", comment: "Заголовок таб бара")
        let tabBarItemTextStatistics = NSLocalizedString("statistic.title", comment: "Заголовок таб бара")
        
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: tabBarItemTextTrackers,
            image: UIImage(
                named: "trackersTabBarItem"
            ) ,
            selectedImage: UIImage(
                named: "selectedTrackersTabBarItem"
            )
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: tabBarItemTextStatistics,
            image: UIImage(
                named: "statisticsTabBarItem"
            ),
            selectedImage: UIImage(
                named: "selectedStatisticsTabBarItem"
            )
        )
        
        self.viewControllers = [trackerViewController, statisticViewController]
    }
}
