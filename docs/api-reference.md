# API reference

This is asking to become an OpenAPI spec. [1]

## User

### Register

Creates a new user account. 

**Pre-conditions**:

- It is *recommended* (but not mandatory) that the username be encrypted by the client with the user's passphrase and sent down as the hash. In that way the passphrase is never
sent to the server. However, we want to support clients that are not capable of doing this, e.g., web clients with JS disabled.

**Post-conditions**:

- User is created. The username is encrypted using the passphrase as key. The encryption can occur at either client- or server-side depending on the client's capabilities.
A one-way hash function should be used, meaning that it's almost impossible to revert. See more at [Okta - One-Way Hash Function: Dynamic Algorithms](https://www.okta.com/identity-101/one-way-hash-function-dynamic-algorithms/).
Both client and server should use the same function so the user can switch clients without problems.
- Default account is created for the user;
- Default wallet is created for the default account.

**Method**: POST

**Path**: users

**Body**:

```json
{
    "username": "string", // required, min length 1, max length 16 (?)
    "secret": {
        "hash": "string", // null if `passphrase` not null, not null if `passphrase` null
        "passphrase": "string" // null if `hash` not null, not null if `hash` null
    }
}
```

**Responses**:

- 201 - Created

```json
{
    "id": "uuid",
    "links": {} // TBD
}
```

- 422 - Username not provided

```json
{
    "errors": [
        {
            "code": "users.post.username.notProvided",
            "dataMap": {}
        }
    ]
}
```

- 422 - Secret not provided

```json
{
    "errors": [
        {
            "code": "users.post.secret.notProvided",
            "dataMap": {}
        }
    ]
}
```

- 422 - Ambiguous secret (both `hash` and `passphrase` were provided)

```json
{
    "errors": [
        {
            "code": "users.post.secret.ambiguous",
            "dataMap": {}
        }
    ]
}
```

- 422 - Username is too short

```json
{
    "errors": [
        {
            "code": "users.post.username.tooShort",
            "dataMap": {
                "username": "$REQUESTED_USERNAME",
                "min": $MIN_LENGTH
            }
        }
    ]
}
```

- 422 - Username is too long

```json
{
    "errors": [
        {
            "code": "users.post.username.tooLong",
            "dataMap": {
                "username": "$REQUESTED_USERNAME",
                "max": $MAX_LENGTH
            }
        }
    ]
}
```

- 409 - Unavailable username

```json
{
    "errors": [
        {
            "code": "users.post.username.unavailable",
            "dataMap": {
                "username": "$REQUESTED_USERNAME"
            }
        }
    ]
}
```

## Account

### Register account

## Ledger

### Register entry (WIP)

Creates a new entry on the user's ledger. The entry may be either a `CREDIT` or a `DEBIT`.

**Headers**:

| Key | Value |
| --- | --- |
| Authorization | Bearer $TOKEN |

**Method**: POST

**Path**: ledger

**Body**:

```json
{
    "type": ["CREDIT", "DEBIT"],
    "value": "number"
}
```

## Notes

[1] [Or not...](https://blog.ploeh.dk/2024/05/13/gratification/#f7f676bf5a334b189b3c2baab18b1e6a)

