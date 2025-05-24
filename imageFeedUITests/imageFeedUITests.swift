//
//  imageFeedUITests.swift
//  imageFeedUITests
//
//  Created by Medina Huseynova on 22.05.25.
//

import XCTest

final class Image_FeedUITests: XCTestCase {
    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }
    
    func testAuth() throws {
        app.buttons["Войти"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 30), "WebView не загрузился")
        
        let loginTextField = webView.textFields.element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        
        loginTextField.tap()
        loginTextField.typeText("<Ваш e-mail>")
        
        XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout: 5), "Кнопка Done не найдена")
        app.buttons["Done"].tap()
        
        let passwordTextField = webView.secureTextFields.element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 10), "Поле пароля не найдено")
        
        passwordTextField.tap()
        passwordTextField.typeText("<Ваш пароль>")
        
        if app.buttons["Done"].exists {
            app.buttons["Done"].tap()
        }
        
        XCTAssertTrue(webView.buttons["Login"].waitForExistence(timeout: 10), "Кнопка логина не найдена")
        webView.buttons["Login"].tap()
        
        let cell = app.tables.cells.element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 15), "Лента не загрузилась")
    }
    func testFeed() throws {
        let tablesQuery = app.tables
        let firstCell = tablesQuery.cells.element(boundBy: 0)
        
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Лента не загрузилась")
        
        // Прокручиваем вниз, чтобы появились другие ячейки
        firstCell.swipeUp()
        
        let secondCell = tablesQuery.cells.element(boundBy: 1)
        XCTAssertTrue(secondCell.waitForExistence(timeout: 5), "Вторая ячейка не найдена")
        
        // Прокручиваем до второй ячейки, чтобы все элементы стали hittable
        // scrollToElement(secondCell)
        
        let likeButton = secondCell.buttons["like button off"]
        let likedButton = secondCell.buttons["like button on"]
        
        if likeButton.exists && likeButton.isHittable {
            likeButton.tap()
            
            // Ждём исчезновения старой кнопки
            let predicate = NSPredicate(format: "exists == false")
            expectation(for: predicate, evaluatedWith: likeButton, handler: nil)
            waitForExpectations(timeout: 5)
            
            XCTAssertTrue(likedButton.exists, "Кнопка после лайка не появилась")
            likedButton.tap()
        } else if likedButton.exists && likedButton.isHittable {
            likedButton.tap()
            
            let predicate = NSPredicate(format: "exists == false")
            expectation(for: predicate, evaluatedWith: likedButton, handler: nil)
            waitForExpectations(timeout: 5)
            
            let unlikedButton = secondCell.buttons["like button off"]
            XCTAssertTrue(unlikedButton.exists, "Кнопка после дизлайка не появилась")
        } else {
            XCTFail("Ни одна кнопка лайка не найдена или не доступна для нажатия")
        }
        
        func testProfile() throws {
            sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
            
            XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            app.buttons["logout button"].tap()
            
            app.alerts["Bye bye!"].scrollViews.otherElements.buttons["Yes"].tap()
        }
    }
}
