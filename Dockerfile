FROM golang:1.19.3 as builder

ARG PACKAGE=eventindexer

RUN apt install git curl

RUN mkdir /mxc-mono

WORKDIR /mxc-mono

COPY . .

RUN go mod download

WORKDIR /mxc-mono/packages/$PACKAGE

RUN CGO_ENABLED=0 GOOS=linux go build -o /mxc-mono/packages/$PACKAGE/bin/${PACKAGE} /mxc-mono/packages/$PACKAGE/cmd/main.go

FROM alpine:latest

ARG PACKAGE

RUN apk add --no-cache ca-certificates

COPY --from=builder /mxc-mono/packages/$PACKAGE/bin/$PACKAGE /usr/local/bin/

ENTRYPOINT ["$PACKAGE"]