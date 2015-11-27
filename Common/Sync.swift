//
//  Sync.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Returns dictionary of dates when content was last updated
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter completion: completion block
     
     - returns: NSURLSessionDataTask?
     */
    public func lastActivities(completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/last_activities", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Playback
    
    /**
     Whenever a scrobble is paused, the playback progress is saved. Use this progress to sync up playback across different media centers or apps. For example, you can start watching a movie in a media center, stop it, then resume on your tablet from the same spot. Each item will have the progress percentage between 0 and 100.
     
     You can optionally specify a type to only get movies or episodes.
     
     By default, all results will be returned. However, you can send a limit if you only need a few recent results for something like an "on deck" feature.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter type: Possible Values: .Movies, .Episodes
     */
    public func getPlaybackProgress(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(type)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Remove a playback item from a user's playback progress list. A 404 will be returned if the id is invalid.
     
     Status Code: 204
     
     🔒 OAuth: Required
    */
    public func removePlaybackItem(id: NSNumber, completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/playback/\(id)", authorization: true, HTTPMethod: "DELETE") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNoContentToReturn, completion: completion)
    }
    
    // MARK: - Collection
    
    /**
     Get all collected items in a user's collection. A collected item indicates availability to watch digitally or on physical media.
     
     If you add `?extended=metadata` to the URL, it will return the additional `media_type`, `resolution`, `audio`, `audio_channels` and '3d' metadata. It will use `null` if the metadata isn't set for an item.
     
     Status Code: 200
     
     🔒 OAuth: Required
    */
    public func getCollection(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection/\(type)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Add items to a user's collection. Accepts shows, seasons, episodes and movies. If only a show is passed, all episodes for the show will be collected. If seasons are specified, all episodes in those seasons will be collected.
     
     Send a `collected_at` UTC datetime to mark items as collected in the past. You can also send additional metadata about the media itself to have a very accurate collection. Showcase what is available to watch from your epic HD DVD collection down to your downloaded iTunes movies.
     
     **Note**: You can resend items already in your collection and they will be updated with any new values. This includes the `collected_at` and any other metadata.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    public func addToCollection(movies movies: [String], shows: [String], episodes: [String], completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNewResourceCreated, completion: completion)
    }
    
    /**
     Remove one or more items from a user's collection.
     
     Status Code: 200
     
     🔒 OAuth: Required
     */
    public func removeFromCollection(movies movies: [String], shows: [String], episodes: [String], completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/collection/remove", authorization: true, HTTPMethod: "POST") else { return nil }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: -
    
    /**
     Returns all movies or shows a user has watched.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter type: which type of content to receive
     
     - parameter completion: completion handler
     */
    public func getWatched(type: WatchedType, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        
        // Used to check data from another Trakt acount
//        guard let request = mutableRequestForURL("users/dobwai/watched/shows?extended=full", authorization: true, HTTPMethod: "GET") else {
//            return nil
//        }
        
        guard let request = mutableRequestForURL("sync/watched/\(type.rawValue)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - History
    
    /**
     Returns movies and episodes that a user has watched, sorted by most recent. You can optionally limit the `type` to `movies` or `episodes`. The `id` in each history item uniquely identifies the event and can be used to remove individual events by using the POST /sync/history/remove method. The action will be set to scrobble, checkin, or watch.
     
     Specify a type and trakt id to limit the history for just that item. If the id is valid, but there is no history, an empty array will be returned.
    
    🔒 OAuth: Required
     */
    public func getHistory(type: WatchedType?, traktID: NSNumber?, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "sync/history"
        if let type = type {
            path += type.rawValue
        }
        
        if let traktID = traktID {
            path += "\(traktID)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: true, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Add items to a user's watch history.
     
     Status Code: 201
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func addToHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/history", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNewResourceCreated, completion: completion)
    }
    
    /**
     Removes items from a user's watch history including watches, scrobbles, and checkins.
     
     Status Code: 200
     
     🔒 OAuth: Required
     
     - parameter movies: array of movie objects
     - parameter shows: array of show objects
     - parameter episodes: array of episode objects
     - parameter completion: completion handler
     */
    public func removeFromHistory(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/history/remove", authorization: true, HTTPMethod: "POST") else {
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
     Get a user's ratings filtered by type. You can optionally filter for a specific rating between 1 and 10.
    
    🔒 OAuth: Required
    
    - parameter type: Possible values:  `movies`, `shows`, `seasons`, `episodes`.
    - parameter rating: Filter for a specific rating
    */
    public func getRatings(type: WatchedType, rating: NSInteger?, completion: arrayCompletionHandler) -> NSURLSessionDataTask? {
        var path = "sync/ratings/\(type)"
        if let rating = rating {
            path += "/\(rating)"
        }
        
        guard let request = mutableRequestForURL(path, authorization: true, HTTPMethod: "GET") else { return nil }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Rate one or more items. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be rated. If seasons are specified, all of those seasons will be rated.
     
     Send a `rated_at` UTC datetime to mark items as rated in the past. This is useful for syncing ratings from a media center.
     
     🔒 OAuth: Required
    */
    public func addRatings(rating rating: NSNumber, movies: [String], shows: [String], episodes: [String], completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        fatalError("\(__FUNCTION__) not implemented")
        guard let request = mutableRequestForURL("sync/ratings", authorization: true, HTTPMethod: "POST") else { return nil }
//        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes) // TODO: Body only needs to include the rating and ID's
        
        return performRequest(request: request, expectingStatusCode: statusCodes.successNewResourceCreated, completion: completion)
    }
    
    /**
     Remove ratings for one or more items.
     
     🔒 OAuth: Required
    */
    public func removeRatings() {
        fatalError("\(__FUNCTION__) not implemented")
    }
    
    // MARK: - Watchlist
    
    /**
     Returns all items in a user's watchlist filtered by type. When an item is watched, it will be automatically removed from the watchlist. To track what the user is actively watching, use the progress APIs.
    */
    public func getWatchlist(watchType: WatchedType, completion: dictionaryCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist/\(watchType)", authorization: true, HTTPMethod: "GET") else {
            return nil
        }
        
        return performRequest(request: request, expectingStatusCode: statusCodes.success, completion: completion)
    }
    
    /**
     Add one of more items to a user's watchlist. Accepts shows, seasons, episodes and movies. If only a show is passed, only the show itself will be added. If seasons are specified, all of those seasons will be added.
     
     Status Code: 201
     
     🔒 OAuth: Required
    */
    public func addToWatchlist(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        
        // Request
        guard let request = mutableRequestForURL("sync/watchlist", authorization: true, HTTPMethod: "POST") else {
            completion(success: false)
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
    
    /**
     Remove one or more items from a user's watchlist.
     
     Status Code: 201
     
     🔒 OAuth: Required
     */
    public func removeFromWatchlist(movies movies: [String], shows: [String], episodes: [String], completion: successCompletionHandler) -> NSURLSessionDataTask? {
        guard let request = mutableRequestForURL("sync/watchlist/remove", authorization: true, HTTPMethod: "POST") else {
            completion(success: false)
            return nil
        }
        request.HTTPBody = createJsonData(movies: movies, shows: shows, episodes: episodes)
        
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard error == nil else {
                #if DEBUG
                    print("[\(__FUNCTION__)] \(error!)")
                #endif
                completion(success: false)
                return
            }
            
            // Check response
            // A successful post request sends a 201 status code
            guard let HTTPResponse = response as? NSHTTPURLResponse
                where HTTPResponse.statusCode == statusCodes.successNewResourceCreated else {
                    #if DEBUG
                        print(response)
                    #endif
                    completion(success: false)
                    return
            }
            
            // Check data
            guard let data = data else {
                completion(success: false)
                return
            }
            
            do {
                if let _ = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? [String: AnyObject] {
                    completion(success: true)
                }
            }
            catch let jsonSerializationError as NSError {
                #if DEBUG
                    print(jsonSerializationError)
                #endif
                completion(success: false)
            }
        }
        
        dataTask.resume()
        return dataTask
    }
}