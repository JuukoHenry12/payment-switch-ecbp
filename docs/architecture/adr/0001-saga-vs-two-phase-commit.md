# ADR-0001: Saga Pattern over Two-Phase Commit

## Status
Proposed

## Context
payment-service must keep account-service and risk-service consistent
during a transfer without a distributed transaction coordinator across
service boundaries.

## Decision
(Fill in during Phase 3: why orchestration-based saga was chosen over 2PC/XA,
what the compensating transaction looks like.)

## Consequences
(Fill in: eventual consistency window, complexity of compensation logic, etc.)
