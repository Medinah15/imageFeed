//
//  ProfileViewController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 07.02.25.

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginNameLabel = UILabel()
    private let infoLabel = UILabel()
    private let logoutButton = UIButton()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateProfileDetails(profile: profileService.profile)
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    // MARK: - Private Methods
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL
        else { return }
        //       https://images.unsplash.com/profile-1745424847523-b33e47391d28image?ixlib=rb-4.0.3&crop=faces&fit=crop&w=32&h=32
        if var components = URLComponents(string: profileImageURL) {
            
            components.queryItems = components.queryItems?.filter {
                !["crop", "fit", "w", "h"].contains($0.name)
            }
            
            let newParams: [URLQueryItem] = [
                URLQueryItem(name: "crop", value: "faces"),
                URLQueryItem(name: "w", value: "150"),
                URLQueryItem(name: "h", value: "150")
            ]
            
            components.queryItems?.append(contentsOf: newParams)
            
            let newURL = components.url
            //            https://images.unsplash.com/profile-1745424847523-b33e47391d28image?ixlib=rb-4.0.3&crop=faces&w=140&h=140
            
            avatarImageView.kf.setImage(
                with: newURL,
                options: [.transition(.fade(0.3))]
            )
        }
    }
    
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
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else {
            print("❌ Профиль не найден")
            return
        }
        
        nameLabel.text = profile.name
        loginNameLabel.text = profile.loginName
        infoLabel.text = profile.bio
    }
    
    // MARK: - Actions
    
    @IBAction private func didTapLogoutButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { _ in
            ProfileLogoutService.shared.logout()
        })
        present(alert, animated: true)
        
    }
}

