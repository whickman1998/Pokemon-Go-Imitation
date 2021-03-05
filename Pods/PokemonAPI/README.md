# PokemonAPI

[![Build Status](https://travis-ci.org/kinkofer/PokemonAPI.svg?branch=master)](https://travis-ci.org/kinkofer/PokemonAPI)
[![Version](https://img.shields.io/cocoapods/v/PokemonAPI.svg?style=flat)](http://cocoapods.org/pods/PokemonAPI)
[![License](https://img.shields.io/cocoapods/l/PokemonAPI.svg?style=flat)](http://cocoapods.org/pods/PokemonAPI)
[![Platform](https://img.shields.io/cocoapods/p/PokemonAPI.svg?style=flat)](http://cocoapods.org/pods/PokemonAPI)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## What is this?

PokemonAPI is a swift wrapper for PokéAPI (pokeapi.co). Easily call web services to get info about Pokemon and the Pokemon games.

The framework supports paginated responses, allowing you to quickly get the next results or a specific page. 
Linked resources can quickly be turned into their associated classes via a generic `fetch(_ resource:)` function.

All code is Swift native with no third party frameworks.



## Usage

Use the `PokemonAPI` class to access web service classes organized by categories found on pokeapi.co (Berries, Pokemon, Games, etc.).

### Response
All web service functions use a competion handler that return a `Result` enum value of either case `.success(T)` or `.failure(HTTPError)` where `T` is an instance of the class returned by the response, decoded from JSON.


### Resources

Some properties on the returned object are type `PKMNamedAPIResource<T>` or `PKMAPIResource<T>` where `T` is another class with additional information. Passing that property to `PokemonAPI.resourceService.fetch(_ resource:)` will return that object in the function's completion handler. An example is provided below.

### Lists

Fetching lists will return a `PagedObject<T>` containing a page of results, plus the total count, number of pages, and if next and/or previous pages are available. The `results` will be an array of `PKMNamedAPIResource<T>` or `PKMAPIResource<T>`, so it's typical to fetch the resources immediately, if needed.

Web service functions for lists take a `PaginationState` enum parameter. There are two cases for this enum, `.initial(pageLimit: Int)` for the first call, and `.continuing(PKMPagedObject<T>, PaginationRelationship)` for subsequent calls. Each function sets a default value of `.initial(pageLimit: 20)`, but you can pass your own page limit. After the first call, you use `.continuing()` with the PagedObject from the last response, and a `PaginationRelationship` for navigation (`.next`, `.previous`, `.first`, `.last`, or a specific `.page(Int)`).


## Examples

```swift
import PokemonAPI

// Example of calling a web service using an ID
PokemonAPI.berryService.fetchBerry(1) { result in
    switch result {
    case .success(let berry):
        self.berryLabel.text = berry.name // cheri
    case .failure(let error):
        print(error)
    }
}
```


```swift
// Example of calling a web service using a name
PokemonAPI.pokemonService.fetchPokemon("bulbasaur") { result in
    switch result {
    case .success(let pokemon):
        self.pokemonLabel.text = pokemon.name // bulbasaur
    case .failure(let error):
        print(error)
    }
}
```


```swift
// Example of fetching a PKMNamedAPIResource (or PKMAPIResource)
PokemonAPI.gameService.fetchPokedex(14) { result in
    switch result {
    case .success(let pokedex):
        print(pokedex.name!) // kalos-mountain
        
        PokemonAPI.resourceService.fetch(pokedex.region!) { result in
            switch result {
            case .success(let region):
                print(region.name!) // kalos
            case .failure(let error):
                print(error.message)
            }
        }
        
    case .failure(let error):
        print(error.message)
    }
}
```

```
// Example of calling a paginated web service with a pageLimit, then using the pagedObject to fetch the next page in the list
PokemonAPI.utilityService.fetchLanguageList(paginationState: .initial(pageLimit: 5)) { result in
    switch result {
    case .success(let pagedLanguages):
        print("\(pagedLanguages.count!)") // 12

        PokemonAPI.utilityService.fetchLanguageList(paginationState: .continuing(pagedLanguages, .next)) { result in
            switch result {
            case .success(let pagedLanguagesNext):
                print("Page: \(pagedLanguagesNext.currentPage)") // Page: 1
            case .failure(let error):
                print(error.message)
            }
        }
    case .failure(let error):
        print(error.message)
    }
}
```


## TODO

- [ ] Fully [Documented](http://kinkofer.github.io/PokemonAPI/)
- [ ] Fully tested

## Installation

PokemonAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PokemonAPI'
```

If you're using Carthage you can add PokemonAPI by adding it to your Cartfile:

```ruby
github "kinkofer/PokemonAPI" ~> 4.0
```

In your Info.plist, add
```plist
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSExceptionDomains</key>
	<dict>
		<key>pokeapi.co</key>
		<dict>
			<key>NSIncludesSubdomains</key>
			<true/>
			<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
			<true/>
			<key>NSTemporaryExceptionMinimumTLSVersion</key>
			<string>TLSv1.2</string>
		</dict>
	</dict>
</dict>
```

## Author

Christopher Jennewein, kinkofer@gmail.com

Forked from PokemonKit, Yeung Yiu Hung, http://github.com/ContinuousLearning/PokemonKit

## License

PokemonAPI is available under the MIT license. See the LICENSE file for more info.

