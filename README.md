![OrganizrHeader](https://github.com/causefx/Organizr/raw/v2-develop/plugins/images/organizr/logo-wide.png)

![OrganizrAbout](https://user-images.githubusercontent.com/16184466/53614282-a91e9e00-3b96-11e9-9b3e-d249775ecaa1.png)

Do you have quite a bit of services running on your computer or server? Do you have a lot of bookmarks or have to memorize a bunch of ip's and ports? Well, Organizr is here to help with that. Organizr allows you to setup "Tabs" that will be loaded all in one webpage. You can then work on your server with ease. Want to give users access to some Tabs? No problem, just enable user support and have them make an account. Want guests to be able to visit too? Enable Guest support for those tabs.

![OrganizrInfo](https://user-images.githubusercontent.com/16184466/53614285-a9b73480-3b96-11e9-835e-9fadd045582b.png)

![OrganizrGallery](https://user-images.githubusercontent.com/16184466/53614284-a9b73480-3b96-11e9-9bea-d7a30b294267.png)

<img src="https://user-images.githubusercontent.com/16184466/53615855-35cc5a80-3b9d-11e9-882b-f09f3eb18173.png" width="23%"></img>
<img src="https://user-images.githubusercontent.com/16184466/53615856-35cc5a80-3b9d-11e9-8428-1f2ae05da2c9.png" width="23%"></img>
<img src="https://user-images.githubusercontent.com/16184466/53615857-35cc5a80-3b9d-11e9-82bf-91987c529e72.png" width="23%"></img>
<img src="https://user-images.githubusercontent.com/16184466/53615858-35cc5a80-3b9d-11e9-8149-01a7fcd9160a.png" width="23%"></img>

[![OrganizrOverview](https://img.youtube.com/vi/LZL4smFB6wU/0.jpg)](https://www.youtube.com/watch?v=LZL4smFB6wU)

![OrganizrFeat](https://user-images.githubusercontent.com/16184466/53614283-a9b73480-3b96-11e9-90ef-6e752e067884.png)

- 'Forgot Password' support [receive an email with your new password, prerequisites: mail server setup]
- Additional language support
- Custom tabs for your services
- Customise the top bar by adding your own site logo or site name
- Enable or disable iFrame for your tabs
- Fail2ban support ([see wiki](https://docs.organizr.app/features/fail2ban-integration))
- Fullscreen Support
- Gravatar Support
- Keyboard shortcut support (Check help tab in settings)
- Login with Plex/Emby/LDAP or sFTP credentials
- Mobile support
- Multiple login support
- Nginx Auth_Request support ([see wiki](https://docs.organizr.app/features/server-authentication))
- Organizr login log viewer
- Personalise any theme: Customise the look and feel of Organizr with access to the colour palette
- Pin/Unpin sidebar
- Protect new user account creation with registration password
- Quick access tabs (access your tabs quickly e.g. www.example.com/#Sonarr)
- Set default page on launch
- Theme-able
- Unlimited User Groups
- Upload new icons with ease
- User management support: Create, delete and promote users from the user management console

![OrganizrFeatReq](https://user-images.githubusercontent.com/16184466/53614286-a9b73480-3b96-11e9-8495-4944b85b1313.png)

[![Feature Requests]](https://vote.organizr.app/)

![OrganizrDocker](https://user-images.githubusercontent.com/16184466/53667702-fcdcc600-3c2e-11e9-8828-860e531e8096.png)

[![Repository](https://img.shields.io/github/stars/GitTimeraider/organizr-docker?color=402885&style=for-the-badge&logo=github&logoColor=41add3&)](https://github.com/GitTimeraider/Organizr-docker)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/GitTimeraider/organizr-docker/build-and-push.yml?branch=main&color=402885&style=for-the-badge&logo=github&logoColor=41add3)](https://github.com/GitTimeraider/organizr-docker/actions)
[![GHCR Pulls](https://img.shields.io/badge/ghcr.io-pulls-402885?style=for-the-badge&logo=docker&logoColor=41add3)](https://ghcr.io/gittimeraider/organizr-docker)

## 🐳 Docker Images

This project provides multi-architecture Docker images hosted on GitHub Container Registry (GHCR).

### Supported Architectures
- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64/AArch64)

### Available Tags
- `latest` - Latest stable release from main branch
- `dev` - Development builds from develop branch  
- `v2.x.x` - Specific version tags
- `main` - Latest commit from main branch

### Quick Start

#### Docker Run
```bash
docker run -d \
  --name=organizr \
  -p 80:80 \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -v /path/to/config:/config \
  --restart unless-stopped \
  ghcr.io/gittimeraider/organizr-docker:latest
```

#### Docker Compose
```yaml
version: "3.8"
services:
  organizr:
    image: ghcr.io/gittimeraider/organizr-docker:latest
    container_name: organizr
    ports:
      - "80:80"
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
      - FPM=false
      - BRANCH=v2-master
    volumes:
      - ./config:/config
    restart: unless-stopped
```

### Parameters

| Parameter | Function |
| :----: | --- |
| `-p 80:80` | HTTP port for web interface |
| `-e PUID=1000` | UserID for file permissions |
| `-e PGID=1000` | GroupID for file permissions |
| `-e TZ=UTC` | Timezone (e.g., America/New_York) |
| `-e FPM=false` | Enable/disable FPM (optional) |
| `-e BRANCH=v2-master` | Organizr branch to use (optional) |
| `-v /config` | Persistent config directory |

### User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container. To avoid this, you can specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify:
```bash
chown -R 1000:1000 /path/to/config
```

### Health Check

The container includes a built-in health check that verifies the web service is responding:
```bash
docker exec organizr curl -f http://localhost:80/ || exit 1
```

### User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container. To avoid this, you can specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify:
```bash
chown -R 1000:1000 /path/to/config
```

### Health Check

The container includes a built-in health check that verifies the web service is responding:
```bash
docker exec organizr curl -f http://localhost:80/ || exit 1
```

### Building Locally

To build the image locally for development:

```bash
# Clone the repository
git clone https://github.com/GitTimeraider/Organizr-docker.git
cd Organizr-docker

# Build the image
docker build -t organizr-local .

# Run locally built image
docker run -d --name organizr-local \
  -p 80:80 \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ./config:/config \
  organizr-local
```

### Development

Use the provided `compose.local.yml` for local development:

```bash
# Start development environment
docker-compose -f compose.local.yml up -d

# View logs
docker-compose -f compose.local.yml logs -f

# Stop and cleanup
docker-compose -f compose.local.yml down
```

The optional parameters and GID and UID are described in the documentation.

##### Info

- Shell access whilst the container is running: `docker exec -it organizr /bin/bash`
- To monitor the logs of the container in realtime: `docker logs -f organizr`

![OrganizrSponsor](https://user-images.githubusercontent.com/16184466/53614287-a9b73480-3b96-11e9-9c8e-e32b4ae20c0d.png)

### Seedboxes.cc 

[![Seedboxes.cc](https://user-images.githubusercontent.com/16184466/154811062-201be154-6868-4a24-ade6-a26278935415.png)](https://www.seedboxes.cc)

### BrowserStack for allowing us to use their platform for testing

[![BrowserStack](https://avatars2.githubusercontent.com/u/1119453?s=200&v=4g)](https://www.browserstack.com)

### This project is supported by

<img src="https://opensource.nyc3.cdn.digitaloceanspaces.com/attribution/assets/SVG/DO_Logo_horizontal_blue.svg" width="200px"></img>

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://tronflix.app"><img src="https://avatars.githubusercontent.com/u/22502007?v=4?s=100" width="100px;" alt="Chris Yocum"/><br /><sub><b>Chris Yocum</b></sub></a><br /><a href="#test-tronyx" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="http://roxedus.dev"><img src="https://avatars.githubusercontent.com/u/7110194?v=4?s=100" width="100px;" alt="Roxedus"/><br /><sub><b>Roxedus</b></sub></a><br /><a href="#test-Roxedus" title="Tests">⚠️</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/HalianElf"><img src="https://avatars.githubusercontent.com/u/28244771?v=4?s=100" width="100px;" alt="HalianElf"/><br /><sub><b>HalianElf</b></sub></a><br /><a href="#test-HalianElf" title="Tests">⚠️</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END --
