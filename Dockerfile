FROM golang:1.16 as build

ENV GO111MODULE on
ENV GOPROXY "https://goproxy.cn"

WORKDIR /opt
RUN mkdir etcdkeeper
ADD . /opt/etcdkeeper
WORKDIR /opt/etcdkeeper/src/etcdkeeper

RUN go mod tidy \
    && CGO_ENABLED=0 go build  -o main main.go
RUN chmod 755 -R /opt/etcdkeeper

FROM alpine:latest as prod

ENV HOST="0.0.0.0"
ENV PORT="8080"

# RUN apk add --no-cache ca-certificates
# 如果不使用CGO_ENABLED=0，则需要链接 libc 库
# RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

WORKDIR /opt/etcdkeeper
COPY --from=build /opt/etcdkeeper/src/etcdkeeper/main ./main
ADD assets assets

EXPOSE ${PORT}

CMD  ./main -auth