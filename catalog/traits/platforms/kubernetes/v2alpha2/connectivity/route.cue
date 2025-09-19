package connectivity

import (
	core "jacero.io/oam/core/v2alpha2"
	schema "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema"
)

#HTTPRoute: core.#Trait & {
	#metadata: #traits: HTTPRoute: core.#TraitMetaAtomic & {
		#apiVersion: "gateway.networking.k8s.io/v1"
		#kind:       "HTTPRoute"
		description: "Kubernetes HTTPRoute for HTTP and HTTPS access to services from outside the cluster"
		domain:      "connectivity"
		scope: ["component"]
		schema: {routes: [string]: schema.#RouteSpec}
	}
	routes: [string]: schema.#RouteSpec
}

#HTTPRouteMeta: #HTTPRoute.#metadata.#traits.HTTPRoute

#GRPCRoute: core.#Trait & {
	#metadata: #traits: GRPCRoute: core.#TraitMetaAtomic & {
		#apiVersion: "gateway.networking.k8s.io/v1"
		#kind:       "GRPCRoute"
		description: "Kubernetes GRPCRoute for gRPC access to services from outside the cluster"
		domain:      "connectivity"
		scope: ["component"]
		schema: {routes: [string]: schema.#RouteSpec}
	}
	routes: [string]: schema.#RouteSpec
}

#GRPCRouteMeta: #GRPCRoute.#metadata.#traits.GRPCRoute
