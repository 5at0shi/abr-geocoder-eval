# abr-geocoder evaluation workspace

This repository contains a small evaluation workspace for testing Digital Agency `abr-geocoder` against mixed Japanese address patterns, especially:

- residential addressing
- parcel-based addressing
- addresses with building names and floor information

## What is included

- evaluation plan: [PLAN.md](./PLAN.md)
- execution record: [EXECUTION_RESULT.md](./EXECUTION_RESULT.md)
- assessment notes: [docs/abr-geocoder-assessment.md](./docs/abr-geocoder-assessment.md)
- setup guide: [docs/abr-geocoder-setup-guide.md](./docs/abr-geocoder-setup-guide.md)
- sample inputs: [samples](./samples)
- helper scripts: [scripts](./scripts)

## What is not committed

Large downloaded data under `results/*/data/` is intentionally ignored.

## Main result

Current conclusion: `abr-geocoder` is conditionally suitable.

- strong for residential-style normalization
- usable for some parcel-style inputs
- needs downstream review for `machiaza` / `machiaza_detail` results
- downloaded evaluation datasets consume several hundred MB even for one municipality
