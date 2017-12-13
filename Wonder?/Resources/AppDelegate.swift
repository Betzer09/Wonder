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
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 48 / 255.0, green: 50 / 255.0, blue: 52 / 255.0, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 173 / 255.0, green: 174 / 255.0, blue: 175 / 255.0, alpha: 1) ]
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        return true
    }



}

