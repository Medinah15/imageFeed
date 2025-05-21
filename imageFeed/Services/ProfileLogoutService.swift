//
//  ProfileLogoutService.swift
//  imageFeed
//
//  Created by Medina Huseynova on 10.05.25.
//

import Foundation
// Обязательный импорт
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
    }
    
    private func cleanCookies() {
        OAuth2TokenStorage.shared.token = nil
        // Очищаем все куки из хранилища
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        URLCache.shared.removeAllCachedResponses()
        
        // 3. Сбросить сервисы
        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()
        // Запрашиваем все данные из локального хранилища
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            // Массив полученных записей удаляем из хранилища
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
        
        // 4. Перейти на SplashViewController (он сам покажет экран авторизации)
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Не найдено окно приложения")
            return
        }
        
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
