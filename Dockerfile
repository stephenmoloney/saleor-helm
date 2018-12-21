### Forked from mirumee/saleor (BSD-3 License)
### https://github.com/mirumee/saleor/blob/e3057df41ab6c5689f381dff5f3d5721d685d183/Dockerfile#L2-L75
FROM python:3.6 as build-python

ADD Pipfile /app/
ADD Pipfile.lock /app/
WORKDIR /app
RUN \
    apt-get -y update && \
    apt-get install -y gettext && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install pipenv && \
    pipenv install --system --deploy

FROM node:10 as build-nodejs

ADD webpack.config.js app.json package.json package-lock.json tsconfig.json webpack.d.ts /app/
ADD ./saleor/static /app/saleor/static/
ADD ./templates /app/templates/
WORKDIR /app
RUN \
    npm install && \
    npm run build-assets --production && \
    npm run build-emails --production


FROM python:3.6-slim

RUN \
    apt-get update && \
    apt-get install -y libxml2 libssl1.1 libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 shared-mime-info mime-support && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ADD . /app
COPY --from=build-python /usr/local/lib/python3.6/site-packages/ /usr/local/lib/python3.6/site-packages/
COPY --from=build-python /usr/local/bin/ /usr/local/bin/
COPY --from=build-nodejs /app/saleor/static /app/saleor/static
COPY --from=build-nodejs /app/webpack-bundle.json /app/
COPY --from=build-nodejs /app/templates /app/templates
WORKDIR /app
RUN \
    useradd --uid 1001 --gid 0 --create-home saleor && \
    mkdir -p /app/media /app/static && \
    chown -R 1001:0 /app
USER 1001
EXPOSE 8000

CMD ["uwsgi", "/app/saleor/wsgi/uwsgi.ini"]
