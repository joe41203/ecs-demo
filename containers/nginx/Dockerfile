FROM nginx:1.19.3

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y vim procps htop

COPY ./static-html /usr/share/nginx/html
