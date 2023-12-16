FROM postgres:16-alpine3.19
ENV POSTGRES_DB liquibase_db
ENV POSTGRES_USER liquibase_user
ENV POSTGRES_PASSWORD liquibase_password
COPY src/main/resources/db/init/create-schema.sql /docker-entrypoint-initdb.d