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
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var topCardView: UIView!
    @IBOutlet weak var bottomCardView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var topCardImage: UIImageView!
    @IBOutlet weak var bottomCardImage: UIImageView!
    @IBOutlet weak var customTopCardLabel: UILabel!
    @IBOutlet weak var customBottomCardLabel: UILabel!
    @IBOutlet weak var userInfoLabel: UILabel!
    
    // MARK: - Notifcations
    let questionCounterObserver = Notification.Name("questionCounterObserver")
    
    // MARK: - Counter Properties
    var questionCounter = 0 {
        didSet {
            NotificationCenter.default.post(name: questionCounterObserver, object: nil)
        }
    }
    var indexOfGenre = 0
    var similerMoviesCounter = 0
    
    var maxMovieGenreCount: Int?
    var likedGenresCount: Int?
    
    // MARK: - Array Properties
    var discoveredMovies: [Movie] = []
    /// This is an array full of similar movies that we will display to the user.
    var similarMoviesToWhatWeWillRecommend: [Movie] = []

    
    // MARK: - Boolean Properties
    var switchToQuestions = false
    var haveGenresReset = false
    var disLikeButtonAnimationCompleted = true
    var hasLikeButtonAnimationCompleted = true
    var hasSegued = false

    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Watches to see if a genre has been updated
        NotificationCenter.default.addObserver(self, selector: #selector(refreshLikeGenres), name: GenresController.likedMovieGenresArrayWasUpdated, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshSimilarMovies), name: MovieController.similarMoviesToDisplayToTheUserWasUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(presentSimilarMovies), name: questionCounterObserver, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(displayFinalResults), name: MovieController.recommendedTheaterMoviesToDisplayToTheUserWasUpdated, object: nil)
        resetView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: GenresController.likedMovieGenresArrayWasUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: questionCounterObserver, object: nil)
        NotificationCenter.default.removeObserver(self, name: MovieController.recommendedTheaterMoviesToDisplayToTheUserWasUpdated, object: nil)
    }
    
    // MARK: - Actions
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        guard let card = sender.view else {return }
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        let scale = min(100/abs(xFromCenter), 1)
        
        panCardAnimation(card: card, point: point, xFromCenter: xFromCenter, scale: scale)
        
        let genreToModify = GenresController.shared.movieGenres[indexOfGenre]
        
        if sender.state == .ended {
            // After they have toggled a genre we need to figure out if we need to switch to movies
            guard let likedGenresCount = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {print("Broken likedGenreCount");return}
            
            if card.center.x < 75 {
                // Move off to the left side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    // This going to check if we need to start asking qustions or if we need to continue displaying genre types
                    if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                    } else {
                        // If they haven't picked three genres that they like make them start over
                        if self.indexOfGenre == maxMovieGenreCount - 1 && likedGenresCount != 3{
                            self.haveGenresReset = true
                            self.indexOfGenre = 0
                            self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                        } else {
                            // This checks if we need to switch to similar movies
                            if self.questionCounter > 3 {
                                let movie = MovieController.shared.similarMoviesToDisplayToTheUser[self.similerMoviesCounter]
                                guard let updatedMovie = MovieController.shared.toggleSimilarMoviesStatisFor(movie: movie, with: false) else {return}
                                MovieController.shared.filterOutSimilarMovieWith(movie: updatedMovie)
                                self.similerMoviesCounter += 1
                                self.resetTopCardWithSimilarMovies(self.topCardView)
                                print("Foo")
                            } else {
                                let question = QuestionController.shared.questions[self.questionCounter - 1 ]
                                self.prepareForNextQuestion(question: question, isLiked: false, completion: { (isComplete) in
                                    if isComplete {
                                        
                                    }
                                })
                            }
                        }
                    }
                })
            } else if card.center.x > (view.frame.width - 75) {
                // Move off to the right side
                UIView.animate(withDuration: 0.3, animations: {
                    card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                    card.alpha = 0
                }, completion: { (_) in
                    // This checks if it needs to switch to questions
                    if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: true)
                    } else {
                        // This checks if we need to switch to similar movies
                        if self.questionCounter > 3 {
                            let movie = MovieController.shared.similarMoviesToDisplayToTheUser[self.similerMoviesCounter]
                            guard let updatedMovie = MovieController.shared.toggleSimilarMoviesStatisFor(movie: movie, with: true) else {return}
                            MovieController.shared.filterOutSimilarMovieWith(movie: updatedMovie)
                            self.similerMoviesCounter += 1
                            self.resetTopCardWithSimilarMovies(self.topCardView)
                            // Now we need to filter the array and check the count that way we can present the results
                        } else {
                            let question = QuestionController.shared.questions[self.questionCounter - 1]
                            self.prepareForNextQuestion(question: question, isLiked: true, completion: { (isComplete) in
                                if isComplete {
                                    
                                }
                            })
                        }
                    }
                    
                })
            } else {
                resetPostionOfCardWithAnimation(card)
            }
        }
        
    }
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        animateTopCardWhenLikeButtonIsPressed()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func dislikeButtonPressed(_ sender: Any) {
        animateTopCardWhenDislikeButtonIsPressed()
    }
    
    
    
    // MARK: - Card Button Animations
    private func panCardAnimation(card: UIView, point: CGPoint, xFromCenter: CGFloat, scale: CGFloat) {
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
    }
    
    /// Animates the top card to slide to the right
    private  func animateTopCardWhenLikeButtonIsPressed() {
        guard let card = self.topCardView else {return}
        if hasLikeButtonAnimationCompleted {
            self.hasLikeButtonAnimationCompleted = false
            UIView.animate(withDuration: 0.5 , animations: {
                card.center = CGPoint(x: card.center.x + 200, y: card.center.y + 75)
                card.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (_) in
                // This checks if it needs to switch to questions
                self.hasLikeButtonAnimationCompleted = true
                guard let likedGenresCount = self.likedGenresCount else {return}
                let genreToModify = GenresController.shared.movieGenres[self.indexOfGenre]
                if self.indexOfGenre + 1 != self.maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: true)
                } else {
                    let question = QuestionController.shared.questions[self.questionCounter - 1]
                    self.prepareForNextQuestion(question: question, isLiked: true, completion: { (isComplete) in
                        if isComplete {
                            // TODO: -  Fetch Movies
                            self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                        }
                    })
                }
            }
        }
    }
    
    /// Animates the top card to slide to the left
    private func animateTopCardWhenDislikeButtonIsPressed() {
        guard let card = self.topCardView else {return}
        if disLikeButtonAnimationCompleted {
            self.disLikeButtonAnimationCompleted = false
            UIView.animate(withDuration: 0.5 , animations: {
                card.center = CGPoint(x: card.center.x - 200, y: card.center.y + 75)
                card.alpha = 0
                card.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }) { (_) in
                // This checks if it needs to switch to questions
                guard let likedGenresCount = self.likedGenresCount, let maxMovieGenreCount = self.maxMovieGenreCount else {print("Broken likedGenreCount");return}
                let genreToModify = GenresController.shared.movieGenres[self.indexOfGenre]
                // This going to check if we need to start asking qustions or if we need to continue displaying genre types
                if self.indexOfGenre + 1 != maxMovieGenreCount && self.switchToQuestions == false && likedGenresCount <=  3 {
                    self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                } else {
                    // If they haven't picked three genres that they like make them start over
                    if self.indexOfGenre == maxMovieGenreCount - 1 && likedGenresCount != 3{
                        self.haveGenresReset = true
                        self.indexOfGenre = 0
                        self.completeAnimationForGenreUsing(card: card, likedGenresCount: likedGenresCount, genreToModify: genreToModify, isLiked: false)
                    } else {
                        // When this runs we are starting to ask general question before we start fetch movies
                        let question = QuestionController.shared.questions[self.questionCounter - 1 ]
                        self.prepareForNextQuestion(question: question, isLiked: false, completion: { (isComplete) in
                            if isComplete {
                                // TODO: -  Fetch Movies
                                self.setCustomText(toLabel: self.customBottomCardLabel, text: "Coming SOOOOOOON")
                            }
                        })
                    }
                }
                self.disLikeButtonAnimationCompleted = true
            }
        }
    }
    
    
    // MARK: - SetUp UI
    private func configureView() {
        // Reset this value evertime the view is loaded so the expirances is the same
        GenresController.shared.genreMoviesThatHaveAlreadyBeenDisplayed.removeAll()
        
        self.topCardView.layer.cornerRadius = 20.0
        self.bottomCardView.layer.cornerRadius = 20.0
        
        self.topCardImage.layer.shadowColor = UIColor.black.cgColor
        self.topCardImage.layer.shadowOpacity = 1
        self.topCardImage.layer.shadowOffset = CGSize.zero
        self.topCardImage.layer.shadowRadius = 15
        self.topCardImage.layer.shadowPath = UIBezierPath(rect: topCardImage.bounds).cgPath
        self.topCardImage.layer.shouldRasterize = true
        
        self.bottomCardImage.layer.shadowColor = UIColor.black.cgColor
        self.bottomCardImage.layer.shadowOpacity = 1
        self.bottomCardImage.layer.shadowOffset = CGSize.zero
        self.bottomCardImage.layer.shadowRadius = 15
        self.bottomCardImage.layer.shadowPath = UIBezierPath(rect: bottomCardImage.bounds).cgPath
        self.bottomCardImage.layer.shouldRasterize = true
        
        
        maxMovieGenreCount = GenresController.shared.movieGenres.count
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        discoveredMovies = MovieController.shared.discoveredMoviesBasedOnGenres
        let genreImageIDForTopCard = GenresController.shared.movieGenres[indexOfGenre]
        let genreImageIDForBottomCard = GenresController.shared.movieGenres[indexOfGenre + 1]
        fetchTheTopCardImageWith(genre: genreImageIDForTopCard)
        fetchTheBottomCardImageWith(genre: genreImageIDForBottomCard)
        self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
        
    }
    
    private func resetView() {
        GenresController.shared.likedMovieGenres.removeAll()
        GenresController.shared.unlikedMovieGenres.removeAll()
        similerMoviesCounter = 0
        indexOfGenre = 0
        questionCounter = 0
        switchToQuestions = false
        hasSegued = false
    }
    
    // MARK: - Notifications Functions
    
    @objc func presentSimilarMovies() {
        if questionCounter > 3 {
            self.resetTopCardWithSimilarMoviesForTheFirstTime(topCardView)
        }
    }
    
    @objc func displayFinalResults() {
        guard let count = MovieController.shared.recommendedTheaterMoviesToDisplayToTheUser?.count else {return}
        if count <= 3 || similerMoviesCounter >= count - 1{
            guard !hasSegued else {return}
            hasSegued = true
            self.presentTheaterMovieResultsViewController()
        }
        
    }
    
    @objc func refreshSimilarMovies() {
//        self.similarMoviesToWhatWeWillRecommend = MovieController.shared.similarMoviesToDisplayToTheUser
//
//        if similarMoviesToWhatWeWillRecommend.count <= 3 {
//            guard !hasSegued else { return }
//            hasSegued = true
//            self.presentTheaterMovieResultsViewController()
//        }
//        print("Similar Movies Have changes")
    }
    
    @objc func refreshLikeGenres(card: UIView?) {
        likedGenresCount = GenresController.shared.likedMovieGenres.count
        
        guard let count = likedGenresCount, let maxMovieGenreCount = maxMovieGenreCount else {return}
        if count > 3  || indexOfGenre >= maxMovieGenreCount {
            // Sets the top card to start questions
            configureTopCardAsQuestion(topCardView)
            configureBottomCardAsQuestion(bottomCardImage)
            switchToQuestions = true
        }
        print("There are \(likedGenresCount!) Liked Genres")
    }
    
    // MARK: - Methods
    private func presentTheaterMovieResultsViewController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "toResultsTVC", sender: self)
        }
    }
    
    private func prepareForNextQuestion(question: Question, isLiked: Bool, completion: @escaping (_ isComplete: Bool) -> Void ) {
        QuestionController.shared.toggleStatusForQuestion(question: question, isLiked: isLiked)
        if questionCounter == 3 {
            // We have answered all of the questions it is now time to fetch movies 
            self.configureBottomCardAsQuestion(self.bottomCardView)
            completion(true)
        } else {
            self.configureBottomCardAsQuestion(self.bottomCardView)
            completion(false)
        }
        
    }
    
    private func completeAnimationForGenreUsing(card: UIView, likedGenresCount: Int ,genreToModify: Genre, isLiked: Bool) {
        self.resetTopCardForGenres(card)
        self.checkIfTheGenreNeedsToggled(withCount: likedGenresCount, andGenre: genreToModify, isLiked: isLiked)
        
        guard let maxMovieGenreCount = maxMovieGenreCount else {return}
        
        var genreToFetch: Genre
        
        // This decides if we need to switch to questions or not
        if switchToQuestions == false {
            if (indexOfGenre + 1) != (maxMovieGenreCount){
                // Fetch the the new bottom card
                if haveGenresReset {
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre]
                    haveGenresReset = false
                    // Fetch the top and bottom images
                    self.fetchTheTopCardImageWith(genre: genreToFetch)
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre + 1]
                    self.fetchTheBottomCardImageWith(genre: genreToFetch)
                } else {
                    genreToFetch = GenresController.shared.movieGenres[self.indexOfGenre + 1]
                    self.fetchTheBottomCardImageWith(genre: genreToFetch)
                }
            } else {
                // This sets the very last genre to the top card
                topCardImage.image = bottomCardImage.image
                customTopCardLabel.text = customBottomCardLabel.text
            }
        }
        else {
            configureBottomCardAsQuestion(bottomCardView)
        }
    }
    
    private func setCustomText(toLabel label: UILabel, text: String) {
        DispatchQueue.main.async {
            label.text = text
        }
    }
    
    /// Checks to see if the genre needs to be toggled
    private func checkIfTheGenreNeedsToggled(withCount count: Int, andGenre genre: Genre, isLiked: Bool) {
        // This will toggle the genre as long as they haven't already liked three.
        if count < 4 {
            GenresController.shared.toggleIsLikedStatusFor(genre: genre, isLiked: isLiked)
            if haveGenresReset {
                indexOfGenre = 0
            } else {
                indexOfGenre += 1
            }
        }
    }
    
    // MARK: - Card Postion Functions
    
    private func resetTopCardWithSimilarMoviesForTheFirstTime(_ card: UIView) {
        
        MovieController.shared.fetchRecommendedMovies(completion: { (isComplete) in
            if isComplete {
                self.similarMoviesToWhatWeWillRecommend = MovieController.shared.similarMoviesToDisplayToTheUser
                let topCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter]
                
                
                guard let topImageData = topCardSimilarMovie.imageData else {NSLog("Error there is not image data for \(topCardSimilarMovie.title) in function \(#function)"); return}
                self.topCardImage.image = UIImage(data: topImageData)
                
                self.setCustomText(toLabel: self.customTopCardLabel, text: "Did you like watching \"\(topCardSimilarMovie.title)\"?")
                
                // Makes sure we aren't out fo rang
                var bottomCardSimilarMovie: Movie
                if self.similerMoviesCounter <= self.similarMoviesToWhatWeWillRecommend.count - 1 {
                     bottomCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter + 1]
                } else {
                     bottomCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter]
                }
                guard let bottomImageData = bottomCardSimilarMovie.imageData else {NSLog("Error there is not image data for \(bottomCardSimilarMovie.title) in function \(#function)"); return}
                self.bottomCardImage.image = UIImage(data: bottomImageData)
                self.setCustomText(toLabel: self.customBottomCardLabel, text: "Did you like watching \"\(bottomCardSimilarMovie.title)\"?")
                self.resetPostitionOf(card: card)
            }
        })
        
    }
    
    private func resetTopCardWithSimilarMovies(_ card: UIView) {
        
        if hasSegued {return}
        let topCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter]
        
        
        guard let topImageData = topCardSimilarMovie.imageData else {NSLog("Error there is not image data for \(topCardSimilarMovie.title) in function \(#function)"); return}
        self.topCardImage.image = UIImage(data: topImageData)
        
        self.setCustomText(toLabel: self.customTopCardLabel, text: "Did you like watching \"\(topCardSimilarMovie.title)\"?")
        
        // Makes sure we aren't out fo rang
        var bottomCardSimilarMovie: Movie
        if self.similarMoviesToWhatWeWillRecommend.count - 1 > self.similerMoviesCounter{
            bottomCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter + 1]
        } else {
            bottomCardSimilarMovie = self.similarMoviesToWhatWeWillRecommend[self.similerMoviesCounter]
        }
        guard let bottomImageData = bottomCardSimilarMovie.imageData else {NSLog("Error there is not image data for \(bottomCardSimilarMovie.title) in function \(#function)"); return}
        self.bottomCardImage.image = UIImage(data: bottomImageData)
        self.setCustomText(toLabel: self.customBottomCardLabel, text: "Did you like watching \"\(bottomCardSimilarMovie.title)\"?")
        self.resetPostitionOf(card: card)
    }
    
    private func resetTopCardForGenres(_ card: UIView?) {
        guard let card = card else {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
            return
        }
        topCardImage.image = bottomCardImage.image
        if haveGenresReset {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
        } else {
            self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
        }
        resetPostitionOf(card: card)
        
    }
    
    private func fetchTheTopCardImageWith(genre: Genre) {
        guard let data = genre.genreImageData else {print("Error there is no image data for genre \"\(genre.name)\" in file \(#file) and function \(#function)"); return}
        DispatchQueue.main.async {
            self.topCardImage.image = UIImage(data: data)
        }
        self.setCustomText(toLabel: self.customTopCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre].name) movies?")
    }
    
    private func fetchTheBottomCardImageWith(genre: Genre) {
        guard let data = genre.genreImageData else {print("Error there is no image data for genre \"\(genre.name)\" in file \(#file) and function \(#function)"); return}
        
        DispatchQueue.main.async {
            self.bottomCardImage.image = UIImage(data: data)
        }
        self.setCustomText(toLabel: self.customBottomCardLabel, text: "Do you like \(GenresController.shared.movieGenres[self.indexOfGenre + 1].name) movies?")
    }
    
    
    
    
    private func configureTopCardAsQuestion(_ card: UIView) {
        if questionCounter < QuestionController.shared.questions.count && switchToQuestions == false {
            resetPostitionOf(card: card)
            self.topCardImage.image = #imageLiteral(resourceName: "noImageView")
            setCustomText(toLabel: customTopCardLabel, text: "\(QuestionController.shared.questions[questionCounter].text)")
        } else {
            // This will run after the bottom question card has initally been set that way it doesn't bounce
            if questionCounter <= 2 {
                self.topCardImage.image = #imageLiteral(resourceName: "noImageView")
                setCustomText(toLabel: customTopCardLabel, text: QuestionController.shared.questions[questionCounter].text)
                questionCounter += 1
                resetPostitionOf(card: card)
            } else {
                questionCounter += 1
            }
        }
    }
    
    private func configureBottomCardAsQuestion(_ card: UIView) {
        
        if questionCounter + 1 < QuestionController.shared.questions.count && switchToQuestions == false {
            DispatchQueue.main.async {
                self.bottomCardImage.image = #imageLiteral(resourceName: "noImageView")
            }
            setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter].text)
        } else {
            DispatchQueue.main.async {
                self.bottomCardImage.image = #imageLiteral(resourceName: "noImageView")
            }
            // This is to check to see if this is the last question that needs to be displayed
            if questionCounter >= 2 {
                setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter - 1].text)
                configureTopCardAsQuestion(topCardView)
            } else {
                setCustomText(toLabel: customBottomCardLabel, text: QuestionController.shared.questions[questionCounter + 1].text)
                configureTopCardAsQuestion(topCardView)
            }
        }
    }
    
    
    // MARK: - Card Reset Functions
    /// This repositions the card back to the center
    private func resetPostitionOf(card: UIView) {
        card.center = self.view.center
        self.thumbImageView.alpha = 0
        card.alpha = 1
        card.transform = .identity
    }
    
    private func resetPostionOfCardWithAnimation(_ card: UIView) {
        UIView.animate(withDuration: 0.3) {
            card.center = self.view.center
            self.thumbImageView.alpha = 0
            card.alpha = 1
            card.transform = .identity
        }
    }
}
