//
//  PostListModuleConfigurator.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import UIKit

class PostListModuleConfigurator {
    static func configure() -> UIViewController {
        let viewController = PostListViewController()
        
        let presenter = PostListPresenter()
        let interactor = PostListInteractor()
        
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.interactor = interactor
        interactor.presenter = presenter
        
        return viewController
    }
}
