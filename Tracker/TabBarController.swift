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
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(
                named: "trackersTabBarItem"
            ) ,
            selectedImage: UIImage(
                named: "selectedTrackersTabBarItem"
            )
        )
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
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
