# API reference

This is asking to become an OpenAPI spec., and it will in the (hopefully near) future.

## User

### Register

[WIP] Creates a new user account. 

**Pre-conditions**:

- The hash is recommended to be encrypted by the client with the user's passphrase and send down as the hash. In that way the passphrase is never sent to the server.

**Post-conditions**:

- User is created. The hash is encrypted with a one-way hash function, meaning that it's almost impossible to revert. See more at [Okta - One-Way Hash Function: Dynamic Algorithms](https://www.okta.com/identity-101/one-way-hash-function-dynamic-algorithms/).
This is done to support a client that does not have the capability of encryption and sends down a plain passphrase, in which case it's not stored in the open on the server;
- Default account is created for the user;
- Default wallet is created for the default account.

**Method**: POST

**Path**: users

**Body**:

```json
{
    "username": "string", // required, min length 1, max length 16 (?)
    "hash": "string" // required
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

- 422 - Hash not provided

```json
{
    "errors": [
        {
            "code": "users.post.hash.notProvided",
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
