# SRBMinner
This is the full production-ready scaffold for SRBMinner, including miner core, AI analytics, and web dashboard.

## Features
- C++ miner core (CPU/GPU support)
- Python AI/analytics integration
- FastAPI web dashboard
- Dockerized environment
- CI/CD via GitHub Actions

## Setup
1. Clone the repo
2. Run `scripts/setup.sh`
3. Build miner: `cmake -S miner -B miner/build && cmake --build miner/build`
4. Start dashboard: `cd web && pip install -r requirements.txt && uvicorn app.main:app --reload`
