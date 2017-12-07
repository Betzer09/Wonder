//
//  AppDelegate.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        GenresController.shared.fetchMovieGenres()
        GenresController.shared.fetchTvShowGenres()
        
        let listOfGenres = GenresController.shared.movieGenres
        GenresController.shared.fetchImageForGenre(genres: listOfGenres)
        
        return true
    }



}

