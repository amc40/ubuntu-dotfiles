# ubuntu-dotfiles

Repository that sets up common config files in my home directory (dotfiles) for an Ubuntu machine.

Run `./install.sh` to run the setup. Setup steps should be idempotent.

## Docker

A pre-built Docker image is published to the GitHub Container Registry:

```bash
docker pull ghcr.io/amc40/ubuntu-dotfiles:latest
```

You can also specify a version:

```bash
docker pull ghcr.io/amc40/ubuntu-dotfiles:1.0.0
```

To build locally:

```bash
docker build -t ubuntu-dotfiles .
# With a specific Ubuntu version:
docker build --build-arg UBUNTU_VERSION=24.04 -t ubuntu-dotfiles .
# With a custom username:
docker build --build-arg USERNAME=myuser -t ubuntu-dotfiles .
```

### Publishing a new release

Images are published automatically when a semver tag is pushed:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This publishes the following tags to `ghcr.io/amc40/ubuntu-dotfiles`:
- `1.0.0` — exact version
- `1.0` — minor float
- `1` — major float
