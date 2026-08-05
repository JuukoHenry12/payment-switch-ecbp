# ECBP — Enterprise Core Banking & Payments Platform

Microservices-based core banking simulator covering account management, payments,
cards, loans, fraud/risk scoring, EOD batch settlement, and regulatory audit —
built to exercise the full breadth of Java, Spring, REST, SOAP, DB2, Python,
Kafka, AWS, and Splunk.

## Quick start
```bash
docker compose -f docker-compose-infra.yml up -d
cd services/account-service && mvn spring-boot:run
```

## Services
| Service | Purpose |
|---|---|
| account-service | Account lifecycle, balances |
| payment-service | Transfers, idempotency, saga orchestration |
| card-service | Card issuance, authorization |
| loan-service | Loan origination, amortization |
| risk-service | Fraud/risk rule engine |
| batch-service | EOD settlement, interest accrual |
| notification-service | Async notifications |
| audit-service | Immutable audit log |
| legacy-gateway-service | SOAP facade |
| api-gateway | Single entry point, auth, routing |

## Architecture
See `docs/architecture/architecture-overview.md` and `docs/architecture/adr/`.

## Author
Balasubramani P
