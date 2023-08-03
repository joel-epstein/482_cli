package globals

import (
	gsl "greymatter.io/gsl/v1"
)

globals: gsl.#DefaultContext & {
	edge_host: "4.157.204.30:10809"
	namespace: "blahblah"
	
	// Please contact your mesh administrators as to what
	// values must be set per your mesh deployment.
	mesh: {
		name: string
	}
}
