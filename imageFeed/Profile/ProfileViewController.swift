//
//  ProfileViewController.swift
//  imageFeed
//
//  Created by Medina Huseynova on 07.02.25.

import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let imageView = UIImageView()
    private let label1 = UILabel()
    private let label2 = UILabel()
    private let label3 = UILabel()
    private let button = UIButton()
    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
    
    private func updateAvatar() { 
            guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
            else { return }
            // TODO [Sprint 11] Обновить аватар, используя Kingfisher
        }
        
    
    // MARK: - Setup UI
    private func setupUI() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "avatar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        let label1 = UILabel()
        label1.text = "Екатерина Новикова"
        label1.textColor = .white
        label1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label1)
        NSLayoutConstraint.activate([
            label1.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            label1.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 16)
        ])
        
        let label2 = UILabel()
        label2.text = "@ekaterina_nov"
        label2.textColor = .gray
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        NSLayoutConstraint.activate([
            label2.leadingAnchor.constraint(equalTo: label1.leadingAnchor),
            label2.topAnchor.constraint(equalTo: label1.bottomAnchor, constant: 8),
            label2.trailingAnchor.constraint(equalTo: label1.trailingAnchor)
        ])
        
        let label3 = UILabel()
        label3.text = "Hello, World"
        label3.textColor = .white
        label3.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label3)
        NSLayoutConstraint.activate([
            label3.leadingAnchor.constraint(equalTo: label1.leadingAnchor),
            label3.topAnchor.constraint(equalTo: label2.bottomAnchor, constant: 8),
            label3.trailingAnchor.constraint(equalTo: label1.trailingAnchor)
        ])
        
        let button = UIButton()
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // MARK: - Update Profile Details
    private func updateProfileDetails(profile: Profile?) {
            guard let profile = profile else {
                print("❌ Профиль не найден")
                return
            }
            
            label1.text = profile.name
            label2.text = profile.loginName
            label3.text = profile.bio
        }
    
    @objc func didTapButton() {
        print("Выход из профиля")
    }
}

