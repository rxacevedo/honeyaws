# Source: https://levelup.gitconnected.com/complete-guide-to-create-docker-container-for-your-golang-application-80f3fb59a15e
FROM golang:1.15.6-alpine AS builder

RUN apk add -U --no-cache ca-certificates

# Set necessary environmet variables needed for our image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the code into the container
COPY . .

# Build the application
RUN go build -o honeyalb ./cmd/honeyalb/.

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/honeyalb .

# Build a small image
FROM scratch

COPY --from=builder /dist/honeyalb /tmp/honeyalb
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Command to run
ENTRYPOINT ["/tmp/honeyalb","ingest"]
