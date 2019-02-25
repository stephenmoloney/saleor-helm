### Forked from mirumee/saleor (BSD-3 License)
### https://github.com/mirumee/saleor/blob/e3057df41ab6c5689f381dff5f3d5721d685d183/Dockerfile#L2-L75
FROM python:3.6 as build-python

COPY Pipfile /app/
COPY Pipfile.lock /app/
WORKDIR /app
RUN \
    apt-get update -y && \
    apt-get install -y --no-install-recommends gettext='0.19.8.1-2' && \
    pip install pipenv=='2018.11.26' && \
    pipenv install --system --deploy

FROM node:10 as build-nodejs

COPY webpack.config.js app.json package.json package-lock.json tsconfig.json tslint.json  webpack.d.ts /app/
COPY ./saleor/static /app/saleor/static/
COPY ./templates /app/templates/
WORKDIR /app
RUN \
    npm install && \
    npm run build-assets --production && \
    npm run build-emails --production

FROM python:3.6-slim

COPY . /app
COPY --from=build-python /usr/local/lib/python3.6/site-packages/ /usr/local/lib/python3.6/site-packages/
COPY --from=build-python /usr/local/bin/ /usr/local/bin/
COPY --from=build-nodejs /app/saleor/static /app/saleor/static
COPY --from=build-nodejs /app/webpack-bundle.json /app/
COPY --from=build-nodejs /app/templates /app/templates
WORKDIR /app
RUN \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
      libxml2='2.9.4+dfsg1-2.2+deb9u2' \
      libssl1.1='1.1.0j-1~deb9u1' \
      libcairo2='1.14.8-1' \
      libpango-1.0-0='1.40.5-1' \
      libpangocairo-1.0-0='1.40.5-1' \
      libgdk-pixbuf2.0-0='2.36.5-2+deb9u2' \
      shared-mime-info='1.8-1+deb9u1' \
      mime-support='3.60' && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    useradd --uid 1001 --gid 0 --create-home saleor && \
    mkdir -p /app/media /app/static && \
    chown -R 1001:0 /app
USER 1001
EXPOSE 8000

CMD ["uwsgi", "--ini", "/app/saleor/wsgi/uwsgi.ini"]
