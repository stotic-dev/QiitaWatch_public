//
//  AlertExecutor.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/14.
//

import UIKit

@MainActor
struct AlertExecutor: Equatable {
    
    typealias Handler = () -> Void
    
    private let alertCase: AlertCase
    
    init(alertCase: AlertCase) {
        
        self.alertCase = alertCase
    }
    
    func showAlert(target: UIViewController,
                   firstHandler: @escaping Handler,
                   secondHandler: @escaping Handler = {}) {
        
        let alert = UIAlertController(title: alertCase.title,
                                      message: nil,
                                      preferredStyle: .alert)
        
        switch alertCase.handlerType {
            
        case .only:
            alert.addAction(.init(title: alertCase.firstButtonTitle,
                                  style: .default) { _ in
                
                firstHandler()
            })
            
        case .double:
            alert.addAction(.init(title: alertCase.firstButtonTitle,
                                  style: .default) { _ in
                
                firstHandler()
            })
            
            if let secondButtonTitle = alertCase.secondButtonTitle {
                
                alert.addAction(.init(title: secondButtonTitle,
                                      style: .default) { _ in
                    
                    secondHandler()
                })
            }
            else {
                
                assertionFailure("通ることを想定していないコード")
            }
        }
        
        target.present(alert, animated: true)
    }
}
