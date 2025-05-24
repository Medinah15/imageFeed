//
//  TabBarController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 14.04.25.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            assertionFailure("Не удалось загрузить ImagesListViewController")
            return
        }
        let profileViewController = ProfileViewController()
        
        let profilePresenter = ProfilePresenter(helper: ProfileHelper())
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
