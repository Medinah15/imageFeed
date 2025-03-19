//
//  UIBlockingProgressHUD.swift
//  imageFeed
//
//  Created by Medina Huseynova on 19.03.25.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func show() {
        // Блокируем взаимодействие с UI
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()  // Показываем индикатор активности
    }
    
    static func dismiss() {
        // Восстанавливаем взаимодействие с UI
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()  // Скрываем индикатор активности
    }
}

