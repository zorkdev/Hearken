import Hearken

let server = Server(isLoggingEnabled: true)

server[.GET, "/api/health"] = HTTPResponse(status: .ok)

server[.POST, "/api/hello"] = { _ in
    .init(status: .ok,
          headers: [.contentType(.json)],
          body: """
                {
                    "hello": "world"
                }
                """)
}

try server.syncStart()
