//
//  GenreViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/20/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class GenreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    @IBAction func buttonPressed(_ sender: Any) {
        
        GenresController.shared.fetchGenres { (genres) in
            guard let genres = genres else {return}
            print(genres.count)
        }
    }
    
    @IBAction func AnotherButtonPressed(_ sender: Any) {
        
        MovieController.shared.fetchRecommnedMoviesWith(id: 808) { (reccomenedMovies) in
            guard let reccomenedMovies = reccomenedMovies else {return}
            print(reccomenedMovies.count)
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
