# UPI Mesh — Offline Payment System

Send money with zero internet. A payment packet encrypts on your phone, hops through stranger devices via Bluetooth mesh, and settles the moment any device gets connectivity.

This repo is the backend server + a software simulator of the mesh — full demo runs on a single laptop.

---

## Tech Stack
Java 17 · Spring Boot 3.3 · RSA-OAEP + AES-256-GCM · SHA-256 · Gossip Protocol · ConcurrentHashMap · @Transactional + @Version · H2

---

## Run It

**Windows:** `mvnw.cmd spring-boot:run`  
**Mac/Linux:** `./mvnw spring-boot:run`  
**Then open:** `http://localhost:8080`

First run downloads ~80MB. JDK 17+ is the only requirement.

---

## Three Problems This Solves

| Problem | Solution |
|---|---|
| Strangers carry your payment — stop them reading it | RSA-OAEP + AES-256-GCM hybrid encryption |
| Same packet arrives from 3 phones simultaneously | Atomic `putIfAbsent` on SHA-256 hash — settles exactly once |
| Attacker replays a captured packet | Signed timestamp + nonce inside encryption |

---

## Architecture

```
Sender Phone → [encrypt] → MeshPacket
    → gossip hop → hop → bridge phone
        → gets 4G → POST /api/bridge/ingest
            → hash → deduplicate → decrypt → validate → settle
```

---

## Key Files

| File | What it does |
|---|---|
| `HybridCryptoService.java` | RSA-OAEP + AES-256-GCM encrypt/decrypt |
| `IdempotencyService.java` | Atomic deduplication via ConcurrentHashMap |
| `BridgeIngestionService.java` | Main pipeline |
| `SettlementService.java` | @Transactional debit + credit |
| `MeshSimulatorService.java` | Gossip protocol simulation |

---

## Headline Test

```cmd
mvnw.cmd test -Dtest=IdempotencyConcurrencyTest
```

3 threads deliver the same packet simultaneously.  
Result: 1 `SETTLED` · 2 `DUPLICATE_DROPPED` · balance changes once.

---
 