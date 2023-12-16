Подготовка
Если хочется чтобы миграции в бд жили в отдельной схеме ее предварительно надо создать.
Если подходит умолчание (схема public) стереть из образца
liquibaseSchemaName "liquibase"

Нужны будут
jdbc ulr
логин пароль в бд с правами для возможности выполнять миграции.


Текст задачи на настройку сборки



Для техлогина {техлогин} настроить сборку- , которая будет запускать миграцию.

Настроить сборку в jenkins 

Для  настроить сборку таким образом чтоб можно было выбрать ветку для выставления.
Гит проект:
{вставить проект с миграцией в гит}

Коннект в базе данных использовать техлогин {техлогин}
URL коннекта: 

Предоставить доступ к сборке: ФИО (Лдап)

https://www.liquibase.org/ - это инструмент для миграции данных БД.

Необходимо настроить джобу с помощью jenkins которая даст возможность выполнить одну из 2-х задач на выбор.

*1.*Первая будет запускать следующий скрипт в тестовой БД по умолчанию.

1.1 скрипт UPDATE:
gradle -PjdbcUsername=${user} -jdbcUrl=${jdbcUrl} -PjdbcPassword=${password} update
(выполняет модификацию БД)

а так же должна быть возможность запуска следующего скрипта при выборе параметра в этой же джобе.
1.2 скрипт ROLLBACK:
gradle -PjdbcUsername=${user} -PjdbcPassword=${password} -jdbcUrl=${jdbcUrl} rollback -PliquibaseCommandValue="${rollbackTag}"
(откат изменений в зависимости от параметра)



${username} ${password}- будут переданы по приватному каналу

${rollbackTag} - параметр который нужно будет указывать при сборки каждый раз разработчик


Обновление:

gradle -PjdbcUsername=${user} -jdbcUrl=${jdbcUrl} -PjdbcPassword=${password} update

gradle -PjdbcUsername=${user} -PjdbcPassword=${password} -jdbcUrl=${jdbcUrl} rollback -PliquibaseCommandValue="${rollbackTag}"

В проекте приведена тестовая миграция

В IDEA создать шаблон файла с содержимым и именем
changelog.xml
```
<?xml version="1.0" encoding="utf-8" ?>
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog https://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">
 
#set( $removePrefix = "src/main/resources/")
#set( $versionSlashPosition = $DIR_PATH.lastIndexOf("/"))
#set( $versionBeforeSlashPosition = $versionSlashPosition - 1)
#set( $featureSlashPosition = $DIR_PATH.lastIndexOf("/", $versionBeforeSlashPosition))
#set( $featurePosition =  $featureSlashPosition +1)
#set( $featureVersion =  $DIR_PATH.substring($featurePosition))
#set( $tagDatabase =  $featureVersion.replace("/", "."))
#set( $fileDir =  $DIR_PATH.replace($removePrefix, ""))
 
    <changeSet author="Ваш логин" id="1">
        <tagDatabase tag="$tagDatabase"/>
    </changeSet>
    <changeSet author="Ваш логин" id="2"  >
        <sqlFile path="$fileDir/migration.sql" />
        <rollback>
            <sqlFile path="$fileDir/rollback.sql"/>
        </rollback>
    </changeSet>
<!--
Скопировать для вставки в changelog-cumulative.xml
<include file="$fileDir/changelog.xml"/>
 
-->
</databaseChangeLog>
```
К нему создать вложенное создание файлов
migration.sql
rollback.sql

Создать файл changelog-cumulative.xml
```
<?xml version="1.0" encoding="utf-8" ?>
<databaseChangeLog
        xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog https://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">
 
#set( $removePrefix = "src/main/resources/")
#set( $fileDir =  $DIR_PATH.replace($removePrefix, ""))
#set( $pathToScript = $fileDir.concat('/changelog-cumulative.xml'))
<!--
Скопировать для вставки в changelog-cumulative.xml
<include file="$pathToScript"/>
 
-->
</databaseChangeLog>
```

Тогда нажимая правую кнопки мышки можно выбрать соответствующий вариант и создать заготовку куда останется прописать только sql для наката и отката.
При єтом имя тега будет состоять из 2х последних папок
Ожидается что первая папка - фича или идентификатор таски в jira
вложеная папка - версия