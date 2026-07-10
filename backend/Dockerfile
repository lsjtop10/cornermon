# --- Stage 1: Build binary ---
FROM golang:1.26-alpine AS builder

WORKDIR /app

# Install system dependencies
RUN apk add --no-cache ca-certificates tzdata

# Install Go dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build minimized statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build \
    -ldflags="-w -s" \
    -a -installsuffix cgo \
    -o server ./cmd/server/main.go

# --- Stage 2: Runtime image ---
FROM alpine:latest

# Import ca-certificates and tzdata from builder
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo

WORKDIR /app

# Copy the binary and docs from builder
COPY --from=builder /app/server .
COPY --from=builder /app/docs /app/docs

# Create non-root user for security compliance
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
RUN chown -R appuser:appgroup /app

# Run as non-root user
USER appuser

# Expose server port
EXPOSE 8080

# Run executable
CMD ["./server"]
