# ADR-0003: Monorepo Structure

## Status
Accepted

## Context
10 services, 1 shared library, infra, and a Python test framework.

## Decision
Single repository (`payment-switch-ecbp`) rather than one repo per service.

## Consequences
Simpler cross-service refactors and atomic PRs; requires clear folder
boundaries and per-service CI workflows to avoid slow, coupled builds.
