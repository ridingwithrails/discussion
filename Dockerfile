# Extend from Older Elixir Image
FROM elixir:1.4.5

RUN mkdir /app

# COPY mix.exs mix.exs


RUN mix local.rebar --force && \
  	mix local.hex --force && \
		mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new-1.2.5.ez
		
# Grab a pg client to ensure we can connect during installation.
RUN apt-get update && \
		apt-get install -y postgresql-client-9.6		

RUN apt-get update && \
		curl -sL https://deb.nodesource.com/setup_6.x | bash && \
		apt-get install -y nodejs && \
		apt-get install -y build-essential && \
		apt-get install -y inotify-tools

COPY . /app
WORKDIR /app

RUN	mix deps.get && \
		mix deps.compile && \
		cp mix.lock /tmp

EXPOSE 4000

RUN chmod 777 entry-point.sh
CMD ["/app/entry-point.sh"]		




