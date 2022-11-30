# Code Server Base on Coder Code Server

This is build base on the [Coder Code Server](https://hub.docker.com/r/codercom/code-server). Added JDK, kubectl and maven command tools.

## To build The Image

**Build Locally**

```
docker build -t chengkuan/code-server:1.0.0 -f Dockerfile .
```
**Build and Push to Internal Registry**

```
docker buildx build --platform linux/arm64,linux/amd64 -t nexus.internal:7082/repository/containers/code-server:1.0.0  -f Dockerfile --push --output=type=registry,registry.insecure=true .
```
**Build and Push to Docker Hub**
```
docker buildx build --platform linux/arm64,linux/amd64 -t chengkuan/code-server:1.0.0  -f Dockerfile --push .
```