# Hearken

![Swift](https://img.shields.io/badge/Swift-5.4-orange.svg)
![SwiftPM](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)
![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20macOS%20%7C%20Linux-blue.svg)
![Build](https://github.com/zorkdev/Hearken/workflows/Build/badge.svg)

A simple Swift HTTP/1.1 server built on top of [SwiftNIO](https://github.com/apple/swift-nio).

The main goal of this package is to easily create mock servers for your Swift projects, for example when writing UI tests. The API has been kept very minimal as a consequence as Hearken is not intended to be a full-fledged web framework. It comes with a number of convenience APIs to make integration with `XCTest` even more of a breeze.

## 📦 Installation

Hearken is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a project, add it as a dependency within your `Package.swift` manifest:

``` swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/zorkdev/Hearken.git", from: "0.1.4")
    ],
    ...
)
```

## 🚀 Quickstart

An instance of Hearken can be easily created by initializing a `Server`:

``` swift
import Hearken

let server = Server()
```

Simple routes with a response instance can be added by using a custom subscript on `Server`:

``` swift
server[.GET, "/api/health"] = HTTPResponse(status: .ok)
```

You can also assign closures to routes by using another custom subscript on `Server` if you need more control over your route:

``` swift
server[.POST, "/api/hello"] = { request in
    print(request)
    
    return .init(status: .ok,
                 headers: [.contentType(.json)],
                 body: """
                       {
                           "hello": "world"
                       }
                       """)
}
```

The `Server` can be started asynchronously by calling `start()` and stopped by calling `stop()`:

``` swift
try server.start()
try server.stop()
```

The `Server` can also be started synchronously using `syncStart()` if you want to block the current thread:

``` swift
try server.syncStart()
```

## ℹ️  Example Usage

Hearken comes with an example executable product to instantiate a `Server` if you want to quickly check out how it works. Just run `HearkenExample` after you've added Hearken as dependency or checked it out separately:

``` bash
swift run HearkenExample
```

## ✅ `XCTest` additions

Hearken has some added convenience APIs for `XCTest` in a separate `HearkenTestKit` library to make it easier to test network requests. If you intend to use this, don't forget to set the domains the tested application calls to `localhost:8888`.

Create your own subclass of `HearkenTestCase` in your tests:

``` swift
import HearkenTestKit

class MyTestCase: HearkenTestCase {
    ...
}
```

Use the `assert` method to check that the tested application makes the correct request:

``` swift
func testSomething() {
    assert(request: .init(method: .POST,
                          uri: "/api/test",
                          body: "Body",
           response: .init(status: .ok))
    ...
}
```

## 📖 Documentation

Documentation is available [here](https://zorkdev.github.io/Hearken/).

## 🛠 Contributions

Use `develop` branch for development and `master` for release.

To run static analysis and tests on the project, use the `test.sh` script:

``` bash
$ ./test.sh
```
