# Docker image for the primary terria map application server
FROM osgeo/gdal:alpine-small-3.1.0 as build

RUN apk update && apk upgrade && \
    apk add --no-cache bash git openssh npm
RUN mkdir -p /etc/config/client
WORKDIR /usr/src/app

COPY ./package.json ./
RUN npm install

COPY . .

RUN rm wwwroot/config.json && ln -s /etc/config/client/config.json wwwroot/config.json

RUN cp -r node_modules/@juanezm/terriajs node_modules && rm -rf node_modules/@juanezm/

ENV NODE_ENV production

FROM build as solomon_build
RUN cp -r wwwroot/help/img/help_solomon/. wwwroot/help/img/.
RUN cp wwwroot/images/SI_high.png wwwroot/images/help_logo.png
RUN npm run gulp release

FROM build as vanuatu_build
RUN sed -i 's/hsl(209, 79%, 42%)/hsl(44, 92%, 45%)/' lib/Styles/variables.scss
RUN sed -i 's/Solomon Islands/Vanuatu/' node_modules/terriajs/lib/Language/en/translation.json
RUN npm run gulp release
