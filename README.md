# Bangloan DeFI (bangloan-defi)

---
![contracts](https://github.com/bangloan/bangloan-defi/actions/workflows/ci-dev-contracts.yml/badge.svg)

---
## Project Structure

* [`packages/`](./packages) Individual sub-projects
    * [`api/`](./packages/api) Our backend API Server (NestJS)
    * [`app/`](./packages/app) Our frontend app (NextJS)
    * [`contracts/`](./packages/contracts) Smart Contracts and Tests
    * [`ops/`](./packages/ops) Scripts for operational tasks

* [`spikes/`](./spikes) Any POC or research we do

---
## Setup project locally

- If you only want to work on the contracts, you don't need to setup the whole project.
Please go directly to [`contracts/`](./packages/contracts/README.md) and follow the instructions there.

## Install Pre-requisite Tools
- NodeJS LTS (v20) ([install node.js](https://nodejs.org/en/learn/getting-started/how-to-install-nodejs))
- Yarn ([install yarn](https://v3.yarnpkg.com/getting-started/install))
- Foundry ([install forge](https://book.getfoundry.sh/getting-started/installation))
- Docker ([install docker](https://docs.docker.com/get-docker/))
- Supabase CLI ([install the cli](https://github.com/supabase/cli#install-the-cli))
  - Hint: choose a native client for your platform instead of the npm package


## Install dependencies
```bash
yarn install
```
## Onetime Setup
1. Setup environment variables in each package
    ```bash
    cp -n .env.sample .env
    cd packages/api && cp -n .env.sample .env && cd -
    cd packages/app && cp -n .env.local.sample .env.local && cd -
    cd packages/contracts && cp -n .env.sample .env && cd -
    cd packages/ops && cp -n .env.sample .env && cd -
    cd packages/sdk && cp -n .env.sample .env && cd -
    ```
1. Start the database (Supabase)
    ```bash
    cd packages/api && supabase start && cd -
    ```
1. Setup sdk, see [sdk/README.md](packages/sdk/README.md)
1. Setup op scripts, see [operations/README.md](packages/ops/README.md).


## Rum and Test Locally
After completing the above setup, simply run:
```bash
# test all packages
yarn test
```

```bash
# run all packages
yarn dev
```

### Open the Application
open http://localhost:3000

---
## Slack Integration
For subscribing to notifications of interest from the GitHub repository.
This is covered in detail [here](https://github.com/integrations/slack).

