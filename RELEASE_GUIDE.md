# Инструкция по созданию релизов и публикации

## Обзор GitHub Actions workflows

В репозитории настроены три workflow для автоматизации:

### 1. **Build and Deploy Book** (`ci_tests.yml`)
Основной workflow для сборки и публикации книги на GitHub Pages.

**Запускается автоматически:**
- При push в ветку `main`
- При создании pull request в `main`
- При создании тегов версий (например, `v0.3.7`, `1.0.0`)

**Что делает:**
- Собирает Jupyter Book из исходников
- Публикует на GitHub Pages в директорию `v/dev` для main ветки
- Публикует на GitHub Pages в директорию `v/{версия}` для тегов

**Доступ к опубликованной книге:**
- Последняя версия (dev): `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/dev/`
- Версионированные релизы: `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/v0.3.7/`

### 2. **Создание релиза** (`release.yml`)
Workflow для создания GitHub релизов с архивами книги.

**Запускается автоматически:**
- При создании тегов формата `v*.*.*` (например, `v1.0.0`)

**Можно запустить вручную:**
1. Перейдите в раздел **Actions** на GitHub
2. Выберите **Создание релиза**
3. Нажмите **Run workflow**
4. Введите версию (например, `v1.0.0`)

**Что делает:**
- Собирает книгу
- Создаёт архивы HTML версии (ZIP и TAR.GZ)
- Создаёт GitHub релиз с описанием
- Прикрепляет архивы к релизу

### 3. **Сборка и публикация Jupyter Book (ручной запуск)** (`deploy.yml`)
Дополнительный workflow для ручной сборки и публикации.

**Запускается только вручную:**
1. Перейдите в раздел **Actions** на GitHub
2. Выберите workflow
3. Нажмите **Run workflow**

**Что делает:**
- Собирает книгу
- Публикует в директорию `manual-deploy` на GitHub Pages

## Как создать релиз

### Способ 1: Создание тега (рекомендуется)

1. Создайте и запушьте тег версии:
```bash
git tag -a v1.0.0 -m "Первый релиз русской версии"
git push origin v1.0.0
```

2. GitHub Actions автоматически:
   - Соберёт книгу
   - Опубликует на GitHub Pages в директорию `v/v1.0.0`
   - Создаст релиз с описанием
   - Создаст и прикрепит архивы (ZIP и TAR.GZ)

### Способ 2: Ручной запуск workflow

1. Перейдите в репозиторий на GitHub
2. Откройте вкладку **Actions**
3. Выберите **Создание релиза** в списке слева
4. Нажмите **Run workflow**
5. Введите версию (например, `v1.0.0`)
6. Нажмите **Run workflow**

## Настройка GitHub Pages (уже настроено)

GitHub Pages должен быть настроен следующим образом:

1. Перейдите в **Settings** вашего репозитория
2. Откройте **Pages** в левом меню
3. В разделе **Source** выберите:
   - **Source**: Deploy from a branch
   - **Branch**: `gh-pages`
   - **Folder**: `/ (root)`
4. Нажмите **Save**

После этого книга будет доступна по адресу:
- Главная страница: `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/`
- Dev версия: `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/dev/`
- Релизы: `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/{версия}/`

## Ручное создание релиза (если workflows не работают)

Если вы хотите создать релиз вручную:

1. Соберите книгу локально:
```bash
# Из корня репозитория
jupyter-book build .
```

2. Создайте архивы:
```bash
# ZIP архив (Linux/Mac)
cd _build/html
zip -r ../../ccd-guide-russian-html.zip .
cd ../..

# TAR.GZ архив (Linux/Mac)
tar -czf ccd-guide-russian-html.tar.gz -C _build/html .
```

Для Windows (PowerShell):
```powershell
# ZIP архив
Compress-Archive -Path _build\html\* -DestinationPath ccd-guide-russian-html.zip

# Или используйте 7-Zip
7z a -tzip ccd-guide-russian-html.zip .\_build\html\*
```

3. На GitHub:
   - Перейдите в раздел **Releases**
   - Нажмите **Draft a new release**
   - Выберите или создайте тег (например, `v1.0.0`)
   - Заполните название и описание
   - Прикрепите архивы
   - Нажмите **Publish release**

## Версионирование

Рекомендуемая схема версий (Semantic Versioning):

- **v1.0.0** - Первый полный перевод
- **v1.1.0** - Добавлены новые переводы или улучшения
- **v1.0.1** - Исправление ошибок в переводе
- **v2.0.0** - Крупные изменения структуры

## Структура GitHub Pages

После публикации файлы размещаются следующим образом:

```
gh-pages ветка:
├── v/
│   ├── dev/          # Последняя версия из main ветки
│   ├── v0.3.7/       # Релиз v0.3.7
│   ├── v1.0.0/       # Релиз v1.0.0
│   └── ...
└── manual-deploy/    # Ручная публикация (если использовался deploy.yml)
```

## Проверка работы workflows

После настройки можно проверить работу workflows:

1. **Проверка автоматической публикации:**
   - Внесите небольшое изменение и запушьте в `main`
   - Проверьте раздел **Actions** на GitHub
   - После успешной сборки проверьте `https://MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru/v/dev/`

2. **Проверка создания релиза:**
   - Создайте тестовый тег: `git tag v0.0.1-test && git push origin v0.0.1-test`
   - Проверьте раздел **Actions** - должен запуститься workflow "Создание релиза"
   - После завершения проверьте раздел **Releases**

## Устранение проблем

### Workflow не запускается
- Проверьте, что файлы workflow находятся в `.github/workflows/`
- Проверьте права доступа: Settings → Actions → General → Workflow permissions (должно быть "Read and write permissions")

### GitHub Pages не обновляется
- Проверьте Settings → Pages
- Убедитесь, что выбрана ветка `gh-pages`
- Проверьте логи workflow в разделе Actions

### Релиз создаётся без архивов
- Проверьте логи workflow "Создание релиза"
- Убедитесь, что сборка книги прошла успешно
- Проверьте, что директория `_build/html` создаётся корректно

## Автоматизация (текущая настройка)

Все необходимые workflow уже настроены:
- `.github/workflows/ci_tests.yml` - основная сборка и публикация на GitHub Pages
- `.github/workflows/release.yml` - создание релизов с архивами
- `.github/workflows/deploy.yml` - ручная публикация (опционально)

Просто создайте тег и запушьте его, остальное сделают GitHub Actions!
