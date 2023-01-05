# Build the Go Binary
FROM golang:1.17 as build_third
ENV CGO_ENABLED 0
ARG BUILD_REF

# Copy the source code into the container.
COPY . /third

# Build the service binary.
WORKDIR /third
RUN go build -ldflags "-X main.build=${BUILD_REF}"

# Run the Go Binary in Alpine.
FROM alpine:3.15
ARG BUILD_DATE
ARG BUILD_REF
COPY --from=build_third /third/third /third/third
WORKDIR /third
CMD ["./third"]

LABEL org.opencontainers.image.created="${BUILD_DATE}" \
	  org.opencontainers.image.title="third" \
	  org.opencontainers.image.authors="Dmitry Ovchinnikov <dmitry.v.ovchinnikov@gmail.com>" \
	  org.opencontainers.image.source="https://github.com/dmitryovchinnikov/third" \
	  org.opencontainers.image.revision="${BUILD_REF}" \
	  org.opencontainers.image.vendor="Dmitry Ovchinnikov"
