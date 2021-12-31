FROM python:3.10-alpine as builder

RUN apk update
RUN apk add build-base libxml2-dev libxslt-dev git \
	&& rm -rf /var/cache/apk/*

WORKDIR /tmp/build
RUN git clone -b v2 https://github.com/beancount/beancount

WORKDIR /tmp/build/beancount
RUN pip3 install python-dateutil bottle ply lxml python-magic beautifulsoup4
RUN python3 setup.py install

RUN pip3 install fava fava[excel]

RUN find /usr/local -name __pycache__ -exec rm -rf -v {} +

FROM python:3.10-alpine
COPY --from=builder /usr/local /usr/local

WORKDIR /data
ENV BEANCOUNT_FILE "/data/main.beancount"
ENV FAVA_OPTIONS ""

EXPOSE 5000

CMD ["fava", "--host=0.0.0.0"]
