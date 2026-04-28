---
name: professional-controllers
description: "Используй при полном рефакторинге ASP.NET Core контроллеров в этом репозитории: контракт, роутинг, именования, DTO, тесты и OpenAPI."
---

# Professional Controllers

## Цель
Использовать этот skill как workflow-режим полного рефакторинга контроллера.

## Связанные skills
- `.github/skills/controllers/SKILL.md`
- `.github/skills/controllers-contract-openapi/SKILL.md`
- `.github/skills/controllers-testing/SKILL.md`
- `.github/skills/validators/SKILL.md`

## Когда использовать
Используй этот skill, если нужно выполнить full refactoring контроллера, включая:
- изменение маршрутов и naming;
- обновление DTO и контрактов;
- migration strategy при breaking changes;
- синхронизацию OpenAPI;
- обновление unit/regression/compatibility тестов.

## Обязательные правила
1. Следовать всем обязательным правилам из master-skill `controllers`.
2. Не вносить breaking changes без согласованной migration strategy.
3. Обновлять OpenAPI и тесты в том же change set, где меняется контракт.
4. Проверять совместимость существующих клиентских сценариев.
5. При изменении route приводить публичные endpoint к явному lowercase/kebab-case resource-style, принятому в Leo.Orders и Leo.Identity.
6. Не оставлять CamelCase route как итог рефакторинга, если только это не явно согласованный временный compatibility-layer.

## Рекомендуемые практики
1. Сначала фиксировать текущий контракт (routes, DTO, status codes, errors), потом менять код.
2. Делать рефакторинг в порядке: contract -> code -> docs -> tests.
3. Вносить изменения малыми логическими шагами с промежуточной проверкой.
4. Явно документировать migration notes для клиентов API.
5. При выборе target route брать за образец контроллеры уровня `api/users`, `api/carts`, `api/wish-lists`, а не action-based CamelCase endpoint.

## Анти-паттерны
1. Рефакторинг маршрутов и DTO без обновления OpenAPI.
2. Локальные исправления, которые по факту являются breaking, без migration notes.
3. Перенос бизнес-логики в контроллер ради скорости внедрения.
4. Изменение контрактов без регрессионной проверки.
5. Перенос legacy action-route в новый код без попытки выровнять его к lower-case resource-style.

## Алгоритм принятия решений
1. Сними и зафиксируй текущий API-контракт.
2. Раздели изменения на non-breaking и breaking.
3. Для breaking подготовь migration strategy.
4. Выбери целевую lower-case/kebab-case схему route и проверь ее против референсов Leo.Orders и Leo.Identity.
5. Примени контрактные изменения и выровняй маршруты/DTO.
6. Обнови документацию, OpenAPI и атрибуты ответов.
7. Обнови unit/compatibility/regression тесты.
8. Проверь, что существующие клиенты работают без изменений поведения.

## Проверка перед завершением
1. Все требования из `controllers` выполнены.
2. Migration strategy и обратная совместимость проработаны.
3. OpenAPI обновлен синхронно с кодом.
4. Тесты затронутых сценариев проходят.
5. Нет неявных контрактных изменений.
6. Итоговые публичные route не содержат CamelCase/PascalCase сегментов без явно оговоренного compatibility-исключения.
