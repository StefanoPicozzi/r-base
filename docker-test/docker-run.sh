# docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker r-base R CMD check .
# docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker r-base R CMD BATCH $1
# docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker r-base /bin/bash
docker run -ti --rm -v "$PWD":/home/docker -w /home/docker -u docker r-base Rscript $1
