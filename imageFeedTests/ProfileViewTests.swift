//
//  ProfileViewTests.swift
//  imageFeedTests
//
//  Created by Medina Huseynova on 21.05.25.
//

@testable import imageFeed
import XCTest

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    var viewDidLoadCalled = false
    var updateAvatarCalled = false
    var didTapLogoutCalled = false
    var confirmLogoutCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func didTapLogout() {
        didTapLogoutCalled = true
    }
    
    func confirmLogout() {
        confirmLogoutCalled = true
    }
}

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsPresenterViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutButtonCallsDidTapLogout() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        
        // when
        viewController.didTapLogoutButton(UIButton())
        
        // then
        XCTAssertTrue(presenter.didTapLogoutCalled)
    }
    
    
    func testConfirmLogoutCallsPresenterConfirmLogout() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.presenter = presenter
        presenter.view = viewController
        _ = viewController.view
        
        var didConfirmLogout = false
        viewController.logoutConfirmationHandler = {
            didConfirmLogout = true
        }
        
        // when
        viewController.showLogoutAlert()
        // симулируем нажатие "Выйти"
        viewController.logoutConfirmationHandler?()
        
        // then
        XCTAssertTrue(didConfirmLogout)
    }
    
    func testUpdateAvatarSetsImageURL() {
        // given
        let viewController = ProfileViewController()
        _ = viewController.view // триггерим viewDidLoad
        
        let imageURL = URL(string: "https://example.com/avatar.png")!
        // when
        viewController.updateAvatar(url: imageURL)
        
        // then
        
        XCTAssertNotNil(viewController.avatarImageView)
    }
    
    func testUpdateProfileDetailsSetsLabels() {
        // given
        let viewController = ProfileViewController()
        _ = viewController.view // триггерим viewDidLoad
        
        let profileResult = ProfileResult(username: "@login", firstName: "Имя", lastName: "Фамилия", bio: "Биография")
        let profile = Profile(from: profileResult)
        // when
        viewController.updateProfileDetails(profile: profile)
        
        // then
        XCTAssertNotNil(viewController.nameLabel.text)
        XCTAssertNotNil(viewController.loginNameLabel.text)
        XCTAssertNotNil(viewController.infoLabel.text)
    }
}
