FROM golang:alpine as builder
RUN apk update && apk add git && apk add ca-certificates
COPY *.go $GOPATH/src/mypackage/myapp/
WORKDIR $GOPATH/src/mypackage/myapp/
RUN go mod init && go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/docker_state_exporter

FROM alpine:3
COPY --from=builder /go/bin/docker_state_exporter /go/bin/docker_state_exporter
COPY awall/optional /etc/awall/optional
COPY start.sh /
RUN apk update && \
    apk add --no-cache ip6tables iptables && \
    apk add --no-cache -u awall && \
    awall enable main && \
    chmod +x+x+x /start.sh
EXPOSE 8080
CMD ["/entrypoint.sh"]
