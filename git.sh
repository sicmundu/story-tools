#!/bin/bash

# Функция для запроса информации у пользователя
get_input() {
  echo "Введите ваш адрес валидатора (valoper):"
  read validator_address
  echo "Введите ваш Discord ID (число):"
  read discord_id
  echo "Введите ваш ник в Discord:"
  read discord_username
  echo "Введите ваш GitHub username:"
  read github_username
}

# Функция для подтверждения введённой информации
confirm_input() {
  echo "Вы ввели следующие данные:"
  echo "Адрес валидатора: $validator_address"
  echo "Discord ID: $discord_id"
  echo "Ник в Discord: $discord_username"
  echo "GitHub username: $github_username"
  
  while true; do
    read -p "Все верно? (да/нет): " confirm
    case $confirm in
      [Yy]* ) break;;
      [Nn]* ) get_input; confirm_input; break;;
      * ) echo "Пожалуйста, ответьте да или нет.";;
    esac
  done
}

# Функция для клонирования форка пользователя
clone_fork() {
    echo "Клонирование форка репозитория для пользователя $github_username..."
    git clone https://github.com/$github_username/story-validators-race.git
    cd story-validators-race || { echo "Не удалось перейти в директорию story-validators-race"; exit 1; }
}

# Функция для создания новой ветки
create_branch() {
    # Генерация случайного числа
    random_number=$((RANDOM % 1000))
    branch_name="${github_username}-branch-$random_number"
    echo "Создание новой ветки: $branch_name"
    git checkout -b $branch_name
}

# Начало основного скрипта
echo "Этот скрипт создаст файл data.json для участия в гонке Story Validators."

# Запрашиваем данные у пользователя
get_input

# Подтверждаем введённые данные
confirm_input

# Указываем путь для сохранения файла, используя имя валидатора
echo "Введите ваш монникер валидатора:"
read validator_moniker
file_path="wave-2/submissions/${validator_moniker}/data.json"

# Клонирование форка
clone_fork

# Создание новой ветки
create_branch

# Создаем директорию, если она не существует
mkdir -p wave-2/submissions/$validator_moniker

# Создаем файл data.json
echo "{
  \"validator_address\": \"$validator_address\",
  \"discord_id\": \"$discord_id\",
  \"discord_username\": \"$discord_username\"
}" > $file_path

echo "Файл data.json создан по пути $file_path"

# Добавляем и коммитим изменения
git add $file_path
git commit -m "Information file $validator_moniker"

# Пушим изменения в новую ветку
git push origin $branch_name

# Выводим ссылку для создания PR
echo "Создайте Pull Request по этой ссылке:"
echo "https://github.com/$github_username/story-validators-race/pull/new/$branch_name"
