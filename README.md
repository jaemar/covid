# Covid Cases Observation List

 Tools
- Ruby
	- puma
	- sinatra
	- activerecord
	- pg
	- rake
- PostgreSQL

Copy **config/database.yml.example** to **config/database.yml** and change postgresql _username_ and _password_ in config/database.yml
Copy
```bash
$ cp config/database.yml.example config/database.yml 
```
Change **_<your_username>_** & **_<your_password>_**
```
development:
  adapter: postgresql
  encoding: unicode
  host: localhost
  database: covid
  username: <your_username>
  password: <your_password>
```

Run each command in a terminal
```bash
$ bundle install
$ rake db:create
$ rake db:migrate
$ rackup config.ru
```
