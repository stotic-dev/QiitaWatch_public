//
//  CommonNavigationButton.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/18.
//

import UIKit

extension UIBarButtonItem {
    
    static func getCommonNavigationBackButtonItem(target: UIViewController, action: Selector?) -> UIBarButtonItem {
        
        return UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: target, action: action)
    }
}
