struct NillionConfig {
    static let orgCredentials = OrgCredentials(
        secretKey: CraftEnvironmentVariables.nillionSecretKey,
        orgDid: CraftEnvironmentVariables.nillionOrgDid
    )
    
    static let nodes = [
        Node(
            url: "https://nildb-zy8u.nillion.network",
            did: "did:nil:testnet:nillion1fnhettvcrsfu8zkd5zms4d820l0ct226c3zy8u"
        ),
        Node(
            url: "https://nildb-rl5g.nillion.network",
            did: "did:nil:testnet:nillion14x47xx85de0rg9dqunsdxg8jh82nvkax3jrl5g"
        ),
        Node(
            url: "https://nildb-lpjp.nillion.network",
            did: "did:nil:testnet:nillion167pglv9k7m4gj05rwj520a46tulkff332vlpjp"
        )
    ]
    
    struct OrgCredentials {
        let secretKey: String
        let orgDid: String
    }
    
    struct Node {
        let url: String
        let did: String
    }
} 
