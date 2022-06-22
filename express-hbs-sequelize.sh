#!/bin/bash
#  Файл выпонняет установку sequelize для postgres и cli

# Для того что бы все сработало:
# 1) Сохраняете себе этот файл и кидаете его в корень нового проекта.
# 2) chmod +x for-project-sequelize.sh  // файл по умолчанию не исполняемый, перед запуском выполнить эту команду в консоли где расположен файл.
# P.S. В дальнейшем файл не нужно каждый раз инициализировать, достаточно просто кинуть в корень проекта и запустить.
# 3) Профит! Теперь файл можно запускить в корне любого проекта введя ./for-project-sequelize.sh в консоли.

npm init -y

echo '{
  "name": "bash",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
"scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js --ignore session",
    "dbcreate": "npx sequelize db:create",
    "migrate": "npx sequelize db:migrate",
    "migrate:undo": "npx sequelize db:migrate:undo:all",
    "seed": "npx sequelize db:seed:all"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}' > package.json

npm i sequelize pg pg-hstore dotenv express morgan hbs
npm i -D sequelize-cli nodemon
npx create-gitignore node
npm audit fix

mkdir -p views/partials 
mkdir -p public/js
mkdir -p public/images
mkdir -p routes
mkdir -p controllers
mkdir -p middlewares

echo "const path = require('path');
require('dotenv').config()
 module.exports = {
 'config': path.resolve('db', 'dbconfig.json'),
 'models-path': path.resolve('db', 'models'),
 'seeders-path': path.resolve('db', 'seeders'),
 'migrations-path': path.resolve('db', 'migrations')
 };" > .sequelizerc


npx sequelize init

echo '{
  "development": {
    "use_env_variable": "DEV_DB_URL",
    "host": "127.0.0.1",
    "dialect": "postgres"
  },
  "test": {
    "use_env_variable": "TEST_DB_URL",
    "host": "127.0.0.1",
    "dialect": "postgres"
  },
  "production": {
    "use_env_variable": "PROD_DB_URL",
    "host": "127.0.0.1",
    "dialect": "postgres"
  },
  "seederStorage": "sequelize",
  "seederStorageTableName": "SequelizeData"
}' > ./db/dbconfig.json


echo "const { sequelize } = require('./models');
module.exports = async () => {
  try {
    await sequelize.authenticate();
    console.log('База данных успешно подключена.');
  } catch (error) {
    console.error('База не подключена.', error.message);
  }
};" > db/dbCheck.js  

echo '
DEV_DB_URL=postgres://admindb:admindb@localhost:5432/dbName
TEST_DB_URL=postgres://username:password@localhost:5432/dbName
PROD_DB_URL=postgres://username:password@localhost:5432/dbName' > .env 

echo "const express = require('express'); // подключение  express
const morgan = require('morgan'); // подключение  morgan
const hbs = require('hbs'); // подключение  handlebars
const path = require('path');
require('dotenv').config(); // подключение переменных env
const dbCheck = require('./db/dbCheck'); // подключение скрипта проверки соединения с БД

// импорт роутов
const indexRouter = require('./routes/indexRouter');
const catchErrors = require('./routes/catchErrors');

const app = express(); // создание экземпляра сервера express'a

dbCheck(); // вызов функции проверки соединения с базоый данных

app.set('view engine', 'hbs'); // настройка отрисовщика, в данный момент это HBS
// app.set('views', path.join(__dirname, 'views')); // раскоментить если не используются partials

hbs.registerPartials(\`\${__dirname}/views/partials\`); // закоментить если не используются partials

app.use(express.static(path.join(__dirname, 'public'))); // подключение  public директории
app.use(morgan('dev')); // добавление настроек и инициализация morgan
app.use(express.urlencoded({ extended: true })); // парсинг post запросов.
app.use(express.json()); // парсинг post запросов в json.

 // роутеры
app.use('/', indexRouter);

// catch 404 and forward to error handler
app.use(catchErrors);

const PORT = process.env.PORT || 3100;
app.listen(PORT, () => {
  console.log(\`Сервер запущен на http://localhost:\${PORT}\`);
});
" > app.js

echo '<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Document</title>
</head>
<body>
  {{{body}}}
</body>
</html>' > ./views/layout.hbs

echo "exports.mainPage = (req, res, next) => {
     res.render('index');
}" > ./controllers/indexController.js

echo "const express = require('express');
const router = express.Router();
const { mainPage } = require('../controllers/indexController');

router.use((req, res, next) => {
  res.render('error', { message: req.url });
});

router.use((err, req, res) => {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  res.status(err.status || 500);
  res.render('error');
});

module.exports = router;" > ./routes/catchErrors.js

echo "const express = require('express');
const router = express.Router();
const { mainPage } = require('../controllers/indexController');

router.get('/', mainPage);

module.exports = router;" > ./routes/indexRouter.js

echo '<h2 style="text-align: center;">Page {{message}} not found</h2>
<h3>{{error.status}}</h3>
<pre>{{error.stack}}</pre>' > ./views/error.hbs

echo '<h2>Hello Express</h2>' > ./views/index.hbs


