# API reference

This is asking to become an OpenAPI spec. [1]

## User

### Register

Creates a new user account. 

**Post-conditions**:

- User is created. The passphrase is hashed with a [salt](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#salting) using [Argon2id](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html) and the hash is [peppered](https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#peppering)
before being stored.
- Default account is created for the user;
- Default wallet is created for the default account.

**Method**: POST

**Path**: users

**Body**:

```json
{
    "username": "string", // required, min length 1, max length 16 (?)
    "passphrase": "string" // required, min length 16
}
```

**Responses**:

- 201 - Created

```json
{
    "id": "uuid",
    "links": {} // TBD [WIP]
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

- 422 - Passphrase not provided

```json
{
    "errors": [
        {
            "code": "users.post.passphrase.notProvided",
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

- 422 - Passphrase is too short

```json
{
    "errors": [
        {
            "code": "users.post.passphrase.tooShort",
            "dataMap": {
                "min": $MIN_LENGTH
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

