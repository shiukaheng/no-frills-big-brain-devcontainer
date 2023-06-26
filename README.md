# No-frills big brain devcontainer template for Ubuntu 22.04 LTS

## What is this?
The default devcontainer template for VS Code is too much third-party bloat. This barebones template aims to make the devcontainer as minimal as possible and emulates the regular Docker experience as much as possible, and uses a docker-compose.yml to configure the container instead of learning how to use the devcontainer.json file. On top of that, it also includes some macros to make it easier to write Dockerfiles.

## Pre-requisites
- Docker
- VS Code
- [VS Code Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

## How do I use this?
1. Clone this repo
2. Open the folder in VS Code
3. Click the green button in the bottom left corner of VS Code and select "Reopen in Container"

## What's included?
- Everything you need to configure is in the `.devcontainer` folder, inside:
  
    - `devcontainer.json` - The devcontainer configuration file (see [here](https://code.visualstudio.com/docs/remote/devcontainerjson-reference) for more info
    - `Dockerfile` - The Dockerfile used to build the devcontainer
    - `docker-compose.yml` - Declaratively configure what you want to expose to the devcontainer
    - `post_create.sh` - The script that runs after the devcontainer is created
    - `post_start.sh` - The script that runs after the devcontainer is started
    - `.bashrc` - The bashrc file that is copied into the devcontainer
    
- Also included is some juicy macros:
    - `RUN <command>` bash function which runs a command like it would in a regular terminal, but also adds to the Dockerfile if it succeeds.
       E.g.: `RUN apt-get install -y curl` will install curl and add `RUN apt-get install -y curl` to the Dockerfile

    - `UNRUN` undoes any RUN command by removing it from the Dockerfile and attempting to uninstall packages installed (if any)
       E.g.: `UNRUN apt-get install -y curl` will remove `RUN apt-get install -y curl` from the Dockerfile and attempt to uninstall curl.

      Alternatively, running it without a command removes the last Dockerfile line and tries undoing package installations if the line was to install packages.