# homelab-site

Учебный DevOps-проект: сайт-визитка на собственном Linux-сервере.
Довожу его от ручной настройки до автоматического деплоя, мониторинга и бэкапов.

Я системный администратор (Windows Server, Hyper-V, Exchange, 1С, MySQL, Zabbix, Asterisk)
и перехожу в DevOps. Здесь переношу админский опыт в код.

## Архитектура

```
Браузер ──HTTPS:443──▶ nginx на хосте (TLS, редирект 80→443, логи)
                            │ proxy_pass
                            ▼
                 127.0.0.1:8080 ── Docker: nginx:alpine (статика сайта)
```

## Стек

Ubuntu Server 26.04 · nginx · Docker / Docker Compose · Bash · Git / GitHub · ufw · fail2ban · OpenSSH

## Что сделано и что дальше

- [x] Сервер: SSH только по ключам, ufw, fail2ban (вручную, будет перенесено в Ansible)
- [x] nginx: HTTPS с самоподписанным сертификатом, редирект 80→443
- [x] `deploy.sh`: выкладка одной командой
- [x] `scripts/log_report.sh`: статистика по логам nginx за день
- [x] Сайт в Docker-контейнере: healthcheck, порт только на localhost
- [ ] Хостовый nginx как reverse proxy в контейнер
- [ ] CI: GitHub Actions (shellcheck, hadolint, сборка образа)
- [ ] CD: автодеплой через self-hosted runner
- [ ] Ansible: сервер с нуля одним playbook
- [ ] Мониторинг: Uptime Kuma, Prometheus + Grafana
- [ ] Бэкапы с проверкой восстановления
- [ ] Ежедневный отчёт в Telegram

## Структура

```
.
├── Dockerfile          # образ сайта
├── compose.yaml        # запуск контейнера
├── .dockerignore       # что не попадает в образ
├── deploy.sh           # выкладка на сервер
├── nginx/
│   ├── homelab.conf    # nginx на хосте: HTTPS, редирект, логи
│   └── site.conf       # nginx внутри контейнера
├── scripts/
│   └── log_report.sh   # отчёт по логам
└── site/
    └── index.html
```

## Как запустить

```
git clone git@github.com:pavelkuzin01-alt/homelab-site.git
cd homelab-site
docker compose up -d --build
docker compose ps                 # статус healthy
curl -I http://127.0.0.1:8080     # HTTP/1.1 200 OK
```

## Почему сделано так

- **Порт контейнера только на `127.0.0.1`.** Docker сам пишет правила iptables, и опубликованный порт обходит ufw. Снаружи сайт доступен только через nginx на хосте.
- **HTTPS на хосте, а не в контейнере.** Сертификат в одном месте, контейнер остаётся простым и одинаковым в любом окружении.
- **Версия образа закреплена (`nginx:1.27-alpine`), а не `latest`.** Сборка через месяц даст тот же результат.
- **Healthcheck.** «Контейнер запущен» и «сайт отвечает» это разные вещи.
- **Секреты не в репозитории.** Ключи, сертификаты и `*.env` в `.gitignore`, в репозитории только примеры.

