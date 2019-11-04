Job Vacancy Application - Pentos
================================

[![build status](https://gitlab.com/fiuba-memo2/tp2/pentos-bot/badges/master/build.svg)](https://gitlab.com/fiuba-memo2/tp2/pentos-bot/commits/master)

## Environments

- Production: Pentos LaNona Bot (@pentos_lanona_bot)
- Staging: Pentos LaNona Bot (staging) (@pentos_lanona_staging_bot)

## Development team

- Martin Picco
- Kevin Spasiuk
- Edson Justo

## Workflow

The project's development is guided by a simple version of [*Feature Branching Schema*](https://nvie.com/posts/a-successful-git-branching-model/).

There are two main branches: **master** and **develop**. Each holds the source code of production and staging environments respectively.

We create a feature branch for user story. When the feature is completed a merge request to develop is created.
Every merge request is reviewed and approved by at least one member of the developmet team.

Deployments to heroku are triggered by changes on any of the main branches.