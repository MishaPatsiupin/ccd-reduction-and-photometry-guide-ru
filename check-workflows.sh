#!/bin/bash

# Скрипт для проверки настройки GitHub Actions workflows
# Note: We don't use 'set -e' because we intentionally check for errors

echo "=========================================="
echo "Проверка конфигурации GitHub Actions"
echo "=========================================="
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Функция для проверки
check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        return 0
    else
        echo -e "${RED}✗${NC} $2"
        return 1
    fi
}

# Функция для проверки YAML синтаксиса
check_yaml() {
    python3 -c "import yaml; yaml.safe_load(open('$1'))" 2>/dev/null
    check $? "$1 имеет корректный YAML синтаксис" || ((errors++))
}

# Счётчик ошибок
errors=0

echo "1. Проверка наличия workflow файлов..."
[ -f ".github/workflows/ci_tests.yml" ]
check $? "ci_tests.yml существует" || ((errors++))

[ -f ".github/workflows/deploy.yml" ]
check $? "deploy.yml существует" || ((errors++))

[ -f ".github/workflows/release.yml" ]
check $? "release.yml существует" || ((errors++))

echo ""
echo "2. Проверка конфигурационных файлов Jupyter Book..."
[ -f "_config.yml" ]
check $? "_config.yml существует" || ((errors++))

[ -f "_toc.yml" ]
check $? "_toc.yml существует" || ((errors++))

echo ""
echo "3. Проверка зависимостей..."
[ -f "requirements.txt" ]
check $? "requirements.txt существует" || ((errors++))

echo ""
echo "4. Проверка структуры директорий..."
[ -d "notebooks" ]
check $? "Директория notebooks существует" || ((errors++))

[ -d ".github/workflows" ]
check $? "Директория .github/workflows существует" || ((errors++))

echo ""
echo "5. Проверка YAML синтаксиса workflows..."
check_yaml ".github/workflows/ci_tests.yml"
check_yaml ".github/workflows/deploy.yml"
check_yaml ".github/workflows/release.yml"
echo ""
echo "6. Проверка _config.yml..."
grep -q "MishaPatsiupin/ccd-reduction-and-photometry-guide-ru" _config.yml
check $? "Repository URL в _config.yml указывает на правильный репозиторий" || ((errors++))

echo ""
echo "7. Проверка README.md..."
grep -q "MishaPatsiupin.github.io/ccd-reduction-and-photometry-guide-ru" README.md
check $? "README.md содержит правильную ссылку на GitHub Pages" || ((errors++))

echo ""
echo "=========================================="
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}Все проверки пройдены успешно!${NC}"
    echo ""
    echo "Следующие шаги:"
    echo "1. Закоммитьте и запушьте изменения в main ветку"
    echo "2. Проверьте запуск workflow в разделе Actions на GitHub"
    echo "3. Для создания релиза создайте и запушьте тег:"
    echo "   git tag -a v1.0.0 -m 'Первый релиз'"
    echo "   git push origin v1.0.0"
    exit 0
else
    echo -e "${RED}Обнаружено ошибок: $errors${NC}"
    echo "Пожалуйста, исправьте ошибки перед продолжением"
    exit 1
fi
