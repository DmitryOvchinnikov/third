package mid

import (
	"context"
	"net/http"
	"time"

	"github.com/dmitryovchinnikov/third/foundation/web"
	"go.uber.org/zap"
)

// Logger ...
func Logger(log *zap.SugaredLogger) web.Middleware {

	// This is the actual middleware function to be executed.
	m := func(handler web.Handler) web.Handler {

		// Create the handler that will be attached in the middleware chain.
		h := func(ctx context.Context, w http.ResponseWriter, r *http.Request) error {

			traceID := "00000000-0000-0000-0000-000000000000"
			statusCode := http.StatusOK
			now := time.Now()

			log.Infow("request started", "traceid", traceID, "method", r.Method, "path", r.URL.Path, "remoteaddr", r.RemoteAddr)

			// Call the next handler.
			err := handler(ctx, w, r)

			log.Infow("request completed", "traceid", traceID, "method", r.Method, "path", r.URL.Path, "remoteaddr", r.RemoteAddr, "statuscode", statusCode, "since", now)

			// Return the error, so it can be handled further up the chain.
			return err
		}

		return h
	}

	return m
}
