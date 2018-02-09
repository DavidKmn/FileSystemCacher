//
//  Cacher.swift
//  FileSystemCacher
//
//  Created by David on 08/02/2018.
//  Copyright © 2018 David. All rights reserved.
//

import Foundation

public protocol Cachable {
    var filename: String { get }
    func transform() -> Data
}

extension Cachable where Self: Codable {
    public func transform() -> Data {
        do {
            let encoded = try JSONEncoder().encode(self)
            return encoded
        } catch {
            fatalError("Unable to encode object: \(error)")
        }
    }
}

final public class Cacher {
    let destination: URL
    private let queue = OperationQueue()
    
    public enum CacheDestination {
        case temporary
        case atFolder(String)
    }
    
    public init(destination: CacheDestination) {
        switch destination {
        case .temporary:
            self.destination = URL(fileURLWithPath: NSTemporaryDirectory())
        case .atFolder(let folder):
            let documentFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            self.destination = URL(fileURLWithPath: documentFolder).appendingPathComponent(folder, isDirectory: true)
        }
        
        let fileManager = FileManager.default
        
        do {
            try fileManager.createDirectory(at: self.destination, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Unable to create URL: \(error)")
        }
    }
    
    public func persist(item: Cachable, competion: @escaping (_ url: URL?, _ error: Error?) -> Void) {
        
        var url: URL?
        var error: Error?
        
        let operation = BlockOperation {
            do {
                url = try self.persist(data: item.transform(), at: self.destination.appendingPathComponent(item.filename, isDirectory: false))
            } catch let persistError {
                error = persistError
            }
        }
        
        operation.completionBlock = {
            competion(url, error)
        }
        
        queue.addOperation(operation)
        
    }
    
    private func persist(data: Data, at url: URL) throws -> URL {
        do {
            try data.write(to: url, options: [.atomicWrite])
            return url
        } catch {
            throw error
        }
    }
    
    
    public func load<T: Cachable & Codable>(filename: String) -> T? {
        guard let data = try? Data(contentsOf: destination.appendingPathComponent(filename)),
            let decoded = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        
        return decoded
    }
    
    
}
