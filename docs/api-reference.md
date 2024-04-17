# API reference

This is asking to become an OpenAPI spec., and it will in the (hopefully near) future.

## User

### Register

[WIP] Creates a new user account.

**Method**: POST

**Path**: users

**Body**:

```json
{
    "username": "string", // required, min length 1, max length 16 (?)
    "usernameHash": "string"
}
```

**Responses**:

- 201 - Created

```json
{
    "id": "uuid"
}
```

- 422 - Username is too long

- 409 - Unavailable username

```json
{
    "errors": [
        {
            "code": "UNAVAILABLE_USERNAME",
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
