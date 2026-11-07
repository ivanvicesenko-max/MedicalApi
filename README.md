# MedicalApi

Web API для частной клиники: пациенты, справки, каталог видов справок, запись на приём к врачу.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/ivanvicesenko-max/MedicalApi)

## Запуск

- **В браузере (без компьютера):** нажать кнопку выше. Сервер запустится сам, Swagger откроется по адресу вида `https://...-5036.app.github.dev/swagger`.
- **В Visual Studio:** открыть `MedicalApi.csproj`, запустить (F5), открыть `http://localhost:5036/swagger`.

## Адреса

| Ресурс | Адрес |
| --- | --- |
| Пациенты | `/api/patients` |
| Справки пациента | `/api/patients/{id}/spravki` |
| Записи пациента | `/api/patients/{id}/appointments` |
| Виды справок | `/api/spravkatypes` |
| Справки | `/api/spravki?patientId=&spravkaTypeId=` |
| Статистика | `/api/spravki/stats?from=&to=` |
| Запись на приём | `/api/appointments?patientId=&doctorName=&date=` |
