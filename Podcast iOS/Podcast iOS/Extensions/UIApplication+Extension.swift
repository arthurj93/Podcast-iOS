//
//  UIApplication+Extension.swift
//  Podcast iOS
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 03/04/21.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.windows.filter { $0.isKeyWindow}.first?.rootViewController as? MainTabBarController
    }
}
