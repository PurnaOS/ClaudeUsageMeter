import Foundation

/// Reads the Claude Code OAuth token and fetches subscription usage (FR-0001).
public struct UsageClient: Sendable {
    static let endpoint = URL(string: "https://api.anthropic.com/api/oauth/usage")!
    static let betaHeader = "oauth-2025-04-20"
    static let keychainService = "Claude Code-credentials"

    let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }

    /// Location of Claude Code's credentials file, honoring CLAUDE_CONFIG_DIR.
    public static func credentialsURL(
        env: [String: String] = ProcessInfo.processInfo.environment
    ) -> URL {
        let base = env["CLAUDE_CONFIG_DIR"].map { URL(fileURLWithPath: $0) }
            ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude")
        return base.appendingPathComponent(".credentials.json")
    }

    /// Pull `claudeAiOauth.accessToken` out of a credentials JSON blob — the same
    /// shape whether it comes from the Keychain or the file.
    public static func token(fromCredentials data: Data) throws -> String {
        guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let oauth = obj["claudeAiOauth"] as? [String: Any],
              let token = oauth["accessToken"] as? String, !token.isEmpty
        else { throw UsageError.noOAuthToken }
        return token
    }

    /// File-based token (used as a fallback / for non-macOS).
    public static func readToken(at url: URL) throws -> String {
        guard let data = try? Data(contentsOf: url) else { throw UsageError.noOAuthToken }
        return try token(fromCredentials: data)
    }

    /// macOS Keychain — where Claude Code actually stores the credentials.
    /// ponytail: shell out to `/usr/bin/security` rather than pull in a SecItem
    /// wrapper; this is a dev-tool menu-bar app, not a sandboxed store.
    public static func readTokenFromKeychain(service: String = "Claude Code-credentials") throws -> String {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/security")
        p.arguments = ["find-generic-password", "-s", service, "-w"]
        let out = Pipe(); p.standardOutput = out; p.standardError = Pipe()
        do { try p.run() } catch { throw UsageError.noOAuthToken }
        p.waitUntilExit()
        guard p.terminationStatus == 0 else { throw UsageError.noOAuthToken }
        let data = out.fileHandleForReading.readDataToEndOfFile()
        return try token(fromCredentials: data)
    }

    /// Keychain first (the macOS default), then the credentials file.
    public static func readToken() throws -> String {
        if let t = try? readTokenFromKeychain() { return t }
        return try readToken(at: credentialsURL())
    }

    public func request(token: String) -> URLRequest {
        var req = URLRequest(url: Self.endpoint)
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue(Self.betaHeader, forHTTPHeaderField: "anthropic-beta")
        return req
    }

    /// Raw transport — status code + body. The probe uses this to inspect the
    /// real response shape; `fetch()` parses it.
    public func fetchRaw() async throws -> (status: Int, body: Data) {
        let token = try Self.readToken()
        let (data, resp) = try await session.data(for: request(token: token))
        return ((resp as? HTTPURLResponse)?.statusCode ?? 0, data)
    }

    /// Fetch the current snapshot. Caller (the app) layers the 429-aware disk
    /// cache on top (NFR-0002) so this stays a thin, testable transport.
    public func fetch() async throws -> UsageSnapshot {
        let (status, data) = try await fetchRaw()
        guard status == 200 else { throw UsageError.http(status) }
        return try UsageResponse.parse(data)
    }
}
