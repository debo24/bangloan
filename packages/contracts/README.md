## Bangloan Smart Contracts

All our smart contract reside in this project. 

If you exclusively want to work on the contracts, you don't need to setup the whole project. Follow only the instructions below to setup the contracts locally.

## Setup project locally

- Ensure that you have:
    - Foundry ([install forge](https://book.getfoundry.sh/getting-started/installation))

- Check your foundry installation
```shell
$ forge --help
$ anvil --help
```

## Setup using Docker

- Clone the repository with submodules `git clone --recurse-submodules
- Build the image with `docker build -f Dockerfile -t bangloan-contracts .`
- SSH into the container with `docker run --entrypoint "/bin/sh" -it bangloan-contracts`
- You can then run `forge` and `anvil` commands as usual

## Foundry Documentation

https://book.getfoundry.sh/

## Usage

### Build

```bash
forge build
```

### Test

```bash
forge test
```

## Advanced Testing

### Code Coverage Summary
Pre-requisite: install [genhtml](https://manpages.ubuntu.com/manpages/focal/man1/genhtml.1.html)
 ```bash
yarn coverage
 ```

## Reset Submodules 

Update each submodules to latest commit recorded
```bash
# run from project root dir
git submodule update --init --recursive
```

Reset the checked out commit for each submodule
```bash
cd packages/contracts/lib/<SUBMODULE>
git reset --hard HEAD
```