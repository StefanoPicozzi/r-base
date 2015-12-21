# docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker r-base /bin/bash
docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker spicozzi/r-base Rscript $1
