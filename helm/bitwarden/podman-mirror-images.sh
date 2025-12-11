#!/bin/bash
set -e

# Bash script to mirror container images via podman. Utilizes a very dumb config file as input

RED='\e[31m'
GRN='\e[32m'
YLW='\e[33m'
BLU='\e[36m'
BOLD='\e[1m'
NC='\e[0m'

log_status() {
  local info="$1"
  local exit_code="$2"
  local color=""
  local status_label=""
  if [ "$exit_code" -eq 0 ]; then
    status_label="${BOLD}OK${NC}"
    color="$GRN"
  else
    status_label="${BOLD}FAILED${NC}"
    color="$RED"
  fi
  echo -e "${color}[ ${status_label} ${color}] ${NC}${info}${NC}"
}

show_config() {
  echo -e "\nImages to mirror:"
  for image in ${IMAGES[@]}; do echo -e "- ${BLU}$image${NC}"; done
  echo -e "\nRegistry to mirror to: ${BLU}$TARGET_REGISTRY${NC}"
  echo -e "\nFile to save and load images to: ${BLU}$IMAGES_TAR${NC}\n"
}

show_mapping() {
  TPIPE="├──"
  LPIPE="└──"
  VPIPE="│"
  for image in ${IMAGES[@]}; do 
    NEW_TAG=$(echo "$image" | cut -d/ -f2-)
    echo -e "$image\n${VPIPE}\n${LPIPE}${BLU}${TARGET_REGISTRY}/${NEW_TAG}${NC}\n" 
  done
}

show_mirrorimages() {
  for image in ${IMAGES[@]}; do
    NEW_TAG=$(echo "$image" | cut -d/ -f2-)
    echo -e "${BLU}${TARGET_REGISTRY}/${NEW_TAG}${NC}"
  done
}

img_pull() {
  echo -e "${BLU}Pulling images${NC}"
  for image in ${IMAGES[@]}; do
    podman pull -q $image
    local exit_code=$?
    log_status "Pulled $image" $exit_code
    if [ "$exit_code" -ne 0 ]; then
      echo -e "${RED}$image not pulled. Check network connectivity or registry auth status${NC}"
      exit 1 
    fi
  done
  echo
}

img_push() {
  echo -e "${BLU}Pushing images to target registry: ${TARGET_REGISTRY}${NC}"
  for image in ${IMAGES[@]}; do
    NEW_TAG=$(echo "$image" | cut -d/ -f2-)
    podman image push -q --tls-verify=$TLS_VERIFY $image ${TARGET_REGISTRY}/${NEW_TAG}
    local exit_code=$?
    log_status "Pushed $image to: ${TARGET_REGISTRY}/${NEW_TAG}" $exit_code
    if [ "$exit_code" -ne 0 ]; then
      echo -e "${RED}$image not pushed. Check network connectivity or registry auth status${NC}"
      exit 1
    fi
  done
  echo
}

img_save() {
  echo -e "${BLU}Saving images${NC}"
  if [ -e "$IMAGES_TAR" ]; then log_status "${RED}Cannot modify an existing tarball. Remove the existing $IMAGES_TAR, or use a different save path.${NC}" 1; exit 1; fi
  podman save -q -m -o ${IMAGES_TAR} ${IMAGES[@]}
  local exit_code=$?
  log_status "Images saved to: $IMAGES_TAR" $exit_code
  if [ "$exit_code" -ne 0 ]; then
    echo -e "${RED}$image not saved. Verify all images were pulled${NC}"
    exit 1
  fi 
  echo
}

img_load() {
  echo -e "${BLU}Loading $IMAGES_TAR${NC}"
  if [ ! -e "$IMAGES_TAR" ]; then log_status "${RED}$IMAGES_TAR not found, where it be?${NC}" 1; exit 1; fi
  podman load -q -i $IMAGES_TAR
  local exit_code=$?
  log_status "Loaded images from: $IMAGES_TAR" $exit_code
  if [ "$exit_code" -ne 0 ]; then
    echo -e "${RED}$IMAGES_TAR not loaded. Verify $IMAGES_TAR file is present${NC}"
    exit 1
  fi 
  echo
}

cleanup() {
  for image in ${IMAGES[@]}; do
    # Print and store the IDs of the images in the script
    ID=$(podman images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | awk -v target="$image" '$1 == target {print $2}')
    if [[ -z "$ID" ]]; then echo -e "${YLW}$image - not found locally, skipping.${NC}"; continue; fi
    
    # Find the Repository names that match the ID in case of duplicates, and use this to pass to podman for removal
    ALL_IDS=$(podman images --format "{{.Repository}}:{{.Tag}} {{.ID}}" | awk -v id="$ID" '$2 == id {print $1}')
    
    echo "$ALL_IDS" | xargs -r podman rmi -f
    local exit_code=$?
    log_status "" $exit_code
    echo
    if [ "$exit_code" -ne 0 ]; then
      echo -e "${RED}$image not deleted. Podman broken??${NC}"
      return 1
    fi
  done
}

init_conf() {
  cat <<EOF > $(pwd)/example-mirror.conf
# Example configuration file. All variables are necessary, honestly just use a diff tool lol

# List of images to pull with tags, otherwise latest is assumed
IMAGES=(
docker.io/nginx:mainline-trixie
docker.io/jenkins/jenkins:jdk21
)

# Registry to mirror to, can add namespaces if permissions allow. Do not include trailing /
TARGET_REGISTRY="registry.example.com/foo"

# boolean true or false, Sets the --tls-verify flag on podman push
TLS_VERIFY=false

# Path to tarball to save and load images from
IMAGES_TAR="./images.tar"
EOF
  local exit_code=$?
  log_status "Created example config file: ${BLU}$(pwd)/example-mirror.conf${NC}" $exit_code
  if [ "$exit_code" -ne 0 ]; then
    echo -e "${RED}$(pwd)/example-mirror.conf not created. Can you write to $(pwd)??${NC}"
    return 1
  fi
}

helper() {
  cat <<EOF
Quick and easy way to mirror images for quick deployments using podman. 

  -> Create/Init a config file with data to define your image(s), target registry, and save/load tarball, etc

Usage: $0 [command] <config_file>

Commands:
  m2m <config_file>     Mirror to Mirror: Pull the images, then push them to your registry
  m2d <config_file>     Mirror to Disk: Pull the images, then save them to disk
  d2m <config_file>     Disk to Mirror: Load the images from disk, then push them to your registry
  clean <config_file>   Delete all local images that are specified in <config_file>, from your host
  values <config_file>  Show the configured values from <config_file>
  map <config_file>     Print the tree formatted mapping from public source to private registry based on <config_file> | Note: this may not be 100% accurate depending on how the target registry handles namespaces
  mirror <config_file>  Print the image names of the mirrored containers based on <config_file> | Note: this may not be 100% accurate depending on how the target registry handles namespaces

  -i, init              Create example-mirror.conf config file
  -h, help              Show this help message
EOF
}

# Validate config and inputs, there's most definately a better way to do this lmao
# Catch $1 to specify if those positional args require a config file to source
CMD="$1"
CONF_CMDS=("m2m" "m2d" "d2m" "clean" "values" "map" "mirror")
conf_required=false
for cmd in "${CONF_CMDS[@]}"; do if [[ "$CMD" == "$cmd" ]]; then conf_required=true; break; fi; done

# If commands require a config file catch it
if $conf_required; then
  if [[ $# -lt 2 ]]; then
    echo -e "${RED}Error: Command '$CMD' requires a config file.${NC}"
    echo "Usage: $0 $CMD <config_file>"
    exit 1
  fi

  # Catch $2 as the config file, source it, and make sure it's valid to some degree
  CONF="$2"
  if [[ ! -f "$CONF" ]]; then echo -e "${RED}Config file not found: $CONF${NC}"; exit 1; fi
  if [[ ! -r "$CONF" ]]; then echo -e "${RED}Config file is not readable: $CONF${NC}"; exit 1; fi

  # Source the supplied config file and make sure supplied data exists to a degree
  source "$CONF"
  VERIFY_VARS=(IMAGES TARGET_REGISTRY TLS_VERIFY IMAGES_TAR)
  for var in "${VERIFY_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then echo -e "${RED}Config file is missing required variable: $var${NC}"; exit 1; fi
  done
fi

if [[ $# -eq 0 ]]; then helper; exit 0; fi
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|help)
      helper
      exit 0
      ;;
    -i|init)
      init_conf
      exit 0
      ;;
    m2m)
      img_pull; img_push
      exit 0
      ;;
    m2d)
      img_pull; img_save
      exit 0
      ;;
    d2m)
      img_load; img_push
      exit 0
      ;;
    clean)
      cleanup
      exit 0
      ;;
    values)
      show_config
      exit 0
      ;;
    map)
      show_mapping
      exit 0
      ;;
    mirror)
      show_mirrorimages
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      helper
      exit 0
      ;;
  esac
done
