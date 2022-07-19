#!/usr/bin/env bash

set -eux

docker-compose up -d --build api
sleep 5

docker run \
  --rm \
  --volume "$(pwd)":/etc/newman \
  --network "api-tests_default" \
  --link "api-tests_api_1" \
  postman/newman:4-alpine \
  run tests.json --color off --disable-unicode \
  --reporters cli,junit \
  --reporter-junit-export api-test-result.xml \
  --environment docker-environment.json \
  || docker-compose logs api

docker-compose down || docker-compose kill
