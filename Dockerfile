FROM node:lts-bullseye as build
ARG FRONTEND_ZIP_URL=https://github.com/fluidd-core/fluidd/archive/refs/heads/develop.zip
WORKDIR /
ADD ${FRONTEND_ZIP_URL} /tmp/build.zip
RUN unzip /tmp/build.zip -d /
WORKDIR /fluidd-develop
RUN npm ci --omit optional
RUN npm run build

FROM nginx:alpine

ENV JPEG_STREAM_HOST localhost
ENV JPEG_STREAM_PORT 8080

COPY --from=build --chown=101:101 /fluidd-develop/server/nginx-site.conf /etc/nginx/conf.d/default.conf
COPY --from=build --chown=101:101 /fluidd-develop/dist /usr/share/nginx/html
COPY --from=build --chown=101:101 /fluidd-develop/server/config.json /usr/share/nginx/html/config.json
EXPOSE 80
