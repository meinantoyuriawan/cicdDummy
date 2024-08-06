# pull official base image
FROM python:3.11-bullseye@sha256:e3b11c66dcd34900b566b6601c98b4285b7fbed1d97bf6ad1ac3dd97af54ba2b AS builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libxslt-dev libxml2-dev

# lint
RUN pip install --upgrade pip
RUN pip install flake8==5.0.4
COPY . /usr/src/app/
# RUN flake8 --ignore=E501,F401 .

# install python dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt

# pull official base image
FROM python:3.11-bullseye@sha256:e3b11c66dcd34900b566b6601c98b4285b7fbed1d97bf6ad1ac3dd97af54ba2b

# create directory for the app user
RUN mkdir -p /home/app

# create the app user
RUN addgroup --system --gid 2023 appgroup
RUN adduser --system --uid 1999 -gid 2023 app

# create the appropriate directories
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends
COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --upgrade pip
RUN pip install --no-cache /wheels/*

# copy project
COPY . $APP_HOME

# chown all the files to the app user
RUN chown -R app:appgroup $APP_HOME

# change to the app user
USER app