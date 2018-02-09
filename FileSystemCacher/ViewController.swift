//
//  ViewController.swift
//  FileSystemCacher
//
//  Created by David on 08/02/2018.
//  Copyright © 2018 David. All rights reserved.
//

import UIKit

struct CachableMovies: Cachable, Codable {
    let store: String
    let movies: [Movie]
    var filename: String {
        return "movies-\(store)"
    }
    
    init(store: String, movies: [Movie]) {
        self.movies = movies
        self.store = store
    }
    
}

struct Movie: Codable {
    
    let title: String
    let description: String
    let url: URL?
    
    enum CodingKeys: String, CodingKey {
        case title = "movie_title"
        case description = "movie_description"
        case url = "movie_url"
    }
}


class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let myMoviesArray = [
//        Movie(title: "SpiderMan", description: "Blah Blah Blah", url: nil),
//        Movie(title: "Jack Reacher", description: "Blah Blah Blah", url: nil),
//        Movie(title: "John Wick", description: "Blah Blah Blah", url: nil)
//        ]
//        Cacher(destination: .temporary).persist(item: CachableMovies(store: "USA", movies: myMoviesArray)) { (url, error) in
//            if let error = error {
//                print(error)
//                return
//            }
//
//            print(url)
//        }
        
        let cachableMovies: CachableMovies = Cacher(destination: .temporary).load(filename: "movies-USA")!
        
        print(cachableMovies.movies[0].title)
        
        
        
    }

}

