# tp-app-base

Base image for Tei_Publisher generated apps, without autodeployed stock apps, but centraly configurable tei-publisher dependencies.

Automatic builds run daily on CI. Images are published to GitHubs container Registry. To pull:

```shell
docker pull ghcr.io/jinntec/base:main
```

## Tagging Scheme

TODO:

## Configuration Changes

The images modify exist to enhance security and performance for production uses. Namely:

- The [security recommendations](https://www.exist-db.org/exist/apps/doc/production_good_practice.xml#sect-attack-surface) for reducing potential attack surface.
- Building on [distroless nonroot](https://github.com/GoogleContainerTools/distroless) exist user is set accordingly.
- Performance tweaks to locktables
- Performance tweaks to disable restxq

Further desirable settings can be found among the official [ansible roles](https://github.com/eXist-db/existdb-ansible-role).

## Expath dependencies

See the [Dockerfile](https://github.com/Jinntec/tp-app-base/blob/main/Dockerfile#L26) for the list of included dependencies.

## Use Case
