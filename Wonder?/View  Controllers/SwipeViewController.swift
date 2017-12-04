//
//  SwipeViewController.swift
//  Wonder?
//
//  Created by Austin Betzer on 11/21/17.
//  Copyright © 2017 SPARQ. All rights reserved.
//

import UIKit

class SwipeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var bottomCardView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var topCardImage: UIImageView!
    
    
    // MARK: - Properties
    var genreCount: Int?
    var indexOfGenre = 0
    var availableGenres: [Genre] = []
    var likedGenresCount: Int?
    var discoveredMovies: [Movie] = []
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // Watches to see if a genre has been updated
        NotificationCenter.default.addObserver(self, selector: #selector(refetchGenres), name: GenresController.movieGenreWasUpatedNotifaction, object: nil)
        
    }
    
    // MARK: - SetUp UI
    func configureView() {
        genreCount = GenresController.shared.movieGenres.count
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        availableGenres = GenresController.shared.movieGenres
        discoveredMovies = MovieController.shared.discoveredMoviesBasedOnGenres
        
        let genreImageID = GenresController.shared.movieGenres[indexOfGenre].id 
        fetchTheImageForGenreWith(genreID: genreImageID)
    }
    
    // MARK: - Actions
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {return }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        let scale = min(100/abs(xFromCenter), 1)
        
        if xFromCenter > 0 {
            // The card is going right
            thumbImageView.image = #imageLiteral(resourceName: "thumbsUp")
        } else {
            // The card is going left
            thumbImageView.image = #imageLiteral(resourceName: "thumbsDown")
        }
        
        thumbImageView.alpha = abs(xFromCenter) / view.center.x
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        card.transform = CGAffineTransform(rotationAngle: (xFromCenter / view.frame.width) * 0.61).scaledBy(x: scale, y: scale)
        

        let genreToModify = GenresController.shared.movieGenres[indexOfGenre]
        let genreImageID = genreToModify.id
        guard let likedGenresCount = likedGenresCount else {print("Broken likedGenreCount");return}
        
        if sender.state == .ended {
//            checkLikedGenreCount(withCount: likedGenresCount)
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    self.setBottomCardToTop(card)
                    return
                })
                checkIfTheGenreNeedsToggled(withCount: likedGenresCount, andGenre: genreToModify, isLiked: false)
                // We need to fetch everytime the genre gets swicthed
                
                fetchTheImageForGenreWith(genreID: genreImageID)
                
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    self.setBottomCardToTop(card)
                    return
                })
                checkIfTheGenreNeedsToggled(withCount: likedGenresCount, andGenre: genreToModify, isLiked: true)
                fetchTheImageForGenreWith(genreID: genreImageID)
                
            } else {
                resetCard()
            }
        }
        
    }
    
    
    // MARK: - Methods
    
    func fetchTheImageForGenreWith(genreID id: Int) {
        GenresController.shared.fetchImageForGenre(with: id, completion: { (image) in
            guard let image = image else {print("Error with the image in file: \(#file) and function: \(#function)"); return}
            DispatchQueue.main.async {
                self.topCardImage.image = image            }
        })
    }
    
    func checkLikedGenreCount(withCount count: Int) {
        guard let likedGenresCount = likedGenresCount else {print("Broken likedGenreCount");return}
        
        if likedGenresCount >= 3 {
            // Fetch those movies
            let ids = GenresController.shared.likedMovieGenres.flatMap({ $0.id })
            MovieController.shared.fetchMoviesBasedOnGenresWith(ids: ids, pageCount: 1, completion: { (_) in})
            
            let movie = discoveredMovies[0]
            MovieController.shared.fetchImageWith(endpoint: movie.posterPath, completion: { (image) in})
            
        }
    }
    
    /// Checks to see if the genre needs to be toggled
    func checkIfTheGenreNeedsToggled(withCount count: Int, andGenre genre: Genre, isLiked: Bool) {
        if count < 3 {
            GenresController.shared.toggleIsLikedStatusFor(genre: genre, isLiked: isLiked)
        }
        indexOfGenre += 1
        

    }
    
    @objc func refetchGenres() {
        availableGenres = GenresController.shared.movieGenres
        likedGenresCount = GenresController.shared.likedMovieGenres.count
    }
    
    func setBottomCardToTop(_ card: UIView) {
        card.center = view.center
        thumbImageView.alpha = 0
        card.transform = .identity
        card.alpha = 1
        
    }
    
    /// This repositions the card back to the center
    func resetCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.topCardView.center = self.view.center
            self.thumbImageView.alpha = 0
            self.topCardView.alpha = 1
            self.topCardView.transform = .identity
        })        
    }
    
    
}
