apache2:
  pkg:
    - installed
    - pkgs:
      - apache2
      - libapache2-mod-python
  service:
    - running
    - enable: True
    - watch:
      - file: /etc/apache2/sites-available/000-default.conf

default-apache:
  file:
    - managed
    - name: /etc/apache2/sites-available/000-default.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://board/000-default.conf

board-directory:
  file:
    - directory
    - name: /var/www/html/board
    - user: www-data
    - group: www-data
    - dir_mode: 755

board-index:
  file:
    - managed
    - name: /var/www/html/board/index.py
    - user: root
    - group: root
    - mode: 644
    - source: salt://board/index.py

board-script:
  file:
    - managed
    - name: /usr/local/bin/board
    - user: root
    - group: root
    - mode: 755
    - source: salt://board/board

board-client_secret.json:
  file:
    - managed
    - name: /usr/local/share/board/client_secret.json
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - source: salt://board/client_secret.json

board.service:
  file:
    - managed
    - name: /etc/systemd/system/board.service
    - user: root
    - group: root
    - mode: 644
    - source: salt://board/board.service

board.timer:
  file:
    - managed
    - name: /etc/systemd/system/board.timer
    - user: root
    - group: root
    - mode: 644
    - source: salt://board/board.timer
  service:
    - enabled
    - running: True

board-config:
  file:
    - managed
    - name: /var/www/.config/myBoard/credentials-myboard.json
    - user: www-data
    - group: www-data
    - mode: 644
    - makedirs: True
    - source: salt://board/credentials-myboard.json

# dpkg-reconfigure locales und de_DE.UTF-8 aktivieren
board-dependencies:
  pkg:
    - installed
    - pkgs:
      - python-pip
      - python3-pip
      - python3-pil
      - fonts-liberation
      - python3-tz
      - ttf-mscorefonts-installer

googlecalendar:
  pip:
    - installed
    - name: google-api-python-client
    - bin_env: /usr/bin/pip3
    - upgrade: True
