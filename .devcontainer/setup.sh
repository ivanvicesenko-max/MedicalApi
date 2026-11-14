#!/usr/bin/env bash
# Выполняется один раз при создании Codespace
set -e

echo "== psql: консольный клиент PostgreSQL"
sudo apt-get update -q
sudo apt-get install -y -q postgresql-client

echo "== dotnet-ef: команды миграций"
dotnet tool install --global dotnet-ef --version 10.0.0 || true
export PATH="$PATH:$HOME/.dotnet/tools"

echo "== ждём PostgreSQL"
until pg_isready -h localhost -U postgres; do sleep 1; done

echo "== пакеты и сборка"
dotnet restore

echo "== миграции: EF Core создаёт базу medical и таблицы"
dotnet ef database update

echo "== каталог видов справок"
export PGPASSWORD=postgres
COUNT=$(psql -h localhost -U postgres -d medical -tAc 'SELECT COUNT(*) FROM "SpravkaTypes"')
if [ "$COUNT" = "0" ]; then
  psql -h localhost -U postgres -d medical -f sql/medical-seed.sql
fi

echo "== готово. Подключиться к базе: psql -h localhost -U postgres -d medical (пароль postgres)"
