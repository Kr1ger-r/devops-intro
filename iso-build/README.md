# 💽 Custom RAM Live ISO Ubuntu 20.04

Полное руководство и скрипт для сборки кастомного RAM-загружаемого ISO-образа Ubuntu 20.04 с:

- ✅ cloud-init и автоматической установкой (`autoinstall`)
- 🐳 Docker и NVIDIA 570-драйверами
- 💾 Загрузкой в оперативную память (`toram`)
- 🔒 Отключением `nouveau` (open-source драйвера NVIDIA)
- 🧠 Поддержкой cloud-init через `nocloud` или `cidata.iso`
- 🔁 Гибридной загрузкой (BIOS и UEFI)

---

## ⚙️ Минимальные требования

- Ubuntu 20.04 / 22.04 (или WSL2)
- `xorriso`, `squashfs-tools`, `genisoimage`, `rsync`, `unsquashfs`, `isolinux`

---

## 📂 Состав репозитория

| Файл/директория       | Назначение                             |
|-----------------------|-----------------------------------------|
| `ram-build.sh`        | Основной bash-скрипт сборки ISO         |
| `user-data`, `meta-data` | Конфигурация cloud-init (NoCloud)       |
| `loopback.cfg`, `grub.cfg` | Конфигурация GRUB/ISOLINUX для ISO   |
| `cidata.zip` (опц.)   | Архив с cloud-init конфигурацией       |
| `README.md`           | Это руководство                        |

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/yourusername/custom-ram-iso.git
cd custom-ram-iso

chmod +x ram-build.sh
./ram-build.sh
```

Готовый ISO будет создан как `custom-ram-live.iso`.

---

## 💡 Как применить cloud-init

### 🅰 Вариант 1 — Папка `nocloud` в ISO

- Поместите `user-data` и `meta-data` в `extract-cd/nocloud/`
- В `grub.cfg` и `loopback.cfg` добавьте:

  ```
  ds=nocloud;s=/cdrom/nocloud/
  ```

### 🅱 Вариант 2 — Отдельный `cidata.iso`

- Сгенерируйте:

  ```bash
  genisoimage -output cidata.iso -volid cidata -joliet -rock user-data meta-data
  ```

- Используйте второй раздел флешки или Ventoy
- В параметрах ядра:

  ```
  ds=nocloud;s=/cdrom/
  ```

---

## 🔧 GRUB конфигурация (пример)

```cfg
linux /casper/vmlinuz boot=casper toram fsck.mode=skip integrity-check=0 \
      autoinstall ds=nocloud;s=/cdrom/nocloud/ \
      modprobe.blacklist=nouveau nouveau.modeset=0 quiet ---
initrd /casper/initrd
```

---

## 📦 Что включено в `user-data`

- Пользователь: `custom`, пароль: `youpass`
- Docker + rc.local автозапуск
- NVIDIA 570 + fabricmanager + datacenter GPU manager
- Автоматическое включение sudo, cloud-init и SSH

---

## 🛠 Авторы

- 💻 Поддержка и сборка: [yourusername]
- 📄 Руководство, примеры cloud-init и GRUB
