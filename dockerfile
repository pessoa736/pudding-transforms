FROM nickblah/lua:5.4.7-luarocks-debian

ARG user=Davi
ARG uid=1000

WORKDIR /app

COPY . .

RUN useradd -G www-data,root -u $uid -d /home/$user $user


RUN apt-get update && apt-get install -y

RUN chown -R $user:$user /app

USER $user



