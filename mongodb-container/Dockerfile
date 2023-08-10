FROM mongo:6.0.8

LABEL maintainer="Gan Cheng Kuan <chengkuan@gmail.com>"
LABEL desc="MongoDB for Debezium demo"
LABEL github="https://github.com/chengkuangan"
LABEL blog="https://braindose.blog"

COPY --chown=1000:1000 ./startmongod.sh /usr/bin/startmongod.sh

CMD startmongod.sh