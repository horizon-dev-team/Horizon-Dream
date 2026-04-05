## Horizon =][=

[![Build Status](https://github.com/horizon-dev-team/HORIZON-Project-Prototype/workflows/CI%20Suite/badge.svg)](https://github.com/horizon-dev-team/HORIZON-Project-Prototype/actions?query=workflow%3A%22CI+Suite%22)
[![Percentage of issues still open](https://isitmaintained.com/badge/open/horizon-dev-team/HORIZON-Project-Prototype.svg)](https://isitmaintained.com/project/horizon-dev-team/HORIZON-Project-Prototype "Percentage of issues still open")
[![Average time to resolve an issue](https://isitmaintained.com/badge/resolution/horizon-dev-team/HORIZON-Project-Prototype.svg)](https://isitmaintained.com/project/horizon-dev-team/HORIZON-Project-Prototype "Average time to resolve an issue")

### Это основной репозиторий Horizon по игре [Space Station 13](https://station13.ru/).

Space Station 13 — это наполненная паранойей ролевая игра, действие которой разворачивается на фоне бессмысленной металлической смертельной ловушки, маскирующейся под космическую станцию, с очаровательными спрайтами, призванными передать научно-фантастический сеттинг и его опасный подтекст. Веселитесь и выживайте!

## Быстрый старт

1. Требования
   - Для сборки проекта необходим [BYOND](https://www.byond.com/download/).
2. Сборка и запуск
   - Отклонировать/скачать данный репозиторий.
   - Запустить `BUILD.cmd`, или `RUN_SERVER.cmd` для локального сервера.
   - Скопировать содержимое из папки `config` в рабочую папку `cfg`.

- Пользователям Ubuntu/Debian:

  ```bash
  git clone https://github.com/horizon-dev-team/HORIZON-Project-Prototype && cd HORIZON

  # Сборка библиотеки rust-g
  sudo dpkg --add-architecture i386
  sudo apt update || true
  sudo apt install -o libssl1.1:i386
  bash tools/ci/install_rust_g.sh

  # Установка BYOND и запуск сервера
  bash tools/ci/install_byond.sh
  source $HOME/BYOND/byond/bin/byondsetup
  tools/build/build
  bash tools/ci/run_server.sh
  ```

**Сборка tgstation напрямую в DreamMaker устарела и может привести к ошибкам**, таким как `'tgui.bundle.js': cannot find file`.

## Среда разработки

[<img src="https://i.imgur.com/FMf8JBF.png" alt="Старт" width="150" align="left">](.github/guides/wip/coding.md)
**Работаешь с кодом впервые?**<br>Попробуй этот гайд, он обязательно тебя научит чему-нибудь, если будет в настроении!

## Полезное

[<img src="https://i.imgur.com/ZOxkRtD.png" alt="Upstream" width="150" align="left">](https://github.com/tgstation/tgstation)
**Наш Upstream. Ничего особенного.**<br>Основная часть обновлений берётся отсюда.

[<img src="https://i.imgur.com/RwAIgu6.png" alt="Баги" width="150" align="left">](.github/guides/wip/bug.md)
**Баги и что с ними делать.**<br>Гарантированное решение, когда фича перерастает в проблему.

[<img src="https://i.imgur.com/ZKyWpgK.png" alt="Иконки" width="150" align="left">](.github/guides/wip/icon.md)
**Как работать с этим форматом во внешних редакторах?**<br>В этом руководстве описан краткий гайд по работе с иконками бьёнда.

[<img src="https://i.imgur.com/uCDQuc4.png" alt="Редактор карт" width="150" align="left">](https://github.com/SpaiR/StrongDMM/releases)
**Наш основной инструмент для работы с картами.**<br>Экономит кучу времени, заменяя встроенный редактор практически полностью.

## Прочее

- [Скачивание и установка](.github/guides/DOWNLOADING.md)
- [Запуск локального сервера](.github/guides/RUNNING_A_SERVER.md)
- [Карты и Гейты](.github/guides/MAPS_AND_AWAY_MISSIONS.md)
- [Гайды для Контрибьюторов](.github/CONTRIBUTING.md)
- [/tg/station HACKMD](https://hackmd.io/@tgstation)
- [Как настроить сервер](.github/guides/RUNNING_A_SERVER.md).
- [Как скомпилировать билд в VSCode и настроить его](tools/build/README.md).

## Лицензия

Весь код до [коммита 333c566b88108de218d882840e61928a9b759d8f on 2014/12/31 at 4:38 PM PST](https://github.com/horizon-dev-team/HORIZON-Project-Prototype/commit/333c566b88108de218d882840e61928a9b759d8f) лицензирован под [GNU AGPL v3](https://www.gnu.org/licenses/agpl-3.0.html).

All code before [коммита 333c566b88108de218d882840e61928a9b759d8f on 2014/12/31 at 4:38 PM PST](https://github.com/horizon-dev-team/HORIZON-Project-Prototype/commit/333c566b88108de218d882840e61928a9b759d8f) лицензирован под [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html).
(Включая папку tools, но только если их readme не сообщает обратное)

Смотрите LICENSE и GPLv3.txt за подробностями.

TGS DMAPI API лицензирован как подпроект под MIT лицензией.

Посмотрите в самый низ [code/\_\_DEFINES/tgs.dm](./code/__DEFINES/tgs.dm) и [code/modules/tgs/LICENSE](./code/modules/tgs/LICENSE) для MIT лицензии.

Все ассеты включая иконки и звуки лицензированы под [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/), если это не обозначено где-то ещё.

Опубликованный русскоязычный текст в коде находится под лицензией [Creative Commons 4.0 BY-NC-SA license](https://creativecommons.org/licenses/by-nc-sa/4.0/), если это не обозначено где-то ещё. Это подразумевает под собой то, что использование нашего перевода где-либо ещё требует наличие данной авторской лицензии (включая всех авторов, которые когда-либо вносили правки) и отметки о том, что было изменено.
