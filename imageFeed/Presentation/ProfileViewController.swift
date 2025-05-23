//
//  ProfileViewController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 07.02.25.

import UIKit
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileDetails(profile: Profile?)
    func updateAvatar(url: URL)
    func didTapLogoutButton(_ sender: UIButton)
    func showLogoutAlert()
    func switchToAuthScreen()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    // MARK: - UI
    
    let avatarImageView = UIImageView()
    let nameLabel = UILabel()
    let loginNameLabel = UILabel()
    let infoLabel = UILabel()
    let logoutButton = UIButton()
    
    // MARK: - Properties
    
    var presenter: ProfilePresenterProtocol?
    var logoutConfirmationHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        presenter?.viewDidLoad()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFill
        view.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        avatarImageView.layer.cornerRadius = 35
        avatarImageView.clipsToBounds = true
        
        nameLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        nameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo:avatarImageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
        
        loginNameLabel.textColor = UIColor(red: 174/255, green: 175/255, blue: 180/255, alpha: 1)
        loginNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        loginNameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginNameLabel)
        NSLayoutConstraint.activate([
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
        
        infoLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        infoLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        infoLabel.numberOfLines = 0
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview( infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            infoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
        
        logoutButton.setImage(UIImage(named: "logout_button"), for: .normal)
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    internal func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {
            print("❌ Профиль не найден")
            return
        }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        infoLabel.text = profile.bio
    }
    
    func updateAvatar(url: URL) {
        avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
    }
    
    // MARK: - Actions
    
    @objc func didTapLogoutButton(_ sender: UIButton) {
        presenter?.didTapLogout()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: "Выход",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            self.logoutConfirmationHandler?() ?? self.presenter?.confirmLogout()
        })
        present(alert, animated: true)
    }
    
    func switchToAuthScreen() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window or scene configuration")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let splashVC = SplashViewController()
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
    }
}

