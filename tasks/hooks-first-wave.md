# Задача: развить слой shared hooks в backend-agent-kit

Дата создания: 06.05.2026  
Статус: в работе  
Актуализировано: 06.05.2026

## Цель

Собрать первую практическую волну shared hooks для `tools/backend-agent-kit/hooks/`,
чтобы в репозитории появился минимальный, но полезный набор безопасных lifecycle automation rules
для common backend workflow.

Результат должен дать:

- несколько действительно полезных shared hooks вместо пустого каталога;
- безопасные deterministic automations с минимальным side effect;
- baseline safe guard и lightweight validation для нескольких backend-сервисов;
- backlog controlled expansion для самого чувствительного слоя в `backend-agent-kit`.

## Текущее состояние каталога

Сейчас `tools/backend-agent-kit/hooks/` фактически пуст:

- `.gitkeep`

Следствие:

- слой еще не заполнен реальными shared hooks;
- первую волну нужно собирать осторожно, начиная с максимально безопасных сценариев;
- не стоит сразу добавлять много automation с неясным поведением или тяжелыми side effects.

## Контекст и ограничения

Слой `hooks/` нужен для детерминированной lifecycle automation.
В отличие от instructions, hook не советует, а выполняет команду или блокирует действие.

Это самый чувствительный слой в каталоге, потому что ошибка здесь:

- ломает workflow автоматически, а не рекомендацией;
- может вносить side effects без прямого решения пользователя;
- быстро становится раздражающей, если hook шумный, медленный или нестабильный.

Важно сохранить границы слоев:

- `instructions/` - для always-on правил без гарантированного исполнения;
- `prompts/` - для ручного slash-command запуска;
- `agents/` - для роли, tool boundaries и handoff behavior;
- `skills/` - для repeatable workflow с supporting resources;
- `hooks/` - только для deterministic automation или enforcement на lifecycle-событиях;
- `scripts/` - для helper automation, на которую ссылаются hooks.

Следствие:

- не делать hook, если достаточно обычной instructions-подсказки;
- не запускать в hook долгие, нестабильные или сетевые команды без крайней необходимости;
- не подмешивать в shared hook repo-specific scripts или локальную инфраструктуру Leo.Products;
- не делать hook с размытым intent вроде «помогать разработчику», если нельзя точно описать trigger и effect;
- не использовать hook для скрытого форматирования или массовой правки, пока не доказана безопасность такого поведения.

## Критерии хорошего shared hook

Каждый новый hook должен:

- иметь один ясный lifecycle intent;
- быть безопасным по side effect;
- иметь ограниченный runtime и понятный failure mode;
- работать детерминированно;
- быть полезным нескольким backend-сервисам;
- не зависеть от одной локальной инфраструктуры или команды;
- при необходимости опираться на явный helper script в `scripts/`.

Признак того, что hook действительно нужен:

- рекомендация без enforcement уже регулярно не срабатывает;
- поведение можно формализовать как четкий trigger и четкий action;
- сценарий повторяется достаточно часто и его ценность выше, чем раздражение от автоматизации.

## Первая волна shared hooks

Первую волну нужно собирать только из safe-first сценариев: guard, lightweight context, cheap validation.

### 1. shared-dangerous-command-guard.json

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- блокировать заведомо опасные destructive terminal-команды.

Что должно покрывать:

- `git reset --hard`
- `git checkout -- <path>`
- `rm -rf`
- другие команды, которые могут безвозвратно снести изменения или повредить репозиторий.

Почему это хороший первый hook:

- intent однозначный;
- side effect контролируемый: hook только блокирует действие;
- сценарий полезен почти в любом backend-репозитории.

### 2. shared-session-context.json

Статус: [ ] не начато  
Приоритет: высокий

Назначение:

- подмешивать в session start короткий технический контекст без side effects.

Что должно попадать в контекст:

- repo root;
- текущая ветка;
- наличие submodule `tools/backend-agent-kit`, если он есть;
- возможно, другие cheap signals, полезные для безопасной навигации по рабочему дереву.

Почему это хороший первый hook:

- hook только добавляет контекст;
- не меняет файлы;
- снижает риск ошибочных команд и неверной навигации.

### 3. shared-post-edit-shell-syntax-check.json

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- после редактирования shell-скриптов прогонять дешевую синтаксическую проверку.

Что должно покрывать:

- `.sh` файлы;
- при необходимости и наличии явного соглашения `.bash`/`.zsh` scripts.

Почему это хороший кандидат:

- проверка дешевая;
- side effect минимальный;
- помогает ловить очевидные ошибки сразу после edit.

Ограничение:

- запускать только если проверка действительно дешевая и не шумит на неподдерживаемых shell-файлах.

### 4. shared-pre-finish-dirty-worktree-summary.json

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- перед завершением сессии показывать короткую сводку по dirty worktree и submodule state.

Что должно попадать в summary:

- modified/staged files;
- dirty submodules;
- явный сигнал, если в рабочем дереве остались незакоммиченные изменения.

Почему это хороший кандидат:

- side effect ограничен диагностикой;
- помогает не терять хвосты после серии изменений;
- полезен в монорепозитории с submodule.

Ограничение:

- summary должен быть коротким и не шумным.

## Вторая волна shared hooks

Эти hooks полезны, но их лучше брать только после успешной первой волны и после проверки, что baseline automation не раздражает и не ломает workflow.

### 1. shared-post-edit-json-validate.json

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- cheap validation для измененных `.json` файлов, особенно hooks/config artifacts.

### 2. shared-post-edit-markdown-check.json

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- базовая проверка измененных markdown-файлов, если будет согласован легкий и стабильный validator.

### 3. shared-format-after-edit.json

Статус: [ ] не начато  
Приоритет: средний

Назначение:

- автоматическое форматирование после edit, но только если formatter contract стабилен и безопасен.

Ограничение:

- этот hook легко становится раздражающим и рискованным, поэтому он не должен входить в первую волну без явной стандартизации formatter strategy.

### 4. shared-backend-agent-kit-sync-check.json

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- cheap check, не забыли ли прогнать sync после изменений shared слоев `backend-agent-kit`.

Ограничение:

- этот hook уже ближе к toolkit-specific automation и требует аккуратной проверки на portability.

### 5. shared-pre-finish-required-validation.json

Статус: [ ] не начато  
Приоритет: низкий

Назначение:

- напоминать о незапущенной валидации перед завершением, если для измененного среза не выполнены очевидные cheap checks.

Ограничение:

- здесь особенно легко сделать hook слишком шумным или слишком умным, поэтому такой сценарий требует отдельной осторожности.

## Что не надо выносить в shared hooks

Держать локально или в других слоях, а не в shared hooks:

- hooks, завязанные на локальные scripts и инфраструктуру Leo.Products;
- automation с долгими сетевыми вызовами;
- hooks с массовым редактированием файлов без очень сильной причины;
- team-specific process reminders без четкого lifecycle trigger;
- how-to инструкции и workflow-описания, которые лучше оформить как `docs/` или `skills/`;
- разовые полезные команды, которые лучше держать как `prompts/`.

## Рекомендуемый порядок заполнения

Предлагаемый первый practical batch:

1. `shared-dangerous-command-guard.json`
2. `shared-session-context.json`
3. `shared-post-edit-shell-syntax-check.json`

Следующий batch:

1. `shared-pre-finish-dirty-worktree-summary.json`
2. `shared-post-edit-json-validate.json`
3. `shared-post-edit-markdown-check.json`

## Шаблон для каждого hook-файла

Использовать как минимальную заготовку:

```json
{
  "hooks": {
    "<LifecycleEvent>": [
      {
        "type": "command",
        "command": "./scripts/<helper>.sh",
        "timeout": 15
      }
    ]
  }
}
```

Если hook только блокирует опасное действие, structure может отличаться,
но lifecycle intent, failure mode и bounded effect должны быть очевидны сразу.

Если hook требует нетривиальную внешнюю команду, сначала нужно:

- вынести helper в `scripts/`;
- описать failure mode;
- проверить, что команда безопасна и достаточно быстрая.

## Definition of Done

Слой считается достаточно развитым на этой волне, если:

- проведена инвентаризация текущего empty baseline hooks layer;
- выбраны только safe-first сценарии с минимальным side effect;
- добавлено не меньше 2-3 реально полезных shared hooks;
- для hooks с внешней логикой есть явные helper scripts, если они нужны;
- hooks не шумят, не тормозят workflow и не вносят неожиданные изменения;
- sync в consumer `.github/hooks/` проходит без drift.

## Чек-лист выполнения

- [ ] Зафиксировать текущий baseline shared hooks.
- [ ] Для каждого кандидата определить точный lifecycle intent.
- [ ] Для каждого кандидата проверить side effect, runtime и failure mode.
- [ ] При необходимости добавить helper scripts в `tools/backend-agent-kit/scripts/`.
- [ ] Создать first batch hook-файлов в `tools/backend-agent-kit/hooks/`.
- [ ] Прогнать sync в consumer repo.
- [ ] Проверить `.github/hooks/` и validate-only.
- [ ] Закоммитить shared hook batch и consumer sync отдельными коммитами.