# Build the Go Binary.
FROM golang:1.18 as build_metrics
ENV CGO_ENABLED 0
ARG BUILD_REF

# Create the service directory and the copy the module files first and then
# download the dependencies. If this doesn't change, we won't need to do this
# again in future builds.
# RUN mkdir /third
# COPY go.* /third/
# WORKDIR /third
# RUN go mod download

# Copy the source code into the container.
COPY . /third

# Build the service binary. We are doing this last since this will be different
# every time we run through this process.
WORKDIR /third/app/services/metrics
RUN go build -ldflags "-X main.build=${BUILD_REF}"


# Run the Go Binary in Alpine.
FROM alpine:3.15
ARG BUILD_DATE
ARG BUILD_REF
RUN addgroup -g 1000 -S metrics && \
    adduser -u 1000 -h /third -G metrics -S metrics
COPY --from=build_metrics --chown=metrics:metrics /third/app/services/metrics/metrics /third/metrics
WORKDIR /third
USER metrics
CMD ["./metrics"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
	  org.opencontainers.image.title="metrics" \
	  org.opencontainers.image.authors="Dmitry Ovchinnikov <dmitry.v.ovchinnikov@gmail.com>" \
	  org.opencontainers.image.source="https://github.com/dmitryovchinnikov/third/app/services/metrics" \
	  org.opencontainers.image.revision="${BUILD_REF}" \
	  org.opencontainers.image.vendor="Dmitry Ovchinnikov"
