//
//  SplashViewController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 06.03.25.

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.switchToTabBarController()
                
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                }
                    
            case .failure:
                // Здесь покажите ошибку получения профиля
                break
            }
        }
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        window.rootViewController = tabBarController
    }
}


// MARK: - Navigation
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            segue.identifier == showAuthenticationScreenSegueIdentifier,
            let navigationController = segue.destination as? UINavigationController,
            let viewController = navigationController.viewControllers.first as? AuthViewController
        else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        viewController.delegate = self
    }
}

// MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchProfile(code) // Отправляем запрос после авторизации
        }
    }
}


