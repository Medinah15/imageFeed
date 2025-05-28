//
//  ProfilePresenter.swift
//  imageFeed
//
//  Created by Medina Huseynova on 20.05.25.
//

import Foundation

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar()
    func confirmLogout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageObserver: NSObjectProtocol?
    private let helper: ProfileHelperProtocol
    
    init(helper: ProfileHelperProtocol = ProfileHelper()) {
        self.helper = helper
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
        
        profileImageObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }
        
        updateAvatar()
    }
    
    func updateAvatar() {
        let url = helper.avatarURL(withBaseURL: ProfileImageService.shared.avatarURL)
        if let url = url {
            view?.updateAvatar(url: url)
        }
    }
    
    func confirmLogout() {
        profileLogoutService.logout()
    }
    
    deinit {
        if let observer = profileImageObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

