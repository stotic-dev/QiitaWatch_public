//
//  AsyncImageView.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import UIKit

final class AsyncImageView: UIImageView {
    
    // MARK: - private property
    
    // MARK: view model
    
    private let viewModel: AsyncImageViewModel
    
    // MARK: state
    private var progressIndicator: ProgressIndicatorView?
    
    // MARK: - factory method
    
    static func getInstance(url: URL?) -> UIImageView {
        
        let viewModel = AsyncImageViewModel(imageURL: url)
        let imageView = AsyncImageView(viewModel: viewModel)
        return imageView
    }
    
    // MARK: - initialize method
    
    private init(viewModel: AsyncImageViewModel, frame: CGRect = .zero) {
        
        self.viewModel = viewModel
        super.init(frame: frame)
        
        guard let stream = viewModel.stateObserver else {
            
            assertionFailure("Failed create state observer.")
            return
        }
        
        addViewStateObserver(stream)
        
        Task {
            
            await viewModel.onAppear()
        }
    }
    
    required init?(coder: NSCoder) {
        
        guard let viewModel = coder.decodeObject(forKey: "viewModel") as? AsyncImageViewModel else { return nil }
        self.viewModel = viewModel
        super.init(coder: coder)
        
        guard let stream = viewModel.stateObserver else {
            
            assertionFailure("Failed create state observer.")
            return
        }
        
        addViewStateObserver(stream)
        
        Task {
            
            await viewModel.onAppear()
        }
    }
}

// MARK: - private method

private extension AsyncImageView {
    
    func addViewStateObserver(_ viewStateStream: AsyncStream<AsyncImageViewModel.ViewState>) {
        
        Task {
            
            for await state in viewStateStream {
                
                switch state {
                    
                case .initial(let state):
                    updateViewState(state)
                    
                case .appeared(let state):
                    updateViewState(state)
                    removeProgressIndicator()
                    
                case .loading:
                    showProgressIndicator()
                }
            }
        }
    }
    
    func updateViewState(_ state: AsyncImageViewModel.ViewStateEntity) {
        
        self.image = state.image
    }
    
    func showProgressIndicator() {
        
        progressIndicator = ProgressIndicatorView()
        self.addSubview(progressIndicator!)
        self.bringSubviewToFront(progressIndicator!)
        
        progressIndicator?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressIndicator!.topAnchor.constraint(equalTo: self.topAnchor),
            progressIndicator!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            progressIndicator!.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            progressIndicator!.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func removeProgressIndicator() {
        
        guard let progressIndicator else { return }
        progressIndicator.removeFromSuperview()
    }
}
