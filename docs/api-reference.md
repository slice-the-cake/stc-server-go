# API reference

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
