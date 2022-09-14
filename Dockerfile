FROM ocaml/opam:alpine-ocaml-4.14 as build

# Install system dependencies
RUN sudo apk update && sudo apk add --update libev-dev openssl-dev gmp-dev oniguruma-dev

RUN cd ~/opam-repository && git pull origin master && opam update

WORKDIR /home/opam

# Install Opam dependencies
ADD app.opam app.opam
RUN opam install . --deps-only

# Build project
COPY --chown=opam:opam . .
RUN opam exec -- dune build @install --profile=release

FROM alpine:3.12 as run

RUN apk update && apk add --update libev gmp git

RUN chmod -R 755 /var

COPY --from=build /home/opam/_build/default/bin/run.exe /bin/server

ENTRYPOINT /bin/server