# VietGara Proto

Source-of-truth repository for the **internal service-to-service contracts**
of the VietGara platform, defined with Protocol Buffers and served over gRPC
(ADR-006). REST/JSON remains the external protocol at the API Gateway (see
API Specification) — this repo only covers internal communication.

## Roles / Purposes

- **Define the API contracts** of VietGara business modules as `.proto`
  files, versioned per module (`vietgara.<module>.v1`).
- **Generate Go code** (`gen/go`) consumed by `vietgara-backend` (and, in the
  future, any other Go service of the platform). Generated code is committed
  so consumers need no protobuf toolchain.
- **Enforce quality** on the contracts: `buf lint` (naming/package rules),
  `buf format`, and `buf breaking` to prevent incompatible changes between
  releases.

## Modules

| Proto package | Module | Services |
| --- | --- | --- |
| `vietgara.identity.v1` | Identity & Access Management (HLD #1) | `AuthService` — Register, Login, RefreshToken, Logout, ForgotPassword, ResetPassword, LinkSocialAccount |
| `vietgara.tenant.v1` | Tenant/Garage Management (HLD #2) | `GarageService` — CreateGarage, GetGarage, UpdateGarage, ListGarages |
| | | `StaffService` — AddStaff, UpdateStaff, RemoveStaff, ListStaff |

Each module maps to a functional group in the FRD and owns its data per
Database Design (Database-per-service, ADR-008).

## Repository Layout

```
vietgara-proto/
├── proto/vietgara/          # .proto sources (the contract)
│   ├── identity/v1/         # account.proto, auth.proto
│   └── tenant/v1/           # garage.proto, staff.proto
├── gen/go/                  # generated Go code (committed)
├── buf.yaml                 # workspace + lint/breaking config
├── buf.gen.yaml             # Go codegen config
├── go.mod                   # module github.com/viettechno/vietgara-proto
├── Makefile
└── make/                    # tools.mk (installers), proto.mk (tasks)
```

## Prerequisites

- Go 1.26+ (installs the pinned codegen tools)
- `$GOBIN` (or `$GOPATH/bin`) on your `PATH` so `buf` can find the plugins

## Common Commands

```sh
make install-tools        # install pinned tools: buf, protoc-gen-go,
                          # protoc-gen-go-grpc, grpcui
make generate             # regenerate Go code into gen/go
make lint                 # buf lint on all proto files
make format               # format proto files in place
make format-check         # fail if any proto file is not formatted
make breaking             # detect breaking changes vs origin main
make verify               # lint + format-check + generate + go build ./...
make clean                # remove gen/go
make help                 # list all targets
```

Tool versions are pinned in `make/tools.mk` (buf `1.72.0`,
protoc-gen-go `v1.36.11`, protoc-gen-go-grpc `v1.6.2`, grpcui `v1.5.3`).

## Contributing a Change

1. Edit the `.proto` sources under `proto/vietgara/...`.
2. `make format` then `make lint`.
3. `make generate` and commit the regenerated `gen/go` files together with
   the `.proto` change (they must never drift).
4. Before release, run `make breaking` (needs at least one commit on
   `main`).

## Consuming from a Go Service

Add the module as a dependency, e.g. in `vietgara-backend`:

```sh
go get github.com/viettechno/vietgara-proto@main
```

```go
import (
    identityv1 "github.com/viettechno/vietgara-proto/gen/go/vietgara/identity/v1"
    tenantv1 "github.com/viettechno/vietgara-proto/gen/go/vietgara/tenant/v1"
)
```

## Testing with grpcui

[grpcui](https://github.com/fullstorydev/grpcui) is an interactive web UI
for calling gRPC services. It discovers the exposed services through the
server reflection API, so **the target server must have gRPC reflection
registered** (`google.golang.org/grpc/reflection`). If it is not, grpcui
exits with:

```sh
Failed to compute set of methods to expose: server does not support the reflection API
```

That error means the server is reachable but reflection is missing — enable
it in the server that owns the gRPC listener. For `vietgara-backend`
(`vietgara-backend/cmd/server/main.go`), register it right after
`grpc.NewServer(...)`:

```go
import "google.golang.org/grpc/reflection"

reflection.Register(grpcServer)
```

You can verify reflection works before opening grpcui with `grpcurl`:

```sh
grpcurl -plaintext localhost:50051 list
```

Install (pinned):

```sh
make install-grpcui
```

### Examples

Connect to a local server running without TLS, using the default web port
(8080) — the browser opens automatically:

```sh
grpcui -plaintext localhost:50051
```

Choose a different port for the web UI and disable auto-open:

```sh
grpcui -plaintext -port 9000 -open-browser=false localhost:50051
```

Send tenant-scoped calls with the same headers the API Gateway sets
(Bearer token + `x-garage-id`):

```sh
grpcui -plaintext \
  -H 'authorization: Bearer <access-token>' \
  -H 'x-garage-id: <garage-id>' \
  localhost:50051
```

Connect to a TLS-secured server (prod/staging, certificate issued for the
server name in the address):

```sh
grpcui myhost:443
```

With a self-signed certificate:

```sh
grpcui -cacert ca.crt -servername myhost myhost:443
```

> Tip: `-H` headers are injected into every request made from the UI.
> You can also add per-request metadata directly in the UI form.
