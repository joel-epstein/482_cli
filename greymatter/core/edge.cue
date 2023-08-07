// Edge configuration for enterprise mesh-segmentation. This is a dedicated
// edge proxy that provides north/south network traffic to services in this
// repository in the mesh. This edge would be separate from the default
// greymatter edge that is deployed via enterprise-level configuration in
// the gitops-core git repository.
package blahblah

import (
	gsl "greymatter.io/gsl/v1"

	"blahblah.module/greymatter:globals"
)

// global name for remote_jwks clusters
let remote_jwks_upstream = "remote_jwks"

Edge: gsl.#Edge & {
	// A context provides global information from globals.cue
	// to your service definitions.
	context: Edge.#NewContext & globals

	name:              "edge"
	display_name:      "Blahblah Edge"
	version:           "v1.8.1"
	description:       "Edge ingress for blahblah"
	business_impact:   "high"
	owner:             "Blahblah"
	capability:        ""

	raw_upstreams: {
		(remote_jwks_upstream): {
			gsl.#Upstream
			gsl.#TLSUpstream & {
				ssl_config: {
					cert_key_pairs: [
						{
							certificate_path: "/etc/proxy/tls/iam2/server.crt"
							key_path:         "/etc/proxy/tls/iam2/server.key"
						},
					]
				}
			}
			instances: [
				{
				    host: "iam2.greymatter.io"
				    port: 443
				}
			]
		}
    }
	
	ingress: {
		// Edge -> HTTP ingress to your container
		(name): {
			gsl.#HTTPListener
			port: 10809
			filters: [
				gsl.#OIDCPipelineFilter & {
					#options: {
						provider_host: "https://iam2.greymatter.io"
						clientId:      "greymatter"
						// clientSecret:  "8Fg2f1zA0Ali3Q998Eks0v3j9I4cD8wD"
						serviceUrl:    "http://20.242.228.143:10809"
						realm:         "GAT"
						provider_cluster: remote_jwks_upstream
					}
					#secrets: {
						client_secret: gsl.#KubernetesSecret & {
						namespace: globals.globals.namespace
						name:      "a-secret"
						key:       "client-secret"
						}
					}
				},
			]
		}
	}
}

exports: "edge-blahblah": Edge
