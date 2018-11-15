# README

This is a sample project not intended for real use.

A user called admin@localhost with the password 123456 will be created when db:seed is run. This is only intended for development use.

Settings for the automated service are found config/application.rb. For testing purposes you may wish to change run_every_minutes to a smaller number:
  config.x.stock_query.run_every_minutes = 1440;

ActiveJob is used recursively to mimic a task scheduler. On an environment with cron available using a gem such as whenever is probably preferable (I was developing under Windows which doesn't have cron).

Devise has been used for authentication. If the application grows adding a authorization plugin would probably be beneficial.

Devise invite is used (which requires email), for development purposes email is pointing to mailcatcher.

Dates are displayed in US Eastern Time (EST) as this is the time zone of the stock data.