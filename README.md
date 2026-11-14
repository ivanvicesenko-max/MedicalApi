# MedicalApi

Web API для частной клиники: пациенты, справки, каталог видов справок, запись на приём к врачу.

Данные хранятся в PostgreSQL, приложение работает с базой через EF Core. После перезапуска сервера ничего не пропадает.

```
Swagger / сайт  --HTTP-->  MedicalApi  --SQL-->  PostgreSQL (порт 5432)
```

## Что нужно

- .NET 10 SDK
- PostgreSQL (с pgAdmin), порт 5432
- инструмент миграций: `dotnet tool install --global dotnet-ef --version 10.0.0`

## Запуск

1. Проверить строку подключения в `appsettings.json` и поставить свой пароль от пользователя `postgres`:

   ```json
   "ConnectionStrings": {
     "Medical": "Host=localhost;Port=5432;Database=medical;Username=postgres;Password=postgres"
   }
   ```

   Пароль здесь от учебной базы на своём компьютере. Пароли настоящих баз в репозиторий не кладут.

2. Создать базу `medical` и таблицы. Руками ничего создавать не нужно, EF Core сделает это сам по миграциям:

   ```bash
   dotnet ef database update
   ```

3. Заполнить каталог видов справок: открыть `sql/medical-seed.sql` в pgAdmin (Query Tool в базе `medical`) и выполнить.

4. Запустить сервер:

   ```bash
   dotnet run --launch-profile http
   ```

   Swagger: `http://localhost:5036/swagger`

## Адреса

| Ресурс | Адрес |
| --- | --- |
| Пациенты, поиск по части ФИО без учёта регистра | `/api/patients?name=` |
| Справки пациента | `/api/patients/{id}/spravki` |
| Записи пациента | `/api/patients/{id}/appointments` |
| Виды справок | `/api/spravkatypes` |
| Справки с фильтрами | `/api/spravki?patientId=&spravkaTypeId=&minPrice=&maxPrice=&sort=` |
| Статистика по справкам за период | `/api/spravki/stats?from=&to=` |
| Статистика для главврача | `/api/stats` |
| Запись на приём | `/api/appointments?patientId=&doctorName=&date=` |

`sort` для справок: `date` (по умолчанию), `date_desc`, `price`, `price_desc`.

## База данных

| Таблица | Что хранит |
| --- | --- |
| `Patients` | пациенты (ФИО, дата рождения `date`, телефон, email) |
| `SpravkaTypes` | каталог: название и текущая цена |
| `Spravki` | выданные справки: пациент, вид, цена на момент продажи, дата |
| `Appointments` | записи на приём |
| `__EFMigrationsHistory` | какие миграции уже применены |

EF Core называет таблицы и столбцы с большой буквы, поэтому в SQL их пишут в кавычках:

```sql
SELECT "Id", "Name", "BirthDate" FROM "Patients";
```

### Миграции

| Миграция | Что делает |
| --- | --- |
| `Init` | таблицы и внешние ключи |
| `AddPatientEmail` | столбец `Email` у пациента |
| `RestrictDeleteSpravki` | запрет удалять пациента и вид справки, если на них ссылаются справки |

Поменяли модель, значит, новая миграция и обновление базы:

```bash
dotnet ef migrations add ИмяМиграции
dotnet ef database update
```

### Удаление пациента со справками

По умолчанию EF Core удалял бы справки вместе с пациентом (Cascade). Справки это медицинские документы, терять их нельзя, поэтому связь сделана `Restrict`: база не даст удалить пациента со справками. API проверяет это заранее и отвечает 400 с понятным текстом, а не 500. То же для вида справки, по которому уже выданы справки.

## SQL

| Файл | Что внутри |
| --- | --- |
| `sql/clinic.sql` | упражнения на чистом SQL в учебной базе `clinic`: таблицы, данные, запросы, проверка ограничений |
| `sql/ef-queries.sql` | SQL, который EF Core отправляет в базу для каждого эндпоинта пациентов, с объяснениями |
| `sql/medical-seed.sql` | заполнение каталога видов справок в базе `medical` |

Чтобы видеть в консоли значения параметров вместо `?`, можно временно дописать `.EnableSensitiveDataLogging()` после `UseNpgsql(...)` в `Program.cs`.

## Частые ошибки

| Ошибка | Что делать |
| --- | --- |
| `password authentication failed for user "postgres"` | неверный пароль в `appsettings.json` |
| `Failed to connect to 127.0.0.1:5432` | PostgreSQL не запущен: «Службы» → `postgresql-x64-...` → «Запустить» |
| `relation "patients" does not exist` | имена от EF Core пишут в кавычках: `"Patients"` |
| `column ... does not exist` | модель поменяли, а миграцию не применили: `dotnet ef database update` |
