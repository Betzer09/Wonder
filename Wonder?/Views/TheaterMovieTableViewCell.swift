//
//  TheaterMovieTableViewCell.swift
//  Wonder?
//
//  Created by Austin Betzer on 12/14/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class TheaterMovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    
    
    func updateCellWith(theaterMovie: TheatreMovies.TheaterMovie) {
        
        // Find the theater movie in the recommended movies list so we can get the image
        
//        guard let index = MovieController.shared.moviesThatAreSmilar.index(where: { $0.title == theaterMovie.title }),
//            let data = MovieController.shared.moviesThatAreSmilar[index].imageData,
//            let releaseDate = MovieController.shared.moviesThatAreSmilar[index].releaseDate else {return}
//
//            DispatchQueue.main.async {
//                self.movieImage.image = UIImage(data: data)
//                self.movieTitle.text = theaterMovie.title
//                guard let date = returnFormattedDateForMovieLabel(string: releaseDate), let returnDate = returnFormattedDateFrom2(date: date) else {return}
//                self.releaseDate.text = "\(returnDate)"
//            }
        
        
        
    }
    

}
