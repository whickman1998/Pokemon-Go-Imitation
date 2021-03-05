//
//  Resource.swift
//  PokemonAPI
//
//  Created by Christopher Jennewein on 9/11/18.
//

import Foundation


/// API Referenced Resource
open class PKMAPIResource<T>: Codable {
    private enum CodingKeys: String, CodingKey {
        case url
    }
    
    /// The URL of the referenced resource
    open var url: String?
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(String.self, forKey: .url)
    }
}


/// Named API Resource
open class PKMNamedAPIResource<T>: PKMAPIResource<T> {
    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    /// The name of the referenced resource
    open var name: String?
    
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        
        try super.init(from: decoder)
    }
}



// MARK: - Web Services

open class ResourceService {
    /**
     Fetch a resource from a named or unnamed resource url
     
     - parameter resource: PKMAPIResource or APINamedAPIResource
     */
    public static func fetch<T: Decodable>(_ resource: PKMAPIResource<T>, completion: @escaping (_ result: Result<T, HTTPError>) -> Void) {
        guard let urlStr = resource.url else {
            completion(.failure(.invalidRequest))
            return
        }
        
        HTTPWebService.callWebService(url: URL(string: urlStr), method: .get) { result in
            result.decode(completion: completion)
        }
    }
}
