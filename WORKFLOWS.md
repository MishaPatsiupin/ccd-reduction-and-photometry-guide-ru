# Настройка GitHub Actions Workflows

## Обзор

В репозитории настроены три GitHub Actions workflow для автоматизации сборки, публикации и создания релизов русской версии руководства по обработке CCD данных.

## Файлы workflows

### 1. `.github/workflows/ci_tests.yml` - Основной workflow
**Название:** "Build and Deploy Book"

**Триггеры:**
- Push в ветку `main`
- Pull request в ветку `main`
- Создание тегов версий:
  - `1.0.0` (без префикса)
  - `v1.0.0` (с префиксом v)
  - `1.0.0-alpha`, `v1.0.0-beta` (pre-release версии)

**Функции:**
1. Собирает Jupyter Book из исходных файлов
2. Публикует результат на GitHub Pages:
   - `v/dev/` для ветки main
   - `v/{версия}/` для тегов (например, `v/v0.3.7/`)

**Особенности:**
- Использует conda/mamba для управления зависимостями
- Кэширует данные для ускорения сборки
- Использует фиксированный SEED для воспроизводимости изображений

### 2. `.github/workflows/release.yml` - Создание релизов
**Название:** "Создание релиза"

**Триггеры:**
- Автоматически при создании тегов формата `v*.*.*` (например, `v1.0.0`)
- Вручную через GitHub Actions UI с указанием версии

**Функции:**
1. Собирает Jupyter Book
2. Создаёт архивы HTML версии:
   - `ccd-guide-russian-html.zip`
   - `ccd-guide-russian-html.tar.gz`
3. Создаёт GitHub Release с:
   - Автоматически сгенерированным описанием
   - Прикреплёнными архивами
   - Ссылками на онлайн версию

**Использование:**
```bash
# Автоматический запуск
git tag -a v1.0.0 -m "Первый релиз"
git push origin v1.0.0

# Или через UI:
# Actions → Создание релиза → Run workflow → Ввести версию
```

### 3. `.github/workflows/deploy.yml` - Ручная публикация
**Название:** "Сборка и публикация Jupyter Book (ручной запуск)"

**Триггеры:**
- Только ручной запуск через GitHub Actions UI

**Функции:**
1. Собирает Jupyter Book
2. Публикует в директорию `manual-deploy/` на GitHub Pages

**Использование:**
Этот workflow предназначен для экстренных случаев или тестирования.
- Actions → Сборка и публикация Jupyter Book (ручной запуск) → Run workflow

## Структура публикации на GitHub Pages

После работы workflows файлы размещаются в ветке `gh-pages`:

```
gh-pages/
├── v/
│   ├── dev/              # Последняя версия из main
│   │   ├── index.html
│   │   └── ...
│   ├── v0.3.7/          # Релиз v0.3.7
│   │   ├── index.html
│   │   └── ...
│   └── v1.0.0/          # Релиз v1.0.0
│       ├── index.html
│       └── ...
└── manual-deploy/        # Ручная публикация (опционально)
    ├── index.html
    └── ...
```

## URL доступа

### Онлайн версия
- **Dev версия:** https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/dev/
- **Релизы:** https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/v1.0.0/

### Скачиваемые архивы
- Доступны в разделе [Releases](https://github.com/MishaPatsiupin/ccd-reduction-and-photometry-guide-ru/releases)

## Конфигурация

### Требуемые настройки репозитория

1. **GitHub Pages:**
   - Settings → Pages
   - Source: Deploy from a branch
   - Branch: `gh-pages`
   - Folder: `/ (root)`

2. **Actions permissions:**
   - Settings → Actions → General
   - Workflow permissions: "Read and write permissions"
   - Allow GitHub Actions to create and approve pull requests: ✓

### Файлы конфигурации

- `_config.yml` - Конфигурация Jupyter Book
- `_toc.yml` - Оглавление книги
- `requirements.txt` - Python зависимости

## Как работают workflows

### Сборка книги

Все workflows используют команду:
```bash
jupyter-book build --all .
```

Это собирает книгу из корневой директории, используя:
- Конфигурацию из `_config.yml`
- Оглавление из `_toc.yml`
- Ноутбуки из директории `notebooks/`

Результат помещается в `_build/html/`.

### Публикация на GitHub Pages

Используется action `peaceiris/actions-gh-pages@v4`:
- Берёт содержимое из `_build/html/`
- Публикует в ветку `gh-pages`
- В нужную поддиректорию (`v/dev/`, `v/v1.0.0/`, и т.д.)

### Создание релизов

Используется action `softprops/action-gh-release@v1`:
- Создаёт новый GitHub Release
- Прикрепляет архивы
- Добавляет описание в markdown формате

## Тестирование workflows

### Проверка основной сборки
```bash
# 1. Сделайте коммит в main
git add .
git commit -m "Test commit"
git push origin main

# 2. Проверьте Actions на GitHub
# 3. После завершения проверьте:
#    https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/dev/
```

### Проверка создания релиза
```bash
# 1. Создайте тестовый тег
git tag v0.0.1-test
git push origin v0.0.1-test

# 2. Проверьте Actions → "Создание релиза"
# 3. После завершения проверьте Releases
```

### Проверка ручной публикации
```
1. Перейдите в Actions
2. Выберите "Сборка и публикация Jupyter Book (ручной запуск)"
3. Нажмите "Run workflow"
4. После завершения проверьте:
   https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/manual-deploy/
```

## Устранение проблем

### Workflow не запускается
- ✓ Проверьте формат тега (должен быть `v1.0.0`)
- ✓ Проверьте Actions permissions в Settings
- ✓ Проверьте, что файлы workflow в `.github/workflows/`

### Сборка падает с ошибкой
- ✓ Проверьте логи в Actions
- ✓ Проверьте `requirements.txt` - все ли зависимости установлены
- ✓ Проверьте `_config.yml` и `_toc.yml` на синтаксические ошибки

### GitHub Pages не обновляется
- ✓ Проверьте, что ветка `gh-pages` создана
- ✓ Проверьте Settings → Pages → Source
- ✓ Дайте 1-2 минуты на обновление GitHub Pages

### Релиз создаётся без архивов
- ✓ Проверьте логи step "Создание архива"
- ✓ Убедитесь, что `_build/html/` создалась успешно
- ✓ Проверьте наличие команд `zip` и `tar` в runner

## Дополнительная информация

- Подробная инструкция по релизам: [RELEASE_GUIDE.md](RELEASE_GUIDE.md)
- GitHub Actions документация: https://docs.github.com/en/actions
- Jupyter Book документация: https://jupyterbook.org/
