A quick and dirty way to mirror images using podman for low-to-high scenarios utilizing a list of images and settings within a target `<config_file>` file.

### Usage
```bash
./podman-mirror-images.sh [command] <config_file>
```

### Commands 

`./podman-mirror-images.sh -h`

|Command|Argument|Description|
|-|-|-|
|m2m|<config_file>|Mirror to Mirror: Pull the images, then push them to your registry|
|m2d|<config_file>|Mirror to Disk: Pull the images, then save them to disk|
|d2m|<config_file>|Disk to Mirror: Load the images from disk, then push them to your registry|
|clean|<config_file>|Delete all local images that are specified in <config_file>, from your host|
|values|<config_file>|Show the configured values from <config_file>|
|map|<config_file>|Print the tree formatted mapping from public source to private registry based on <config_file>|
|mirror|<config_file>|Print the image names of the mirrored containers based on <config_file>|
|-i, init||Create example-mirror.conf config file|
|-h, help||Show this help message|

### Basic config file structure

`./podman-mirror-images.sh -i`

```bash
# Example configuration file. All variables are required

# List of images to pull with tags, otherwise latest is assumed
IMAGES=(
docker.io/nginx:mainline-trixie
docker.io/jenkins/jenkins:jdk21
)

# Registry to mirror to, can add namespaces if permissions allow. Do not include trailing /
TARGET_REGISTRY="registry.example.com/foo"

# boolean true or false, Sets the --tls-verify flag on podman pull and push
TLS_VERIFY=false

# Path to tarball to save and load images from
IMAGES_TAR="./images.tar"
```