# Закрити порт Postgres і змінити пароль бази (SAM1-30, крок 1)

Production: droplet `206.189.107.151`, контейнер бази `helpbooost-db` (Kamal accessory `db`),
дані на хості в `/home/deploy/helpbooost-db/data` (перезапуск контейнера їх не зачіпає).

## Чому
- Порт `5432` був опублікований на `0.0.0.0`, тобто відкритий в інтернет.
- У логах бази з 2026-06-06 по 2026-11-19 — **9 515 невдалих спроб входу**, з них **15 саме під
  користувачем `helpbooost`**. `log_connections` вимкнено, тож успішні входи ззовні не видно —
  пароль треба вважати скомпрометованим і змінити.

## Що де лежить
| Що | Де | Примітка |
|---|---|---|
| Порт бази | `config/deploy.yml` → `accessories.db.port` | після цього PR: `"127.0.0.1:5432:5432"` |
| Пароль для Kamal | `.kamal/secrets` → `POSTGRES_PASSWORD=$POSTGRES_PASSWORD` | значення береться зі змінної оточення |
| URL баз для Kamal | `.kamal/secrets` → `DATABASE_URL`, `QUEUE_/CACHE_/CABLE_DATABASE_URL` | будуються з `$POSTGRES_PASSWORD`, окремо міняти не треба |
| Пароль у CI (деплой) | GitHub → репозиторій → Settings → Secrets and variables → Actions → `POSTGRES_PASSWORD` | саме звідси бере пароль деплой з `master` |
| URL баз у CI | там само: `DATABASE_URL`, `QUEUE_DATABASE_URL`, `CACHE_DATABASE_URL`, `CABLE_DATABASE_URL` | Kamal їх перекриває рядками з `.kamal/secrets`, але якщо в них старий пароль — оновити теж (або прибрати з workflow окремою задачею) |
| Пароль ролі в самому Postgres | роль `helpbooost` у контейнері `helpbooost-db` | змінна `POSTGRES_PASSWORD` діє лише при першій ініціалізації бази; змінює пароль тільки `ALTER ROLE` |
| Застосунок | `config/database.yml` (production) | бере `POSTGRES_PASSWORD` і `*_DATABASE_URL` з оточення контейнера |

## 0. Підготовка (локально)
```bash
cd ~/my_project/simple_blog
git switch master && git pull          # після мерджу цього PR у master
kamal version                          # очікується 2.12.0
mkdir -p ~/backups/simple_blog
```
Для ручних команд Kamal потрібні змінні з `.kamal/secrets` (значення беруться з оточення).
Перед `kamal accessory reboot` / `kamal deploy` задай щонайменше ці дві (пароль бази — новий після кроку 3):
```bash
read -rs POSTGRES_PASSWORD && export POSTGRES_PASSWORD             # пароль не потрапить в історію
read -rs KAMAL_REGISTRY_PASSWORD && export KAMAL_REGISTRY_PASSWORD # токен GHCR (той самий, що в GitHub secrets)
```

## 1. Бекап усіх баз (тільки читання)
```bash
kamal accessory exec db --reuse -q "pg_dumpall -U helpbooost" > ~/backups/simple_blog/$(date +%F)_pg_dumpall.sql
ls -lh ~/backups/simple_blog/$(date +%F)_pg_dumpall.sql
grep -c "^CREATE DATABASE" ~/backups/simple_blog/$(date +%F)_pg_dumpall.sql   # очікується 4
```
Якщо файл порожній або без `CREATE DATABASE` — далі не йти.

## 2. Закрити порт (вікно обслуговування, ~1–2 хв)
Мердж PR сам нічого не змінює: CI робить `kamal deploy`, а він не перезапускає accessories.
Нове прив'язування порту застосовує лише перезапуск accessory:
```bash
kamal app maintenance          # відвідувачі бачать сторінку обслуговування
kamal accessory reboot db      # контейнер бази перестворюється з новим портом; дані на хості лишаються
kamal app live
```
Перевірка:
```bash
# ззовні — порт має бути закритий
timeout 3 bash -c '</dev/tcp/206.189.107.151/5432' && echo "ВІДКРИТИЙ — СТОП" || echo "закритий — ок"
# на сервері — лише локальний інтерфейс
kamal server exec -q "docker ps --filter name=helpbooost-db --format '{{.Ports}}'"   # 127.0.0.1:5432->5432/tcp
# сайт і база працюють
curl -fsS https://helpbooost.com/up && echo " up ok"
kamal app exec --reuse -q "bin/rails runner 'puts ActiveRecord::Base.connection.select_value(%q{SELECT 1})'"
kamal app logs --lines 50 | grep -iE "PG::|ConnectionNotEstablished" || echo "помилок БД у логах немає"
```

## 3. Змінити пароль бази
Робити одразу після кроку 2: між `ALTER ROLE` і перезапуском застосунку **нові** підключення до бази
не пройдуть (уже відкриті продовжать працювати), тож кроки 3.2–3.4 — без пауз.

**3.1. Згенерувати пароль.** Тільки hex-символи, щоб пароль безпечно вставлявся в URL:
```bash
openssl rand -hex 32
```
Збережи в менеджер паролів.

**3.2. Змінити пароль ролі в Postgres.** Інтерактивно, щоб пароль не потрапив в історію shell і логи Kamal:
```bash
kamal accessory exec db --reuse -i "psql -U helpbooost -d postgres"
```
У psql:
```sql
\password helpbooost
-- двічі ввести новий пароль
\q
```

**3.3. Оновити секрети.**
- GitHub → Settings → Secrets and variables → Actions → `POSTGRES_PASSWORD` → Update → новий пароль.
- Якщо `DATABASE_URL`, `QUEUE_DATABASE_URL`, `CACHE_DATABASE_URL`, `CABLE_DATABASE_URL` містять пароль —
  оновити й їх (формат `postgres://helpbooost:<пароль>@helpbooost-db/<база>`).
- Локально (якщо деплоїш з машини): `read -rs POSTGRES_PASSWORD && export POSTGRES_PASSWORD`, і там, де ти
  зберігаєш змінні для Kamal (менеджер паролів, `.envrc` тощо). У git пароль не додавати.

**3.4. Перезапустити застосунок з новим паролем.**
- Через CI: GitHub → Actions → останній успішний run «CI/CD Pipeline» на `master` → Re-run all jobs
  (повторний запуск бере актуальні секрети).
- Або локально (з експортованими секретами): `kamal deploy`.

**3.5. Оновити змінну в accessory (для узгодженості).** Пароль уже змінено через `ALTER`, а `POSTGRES_PASSWORD`
в оточенні контейнера бази ні на що не впливає після ініціалізації. Щоб не лишалось старого значення:
```bash
kamal accessory reboot db      # з уже експортованим новим POSTGRES_PASSWORD; короткий перезапуск бази
```

**3.6. Перевірка.**
```bash
curl -fsS https://helpbooost.com/up && echo " up ok"
kamal app exec --reuse -q "bin/rails runner 'puts ActiveRecord::Base.connection.select_value(%q{SELECT 1})'"
kamal app logs --roles=job --lines 50 | grep -iE "password authentication failed|PG::" || echo "job ок"
kamal server exec -q "docker logs --since 10m helpbooost-db 2>&1 | grep -c 'password authentication failed'"   # очікується 0
```

## 4. Як тепер підключатись до бази
- **psql на сервері:**
  `kamal accessory exec db --reuse -i "psql -U helpbooost -d helpbooost_production"`
- **Rails:** `kamal app exec --reuse -i "bin/rails dbconsole"` або `... "bin/rails console"`.
- **GUI (DBeaver, TablePlus, pgAdmin) через SSH-тунель:**
  ```bash
  ssh -N -L 15432:127.0.0.1:5432 deploy@206.189.107.151
  ```
  і в клієнті: host `127.0.0.1`, port `15432`, user `helpbooost`, database `helpbooost_production`
  (або `_queue`, `_cache`, `_cable`), пароль — новий.
- Напряму `206.189.107.151:5432` більше не працює — так і має бути.

## Відкат
- **Сайт не бачить базу після кроку 2.** Перевір `docker ps` (контейнер `helpbooost-db` запущений?) і
  `kamal accessory logs db`. Повернути старий порт: у `config/deploy.yml` тимчасово `port: 5432`,
  `kamal accessory reboot db`.
- **Після зміни пароля застосунок не підключається.** Найчастіше секрет не оновився. Перевір
  `POSTGRES_PASSWORD` у GitHub і повтори деплой. Аварійно можна повернути старий пароль:
  `\password helpbooost` у psql (крок 3.2).
- **Втрата даних** (не повинна статися: дані в `/home/deploy/helpbooost-db/data`). Відновлення з бекапу:
  ```bash
  ssh deploy@206.189.107.151 "docker exec -i helpbooost-db psql -U helpbooost -d postgres" \
    < ~/backups/simple_blog/<дата>_pg_dumpall.sql
  ```

## Після
- Записати в SAM1-30 дату, результати перевірок, що порт закрито.
- Наступні кроки SAM1-30: firewall (лише 22/80/443, SSH з твоїх IP), SSH key-only + fail2ban,
  `log_connections = on` у Postgres, щоб бачити входи.
