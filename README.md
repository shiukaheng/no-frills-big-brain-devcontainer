# No-frills devcontainer template for Ubuntu 20.04 LTS

## What is this?
The default devcontainer template for VS Code is too much third-party bloat. This barebones template aims to make the devcontainer as minimal as possible and emulates the regular Docker experience as much as possible and with as little magic as possible.

## What's included?
- Everything you need to configure is in the `.devcontainer` folder, inside:
    - `devcontainer.json` - The devcontainer configuration file (see [here](https://code.visualstudio.com/docs/remote/devcontainerjson-reference) for more info
    - `Dockerfile` - The Dockerfile used to build the devcontainer
    - `docker-compose.yml` - Declaratively configure what you want to expose to the devcontainer
    - `setup.sh` - The script that runs when the devcontainer is built
    - `.bashrc` - The bashrc file that is copied into the devcontainer