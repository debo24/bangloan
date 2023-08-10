FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /contracts

# Set production environment
ENV PUBLIC_OWNER_ADDRESS="0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db"
ENV PUBLIC_OPERATOR_ADDRESS="0xC54f8862C4bB1c114d5b6C666410eb242a6c97Db"

# Copy files
COPY remappings.txt /contracts/remappings.txt
COPY foundry.toml /contracts/foundry.toml
COPY test /contracts/test
COPY src /contracts/src
COPY script /contracts/script
COPY lib /contracts/lib


CMD [ "forge", "test" ]
