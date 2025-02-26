import Foundation
import Web3Auth

public class Web3AuthViewModel: ObservableObject {
    public var web3Auth: Web3Auth?
    @Published public var loggedIn: Bool = false
    @Published public var user: Web3AuthState?
    @Published public var isLoading = false
    // IMP START - Get your Web3Auth Client ID from Dashboard
    private var clientId = CraftEnvironmentVariables.web3AuthClientId
    // IMP END - Get your Web3Auth Client ID from Dashboard
    // IMP START - Whitelist bundle ID
    private var network: Network = .sapphire_devnet
    // IMP END - Whitelist bundle ID
    
    public init() {}
    
    public func setup() async {
        guard web3Auth == nil else { return }
        await MainActor.run(body: {
            isLoading = true
        })
        
        // IMP START - Initialize Web3Auth
        do {
            web3Auth = try await Web3Auth(W3AInitParams(
                clientId: clientId,
                network: network,
                redirectUrl: CraftEnvironmentVariables.web3AuthRedirectURL
            ))
        } catch {
            print("Something went wrong")
        }
        // IMP END - Initialize Web3Auth
        await MainActor.run(body: {
            if self.web3Auth?.state != nil {
                user = web3Auth?.state
                loggedIn = true
            }
            isLoading = false
        })
    }
    
    public func login(provider: Web3AuthProvider) {
        Task {
            do {
                // IMP START - Login
                let result = try await web3Auth?.login(
                    W3ALoginParams(loginProvider: provider)
                )
                // IMP END - LoginCiwq
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                })
                
            } catch {
                print("Error")
            }
        }
    }
    
    public func logout() throws {
        Task {
            // IMP START - Logout
            try await web3Auth?.logout()
            // IMP END - Logout
            await MainActor.run(body: {
                loggedIn = false
            })
        }
    }
    
    public func loginEmailPasswordless(provider: Web3AuthProvider, email: String) {
        Task {
            do {
                // IMP START - Login
                let result = try await web3Auth?.login(W3ALoginParams(loginProvider: provider, extraLoginOptions: ExtraLoginOptions(display: nil, prompt: nil, max_age: nil, ui_locales: nil, id_token_hint: nil, id_token: nil, login_hint: email, acr_values: nil, scope: nil, audience: nil, connection: nil, domain: nil, client_id: nil, redirect_uri: nil, leeway: nil, verifierIdField: nil, isVerifierIdCaseSensitive: nil, additionalParams: nil)))
                // IMP END - Login
                await MainActor.run(body: {
                    user = result
                    loggedIn = true
                })
                
            } catch {
                print("Error")
            }
        }
    }
}
