# ECBP — Complete Environment & Tooling Reference
## Everything installed, why it exists, and how it connects

This is your mental map. Read it once fully, then use it as a lookup reference whenever a tool name or term shows up and you've forgotten exactly what it does.

---

## PART 1 — THE BIG PICTURE

Your setup has three layers, and almost every confusing moment during setup (PATH errors, "command not found," permission issues) happened because a command was run in the wrong layer.

**Layer 1 — Windows itself.** Runs your IDE (IntelliJ), your browsers, Docker Desktop's control panel, and most command-line tools directly: Java, Maven, Git, Python, AWS CLI, Terraform, Node.js, Postman, SoapUI, DBeaver, Claude Code.

**Layer 2 — WSL2 (Windows Subsystem for Linux), running Ubuntu.** A real Linux environment running inside Windows, used specifically because Docker, DB2, Kafka, and Splunk all behave more reliably on Linux than native Windows. You run `docker` commands from here.

**Layer 3 — Docker containers, running inside WSL2's Linux environment.** Three long-running containers: DB2 (your database), Kafka+Zookeeper (your message broker), and Splunk (your log/monitoring platform). These stay running in the background while you work in Windows.

**Why split it this way:** Windows-native tools are faster and more integrated for development work (IntelliJ, Git, editing files). But Docker-based infrastructure (databases, message brokers) runs better on Linux. WSL2 gives you both without needing two separate physical machines.

---

## PART 2 — TERMINALS: CMD vs PowerShell vs WSL2/Ubuntu Bash

You hit friction a few times from being in the wrong one. Here's the actual difference:

| Terminal | What it is | Prompt looks like | When you used it |
|---|---|---|---|
| **CMD** | Windows' original, oldest command shell | `C:\Users\HP>` (no "PS") | Accidentally, once — caused the `Remove-Item` failure |
| **PowerShell** | Windows' modern shell, more powerful, scriptable | `PS C:\Users\HP>` | Almost everything: Java, Maven, Git, Python, AWS CLI, Terraform, npm |
| **WSL2 Ubuntu (Bash)** | A real Linux terminal, running inside WSL2 | `balubtechit@DESKTOP-...:~$` | All `docker` commands, DB2/Kafka/Splunk setup |

**Rule of thumb going forward:** if a command starts with `docker`, run it in Ubuntu. Everything else (Java, Git, Maven, AWS, Terraform, npm, Python/Poetry) runs in PowerShell.

---

## PART 3 — VERSION CONTROL: GIT & GITHUB

**Git** — a version control system that tracks every change to your code over time, running locally on your machine. Every `git commit` is a saved snapshot you can return to.

**GitHub** — a cloud service that hosts a copy of your Git repository (`payment-switch-ecbp`) so it's backed up, shareable, and visible to recruiters. Git and GitHub are separate things: Git works with no internet connection; GitHub is where you push your Git history to.

**SSH key** — the credential that lets your laptop authenticate to GitHub without typing a password every time. You generated a key pair (`id_ed25519` private key stays on your laptop, `id_ed25519.pub` public key uploaded to GitHub). GitHub trusts anything signed by your private key because it has the matching public key on file.

**How the pieces connect:**
```
Your files → git add → git commit (saved locally) → git push → GitHub (backed up, visible online)
```

**Key files:**
- `.git/` (hidden folder) — Git's internal database of every commit, created by `git init`. Never touch this directly.
- `.gitignore` — tells Git which files to never track (build output, secrets, IDE settings, `node_modules`)
- `README.md` — the front-page documentation shown when anyone opens your repo on GitHub

---

## PART 4 — CI/CD: GITHUB ACTIONS

**CI/CD** = Continuous Integration / Continuous Deployment. The practice of automatically building, testing, and (eventually) deploying code every time you push a change, instead of doing it manually.

**GitHub Actions** — GitHub's built-in CI/CD engine. It watches your repo for pushes and runs automated jobs in response, using temporary cloud virtual machines that spin up, do the work, and disappear.

**How it connects to your project:**
```
git push → GitHub detects the push → matches it against .github/workflows/*.yml
  → spins up a fresh Ubuntu VM → checks out your code → installs JDK 21
  → runs `mvn clean verify` (builds + tests) → reports pass/fail
```

You have 12 workflow files: one per service (10), one for Python tests, one reusable template they all share, plus a Terraform deployment workflow (not active yet). You personally debugged four real CI failures during setup — a missing dependency, malformed XML, a missing directory-creation step in a script, and zero tests being collected. That's genuinely representative of what CI/CD work looks like in a real job.

---

## PART 5 — JAVA ECOSYSTEM

**JDK (Java Development Kit)** — the software that lets you write, compile, and run Java code. You installed **Temurin 21 LTS** specifically (an open-source, free JDK build). "LTS" means Long Term Support — the version that gets years of security patches, which is why real companies standardize on it.

**Maven** — a build tool for Java. It reads a project's `pom.xml` file, downloads every library the project depends on (Spring Boot, JUnit, etc.) automatically, compiles the code, runs the tests, and packages everything into a runnable `.jar` file. Think of it as the Java equivalent of `npm install` + a build script combined.

**IntelliJ IDEA** — the actual code editor (IDE = Integrated Development Environment) you'll write Java in. It understands Java deeply — autocomplete, error detection, refactoring, built-in Maven/Git integration — far beyond what a plain text editor gives you.

**Spring Boot** — the application framework your 10 microservices are built on. It handles dependency injection, web server setup, database connections, and configuration so you don't write that plumbing by hand. (Full explanation of Spring given earlier in this conversation — worth re-reading before Day 3.)

**How they connect:**
```
You write code in IntelliJ → IntelliJ uses Maven to fetch dependencies →
Maven compiles your code + Spring Boot's libraries → produces a runnable service
```

**Key files:**
- `pom.xml` — one per service; lists dependencies (Spring Web, Spring Data JPA, etc.) and build configuration. This is the file that broke twice during setup (missing dependency, malformed XML) — it's the most important file in each service folder.
- `*.java` — actual source code files
- `application.yml` / `application-dev.yml` / `application-docker.yml` — Spring Boot configuration files (database connection strings, server port, environment-specific settings). Spring automatically picks the right one based on which "profile" is active.

---

## PART 6 — DATABASE: DB2 & DBEAVER

**DB2** — IBM's relational database. This is what actually stores your data — accounts, transactions, balances — as structured tables. You're running the free **Community Edition** inside a Docker container, since installing DB2 natively on Windows is far messier.

**DBeaver** — a universal database client (GUI tool) that lets you visually browse tables, run SQL queries, and inspect data — without needing DB2's own command-line tools. It connects to your DB2 container over the network (port 50000) exactly like your Spring Boot services will.

**JDBC** — Java Database Connectivity. The standard Java API that lets Java code (your Spring Boot services) talk to any database, including DB2. Your `pom.xml` includes a DB2 JDBC driver dependency for this reason.

**JPA / Spring Data JPA** — a layer on top of JDBC that lets you work with database rows as Java objects instead of writing raw SQL by hand for every operation. You'll define a Java class like `Account`, and Spring Data JPA handles turning that into SQL `INSERT`/`SELECT`/`UPDATE` statements against DB2.

**How they connect:**
```
DBeaver ─┐
          ├──► DB2 container (port 50000) ◄── your Spring Boot services (via JDBC/JPA)
You (SQL)┘
```

**Key files:**
- `db/migration/V1__create_account_table.sql` etc. — versioned SQL scripts (Flyway-style naming) that define your database schema. Running these in order builds up the database structure over time, and gives you a real, demonstrable schema history — a genuinely valuable thing for interviews.

---

## PART 7 — CONTAINERIZATION: DOCKER

Already explained in depth earlier in this conversation, but the short version for this reference: **Docker packages software (DB2, Kafka, Splunk) with everything it needs to run into a portable "container,"** so you don't have to install any of those complex systems directly onto Windows.

**Docker Desktop** — the Windows application that manages Docker containers, with a GUI and the WSL2 integration that lets `docker` commands work from both PowerShell and Ubuntu.

**Docker Compose** — a tool for defining and running *multiple* containers together as one unit, described in a YAML file. Your `infra/kafka/docker-compose-kafka.yml` brings up Kafka + Zookeeper together, since Kafka can't run without Zookeeper coordinating it.

**Key files:**
- `docker-compose-infra.yml` (root) — brings up DB2 + Kafka + Zookeeper + Splunk together, all at once, for full local development
- `infra/kafka/docker-compose-kafka.yml` — just Kafka + Zookeeper, standalone
- `Dockerfile` (one per service) — instructions for packaging *your own* Spring Boot service into a container image, used later for AWS deployment (Day 28+)

---

## PART 8 — MESSAGING: KAFKA & ZOOKEEPER

**Kafka** — a distributed event streaming platform. In plain terms: a durable message queue that services publish events to and subscribe to, instead of calling each other directly. When `payment-service` completes a transfer, instead of directly telling `notification-service` and `audit-service` about it, it publishes a `PaymentSettled` event to Kafka — and any service that cares can independently pick it up. This decouples your services from each other.

**Zookeeper** — a coordination service Kafka (in the version you're using) depends on to manage cluster metadata — which broker owns which data partition, leader election, etc. You don't interact with Zookeeper directly; Kafka needs it running to function.

**Why this matters for ECBP specifically:** your saga pattern (Day 7) and event-driven architecture between `payment-service`, `risk-service`, `notification-service`, and `audit-service` all flow through Kafka topics — it's the nervous system connecting your otherwise-independent microservices.

---

## PART 9 — PYTHON ECOSYSTEM (TEST FRAMEWORK)

**Python** — the language your entire test-framework is written in, separate from the Java services under test. You specifically use **Python 3.12** for this (not the 3.14 you initially installed), because the `ibm_db` driver needed prebuilt compatibility that 3.14 didn't reliably have yet.

**Poetry** — a Python dependency and virtual-environment manager. It reads `pyproject.toml`, resolves exact compatible versions of every library you need, locks them into `poetry.lock` (so anyone else building this gets identical versions), and creates an isolated virtual environment so your test framework's dependencies never conflict with other Python projects on your machine.

**pytest** — the testing framework itself. You write functions starting with `test_`, and pytest discovers and runs them, reporting pass/fail. This is what your CI pipeline actually executes (`poetry run pytest ecbp_tests/api_tests`).

**Playwright** — a browser automation library. It can launch a real browser (Chromium, in your validated setup), navigate pages, click buttons, and assert on what's shown — used for End-to-End (E2E) testing of any UI you eventually build.

**ibm_db** — the Python driver that lets your test scripts connect directly to DB2 and run validation queries (e.g., "did the balance actually change correctly after this API call?").

**zeep** — a Python SOAP client library, used to test your `legacy-gateway-service`'s SOAP endpoints from Python, the same way `requests` tests REST endpoints.

**requests / httpx** — Python libraries for making HTTP calls — this is how your test suite calls your REST APIs (`GET /api/accounts/{id}/balance`, etc.) to test them.

**How they connect:**
```
poetry install → creates isolated environment with pytest, Playwright, ibm_db, zeep, requests
poetry run pytest → runs your test files → each test calls a REST/SOAP endpoint or queries DB2 directly → asserts the result is correct
```

**Key files:**
- `pyproject.toml` — declares what your test framework needs (like `pom.xml`, but for Python)
- `poetry.lock` — exact locked versions of every dependency, ensuring reproducibility
- `conftest.py` — shared pytest configuration and fixtures (reusable test setup code)
- `test_*.py` files — the actual test code, one per service/concern

---

## PART 10 — API TESTING TOOLS: POSTMAN & SOAPUI

**REST** — Representational State Transfer. An architectural style for APIs using standard HTTP verbs (GET, POST, PUT, DELETE) and typically JSON data. Almost all of your services (`account-service`, `payment-service`, etc.) expose REST APIs.

**Postman** — a GUI tool for manually building and sending HTTP requests to REST APIs, inspecting responses, and organizing requests into collections. You use it to manually test endpoints as you build them, before automated tests exist.

**SOAP** — Simple Object Access Protocol. An older, more rigid API style using XML messages with a strict, formally-defined contract. Real banks often still have legacy SOAP interfaces alongside modern REST — which is exactly why `legacy-gateway-service` exists in your project, to demonstrate you can bridge both worlds.

**WSDL (Web Services Description Language)** — an XML document that formally describes a SOAP service: what operations it offers, what parameters they take, what they return. It's the SOAP equivalent of a REST API's OpenAPI/Swagger spec, but far stricter — client code can be auto-generated directly from a WSDL. You'll create this on Day 15-16.

**XSD (XML Schema Definition)** — defines the exact structure/rules for XML documents (used to define the request/response shapes referenced inside a WSDL).

**SoapUI** — the GUI tool for manually testing SOAP services, analogous to what Postman does for REST. You import a WSDL, and SoapUI can generate sample requests automatically based on the contract.

**How they connect:**
```
REST world:  Postman ──(HTTP/JSON)──► your Spring Boot REST controllers
SOAP world:  SoapUI  ──(HTTP/XML, following a WSDL contract)──► your Spring-WS SOAP endpoint
```

---

## PART 11 — CLOUD: AWS CLI, IAM & TERRAFORM

**AWS (Amazon Web Services)** — the cloud provider you'll deploy to starting Day 28. Instead of running your services only on your laptop, they'll eventually run on Amazon's infrastructure, accessible over the internet.

**AWS CLI** — a command-line tool for controlling AWS resources without clicking through the web console — create servers, storage buckets, etc. via commands, which is also what lets automation (like Terraform, or your CI/CD pipeline) interact with AWS.

**IAM (Identity and Access Management)** — AWS's permission system. You created an IAM user (`ecbp-dev`) instead of using your AWS account's all-powerful **root** login for daily work — a critical security practice: root should be used only for account-level tasks (like billing setup), never for routine development, so that if credentials ever leak, the damage is contained to what that specific user can do.

**Access Key ID / Secret Access Key** — the "username and password" equivalent for programmatic (CLI/API) access to AWS, tied to your `ecbp-dev` IAM user. This is what `aws configure` stored, letting your terminal authenticate as that user for every future AWS CLI or Terraform command.

**ARN (Amazon Resource Name)** — AWS's unique identifier format for every single resource — your user, a server, a storage bucket — e.g., `arn:aws:iam::039167285827:user/ecbp-dev`. You'll see these constantly once you start provisioning real AWS resources.

**Terraform** — an Infrastructure as Code (IaC) tool. Instead of manually clicking through the AWS Console to create servers/databases/networks (called "ClickOps," which doesn't scale and isn't reproducible), you *describe* the infrastructure you want in `.tf` files, and Terraform figures out how to create, update, or destroy real AWS resources to match that description. This is genuinely how most professional teams manage cloud infrastructure now.

**How they connect:**
```
You write infra/terraform/*.tf files describing "I want a VPC, an ECS cluster, an RDS database"
→ terraform plan (shows what it WOULD do, no changes yet)
→ terraform apply (actually creates those real AWS resources, using your AWS CLI credentials)
```

**Key files:**
- `infra/terraform/modules/*/main.tf` — reusable infrastructure building blocks (one module per resource type: VPC, ECS, RDS, etc.)
- `infra/terraform/environments/dev|staging|prod/` — environment-specific configuration that combines the modules differently per environment
- `terraform.tfvars` — actual variable values (region, environment name) fed into the `.tf` files

---

## PART 12 — OBSERVABILITY: SPLUNK

**Splunk** — a log aggregation and analysis platform. Real applications generate massive volumes of log lines (errors, transactions, warnings) across many services — Splunk ingests all of that into one searchable place, so instead of manually reading log files on 10 different servers, you search and build dashboards centrally.

**HEC (HTTP Event Collector)** — the specific mechanism by which your Spring Boot services will send their logs into Splunk over HTTP, using the token you generated. Your applications will be configured to ship logs to this endpoint.

**SPL (Search Processing Language)** — Splunk's own query language for searching and analyzing the ingested log data (conceptually similar to SQL, but built for log/event data specifically) — you'll write SPL queries on Day 31-32 to build dashboards like "failed transactions by reason code."

**How it connects:**
```
Your 10 Spring Boot services → write log lines →
  Logback (Java logging library) configured to also forward to →
  Splunk HEC endpoint (https://localhost:8088) → indexed and searchable in Splunk's web UI
```

---

## PART 13 — NODE.JS & NPM

**Node.js** — a JavaScript runtime that lets JavaScript run outside a browser (e.g., on your command line, or as a server). You needed this specifically because **Playwright's underlying browser automation engine is built on Node.js**, even though you're driving it from Python — the Python package wraps a Node.js-based driver internally.

**npm (Node Package Manager)** — Node.js's package manager, bundled with it, used to install JavaScript libraries. You confirmed it works after fixing a PowerShell execution policy restriction — a standard Windows security default that blocks running `.ps1` scripts (npm's launcher is one) until explicitly allowed.

---

## PART 14 — PRE-COMMIT

**pre-commit** — a framework that runs automated checks (linting, formatting, secret-scanning) *before* a commit is even allowed to complete, catching problems locally before they ever reach GitHub/CI. Your `.pre-commit-config.yaml` is configured to run Python linters (`ruff`, `black`), and a secret-scanner (`gitleaks`) that would catch you accidentally committing an AWS key or password.

**How it connects:**
```
git commit → pre-commit hooks run automatically → if any check fails, the commit is blocked
  → you fix the issue → commit again
```
(Note: this is installed but not yet activated with `pre-commit install` in your repo — that's a Day 1-2 task, wiring it into `.git/hooks`.)

---

## PART 15 — CLAUDE CODE

**Claude Code** — a separate AI coding assistant tool (different from this chat) that runs directly in your terminal, inside your project folder. Unlike this chat, it can read your actual files, write/edit code, run terminal commands, and manage Git — with your approval at each step. Useful once you're deep in writing actual Spring Boot code, debugging stack traces, or refactoring across many files.

---

## PART 16 — GLOSSARY OF TERMS YOU'LL KEEP HEARING

| Term | Meaning |
|---|---|
| **API** | Application Programming Interface — a defined way for two pieces of software to talk to each other |
| **REST** | An API style using HTTP verbs + typically JSON |
| **SOAP** | An older, XML-based, strictly-contracted API style |
| **WSDL** | The formal XML contract describing a SOAP service |
| **JSON** | JavaScript Object Notation — the lightweight text format REST APIs typically use |
| **XML** | Extensible Markup Language — the tag-based text format SOAP uses |
| **JDBC** | Java's standard way to connect to databases |
| **JPA / ORM** | A layer that maps database rows to Java objects, avoiding hand-written SQL for every operation |
| **CI/CD** | Continuous Integration / Continuous Deployment — automated build/test/deploy on every code change |
| **IaC** | Infrastructure as Code — defining cloud infrastructure in files instead of manual clicking |
| **IAM** | AWS's identity/permission system |
| **VPC** | Virtual Private Cloud — an isolated network you define inside AWS |
| **ARN** | AWS's unique ID format for every resource |
| **SSH** | Secure Shell — an encrypted way to authenticate and connect to remote systems (used here for GitHub auth) |
| **HEC** | HTTP Event Collector — how logs get sent into Splunk |
| **SPL** | Splunk's search/query language |
| **Saga pattern** | A way to keep data consistent across multiple microservices without a single database transaction spanning all of them |
| **Idempotency** | A property where repeating the same request produces the same result, without duplicating effects (critical for payments, avoiding double-charging on retry) |
| **Microservice** | An independently deployable service responsible for one business capability, as opposed to one giant monolithic application |
| **Container** | A lightweight, portable, isolated unit of software (via Docker) |
| **Repository (repo)** | A project's tracked codebase, in Git/GitHub terms |

---

## PART 17 — END-TO-END: WHAT HAPPENS WHEN YOU ACTUALLY RUN THE APP (Day 4+)

Once you have real code, here's the flow you'll be operating in daily:

```
1. You write Java code in IntelliJ (account-service, payment-service, etc.)
2. You run the service locally: mvn spring-boot:run
   → Spring Boot starts a web server, connects to DB2 (via JDBC/JPA)
3. You test it manually with Postman (REST) or SoapUI (SOAP)
4. You write automated tests in Python (pytest), run them: poetry run pytest
   → these hit your running service's REST/SOAP endpoints, and validate DB2 state directly
5. You commit your code: git add, git commit (pre-commit hooks run first)
6. You push: git push
7. GitHub Actions automatically builds + tests your service in the cloud
8. Later (Day 28+): Terraform provisions real AWS infrastructure,
   your service gets containerized (Dockerfile) and deployed there
9. Once live, your service's logs flow into Splunk for monitoring,
   and inter-service events flow through Kafka
```

---

## PART 18 — IMPORTANT THINGS TO KEEP IN MIND GOING FORWARD

1. **Always check your terminal type** before running a command — `docker` commands go in Ubuntu, everything else in PowerShell.
2. **New terminal window after any PATH change** — this tripped you up repeatedly; PATH updates don't apply to already-open windows.
3. **Never commit secrets** — AWS keys, DB2 passwords, Splunk HEC tokens all stay in your local `.env` file (already gitignored), never hardcoded into files you commit.
4. **Docker containers persist across reboots but don't auto-start** — after restarting your laptop, you may need to manually start DB2/Kafka/Splunk containers again (`docker start db2-ecbp kafka-kafka-1 kafka-zookeeper-1 splunk-ecbp`) unless you configure Docker Desktop to launch them automatically.
5. **Watch AWS costs once Day 28 arrives** — your $50 budget alarm and anomaly monitor are safety nets, not guarantees; run `terraform destroy` between work sessions once real resources exist, rather than leaving them running.
6. **CI failures are normal and informative, not a sign something's broken** — you already proved this to yourself four times over during setup.

---

This document plus the diagram above should give you the full mental model. Whenever a term or tool resurfaces mid-project and you've lost the thread, come back to this file rather than re-asking from scratch — it's built specifically to be your reference, not a one-time read.
