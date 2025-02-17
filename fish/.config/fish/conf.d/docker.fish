# usage: if read_confirm ...
function read_confirm
  while true
    read -l -P 'Do you want to continue? [y/N] ' confirm

    switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

set -x info cyan
set -x warn yellow
set -x error red

function color_print
  set_color "$argv[1]"; echo -ne "$argv[2]"; set_color normal;
end

# ------------------------------------
# Docker alias and functions
# ------------------------------------
# Converted from: https://github.com/tcnksm/docker-alias/blob/master/zshrc

abbr -a dbl "docker build"
abbr -a dcin "docker container inspect"
abbr -a dcls "docker container ls"
abbr -a dclsa "docker container ls -a"
abbr -a dib "docker image build"
abbr -a dii "docker image inspect"
abbr -a dils "docker image ls"
abbr -a dipu "docker image push"
abbr -a dipru "docker image prune -a"
abbr -a dirm "docker image rm"
abbr -a dit "docker image tag"
abbr -a dlo "docker container logs"
abbr -a dnc "docker network create"
abbr -a dncn "docker network connect"
abbr -a dndcn "docker network disconnect"
abbr -a dni "docker network inspect"
abbr -a dnls "docker network ls"
abbr -a dnrm "docker network rm"
abbr -a dpo "docker container port"
abbr -a dpsa "docker ps -a"
abbr -a dpu "docker pull"
abbr -a dr "docker container run"
abbr -a drit "docker container run -it"
abbr -a drm "docker container rm"
abbr -a drm "docker container rm -f"
abbr -a dst "docker container start"
abbr -a drs "docker container restart"
abbr -a dsta "docker stop $(docker ps -q)"
abbr -a dstp "docker container stop"
abbr -a dtop "docker top"
abbr -a dvi "docker volume inspect"
abbr -a dvls "docker volume ls"
abbr -a dvprune "docker volume prune"
abbr -a dxc "docker container exec"
abbr -a dxcit "docker container exec -it"

# Get latest container ID
abbr -a dl "docker ps -l -q"

# Get container process
abbr -a dps "docker ps"

# Get process included stop container
abbr -a dpa "docker ps -a"
abbr -a dls "docker ps -a"

# Get container IP
abbr -a dip "docker inspect --format '{{ .NetworkSettings.IPAddress }}'"

# Run deamonized container, e.g., $dkd base /bin/echo hello
abbr -a dkd "docker run -d -P"

# Run interactive container, e.g., $dki base /bin/bash
abbr -a dki "docker run -i -t -P"

# Execute interactive container, e.g., $dex base /bin/bash
abbr -a dex "docker exec -i -t"

# Stop and Remove all containers
abbr -a drmf 'docker stop (docker ps -a -q); docker rm (docker ps -a -q)'

# Remove dangling volumes
abbr -a drmv 'docker volume rm (docker volume ls -qf "dangling=true")'

# Remove dangling images
abbr -a drmd 'docker rmi (docker images -q)'

# Remove exited containers:
abbr -a drxc 'docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v'

# Remove unused images:
abbr -a drui 'docker images --no-trunc | grep \'<none>\' | awk \'{ print $3 }\' | xargs docker rmi'

# Remove all things docker
abbr -a dprune 'docker system prune -a'

function dstop -d "Stop all containers"
  color_print $warn "Docker: Stop all containers\n"
    set ARG (docker ps -a -q)
    if test -n "$ARG"
      docker stop $ARG
    else
      color_print $info "Docker: Nothing to execute."
    end
end

function drm -d "Remove all containers"
  color_print $warn "Docker: Remove all containers\n"
  if read_confirm
    set ARG (docker ps -a -q)
    if test -n "$ARG"
      docker rm $ARG
    else
      color_print $info "Docker: Nothing to execute."
    end
  end
end

function dri -d "Remove all images"
  color_print $warn "Docker: Remove all images\n"
  if read_confirm
    set ARG (docker images -q)
    if test -n "$ARG"
      docker rmi $ARG
    else
      color_print $info "Docker: Nothing to execute."
    end
  end
end

function dbu -d "Dockerfile build, e.g., $dbu tcnksm/test"
  color_print $info "Docker: Dockerfile build\n"
  docker build -t=$argv[1] .
end

function dalias -d "Show all abbreviations related to docker"
  color_print $info "Docker: Show all abbreviations related to docker.\n"
  abbr | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort
end

function dbash -d "Bash into running container"
  color_print $info "Docker: Bash into running container.\n"
  docker exec -it (docker ps -aqf "name=$argv[1]") bash
end

