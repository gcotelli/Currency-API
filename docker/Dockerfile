# Stage 1: Load the project
FROM ghcr.io/ba-st/pharo-loader:v10.0.0 as loader

COPY ./source/ ./source/
COPY ./.git/ ./.git/
RUN pharo metacello install gitlocal://./source BaselineOfCurrencyAPI --groups=Deployment

# Stage 2: Copy the resulting Pharo.image with our project loaded
# into a new launchpad-based docker image
FROM ghcr.io/ba-st/launchpad:v4

USER root

COPY --from=loader /opt/pharo/Pharo.image ./
COPY --from=loader /opt/pharo/Pharo.changes ./
COPY --from=loader /opt/pharo/Pharo*.sources ./

RUN mkdir logs \
  && chown --recursive pharo:users /opt/pharo

USER pharo

CMD [ "launchpad-start", "currency-api" ]
