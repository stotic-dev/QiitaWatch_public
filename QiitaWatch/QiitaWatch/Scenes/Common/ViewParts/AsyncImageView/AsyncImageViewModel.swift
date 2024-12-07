//
//  AsyncImageViewModel.swift
//  QiitaWatch
//
//  Created by 佐藤汰一 on 2024/11/16.
//

import UIKit

@MainActor
final class AsyncImageViewModel {
    
    // MARK: - public property
    
    private(set) var stateObserver: AsyncStream<ViewState>?
    
    // MARK: - private property
    
    // MARK: dependency
    
    private let cloudImageRepository: CloudImageRepository
    
    // MARK: state
    
    private var continuation: AsyncStream<ViewState>.Continuation?
    
    // MARK: constant
    
    private let imageURL: URL?
    /// AsyncImageViewのデフォルトの画像
    private static let defaultAsyncImage = UIImage(systemName: "questionmark")!
    
    // MARK: - initialize method
    
    init(imageURL: URL?,
         cloudImageRepository: CloudImageRepository = CloudImageRepositoryImpl()) {
        
        self.imageURL = imageURL
        self.cloudImageRepository = cloudImageRepository
        stateObserver = AsyncStream<ViewState> { [weak self] continuation in
            
            self?.continuation = continuation
            continuation.yield(.initial(state: .init(Self.defaultAsyncImage)))
        }
    }
    
    // MARK: - public method
    
    /// 画面表示時
    func onAppear() async {
        
        log.info("Start download image(url=\(imageURL?.absoluteString ?? "nil")).")
        continuation?.yield(.loading)
        
        do {
            
            guard let imageURL else {
                
                throw DownloadError(reason: "Failed download image. because url is nil.")
            }
            
            guard let imageData = try await cloudImageRepository.download(imageURL),
            let image = UIImage(data: imageData) else {
                
                throw DownloadError(reason: "Failed download image. because response data is nil.")
            }
            
            continuation?.yield(.appeared(state: .init(image)))
            log.info("Complete download image.")
        }
        catch {
            
            log.warning("Failed download image(reason: \(error)).")
            continuation?.yield(.appeared(state: .init(Self.defaultAsyncImage)))
        }
        
        continuation?.finish()
    }
}


// MARK: - view state definition

extension AsyncImageViewModel {
    
    enum ViewState: Equatable {
        
        /// 初期状態
        case initial(state: ViewStateEntity)
        /// 画面表示中
        case appeared(state: ViewStateEntity)
        /// ロード中
        case loading
    }
    
    struct ViewStateEntity: Equatable {
        
        /// 画像
        let image: UIImage
                
        init(_ image: UIImage) {
            
            self.image = image
        }
    }
    
    struct DownloadError: Error {
        
        let reason: String
    }
}

// MARK: - conform Equtable

extension AsyncImageViewModel: @preconcurrency Equatable {
    
    static func == (lhs: AsyncImageViewModel, rhs: AsyncImageViewModel) -> Bool {
        
        return lhs.imageURL == rhs.imageURL
    }
}
