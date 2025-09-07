package examples

// import (
// 	"strings"
// 	"list"
// )

// ===================================================================
// APPLICATION-LEVEL SCOPE TRAITS
// These traits apply to groups of components within an application
// ===================================================================

// Network Isolation Scope - manages network boundaries and policies
#NetworkIsolationScope: #Trait & {
	#metadata: #traits: NetworkIsolationScope: {
		category: "structural"
		traitScope: ["scope"]
		provides: {
			network: #NetworkIsolationScope.network
		}
		requires: [
			"core.oam.dev/v1.NetworkPolicy",
			"istio.io/v1.VirtualService",
		]
	}

	network: {
		isolation: "none" | "namespace" | "pod" | "strict" | *"namespace"
		components: [...string]

		policies: [...{
			type: "ingress" | "egress"
			from?: [...{
				namespaceSelector?: {...}
				podSelector?: {...}
				ipBlock?: {cidr: string}
			}]
			to?: [...{
				namespaceSelector?: {...}
				podSelector?: {...}
				ipBlock?: {cidr: string}
			}]
			ports?: [...{
				protocol: "TCP" | "UDP" | "SCTP"
				port:     int | string
			}]
		}]

		serviceMesh?: {
			enabled: bool | *false
			profile: "strict" | "permissive" | *"permissive"
			mTLS:    bool | *true
			trafficPolicy?: {
				connectionPool?: {...}
				outlierDetection?: {...}
				loadBalancer?: "ROUND_ROBIN" | "LEAST_REQUEST" | "RANDOM"
			}
		}
	}
}

// Performance Optimization Scope - manages performance tuning across components
#PerformanceScope: #Trait & {
	#metadata: #traits: PerformanceScope: {
		category: "operational"
		traitScope: ["scope"]
		provides: {
			performance: #PerformanceScope.performance
		}
		requires: [
			"autoscaling/v2.HorizontalPodAutoscaler",
			"caching.dev/v1.RedisCache",
		]
	}

	performance: {
		components: [...string]

		autoscaling?: {
			enabled:     bool | *true
			minReplicas: int | *2
			maxReplicas: int | *10
			metrics: [...{
				type:        "cpu" | "memory" | "custom"
				target:      int
				targetType?: "utilization" | "value" | "averageValue"
			}]
			behavior?: {
				scaleUp?: {
					stabilizationWindowSeconds?: int
					policies?: [...{...}]
				}
				scaleDown?: {
					stabilizationWindowSeconds?: int
					policies?: [...{...}]
				}
			}
		}

		caching?: {
			strategy:        "local" | "distributed" | "hybrid"
			provider?:       "redis" | "memcached" | "hazelcast"
			ttl?:            string | *"1h"
			evictionPolicy?: "LRU" | "LFU" | "FIFO"
			size?:           string
		}

		optimization?: {
			connectionPooling?: {
				enabled:            bool | *true
				maxConnections?:    int | *100
				connectionTimeout?: string | *"30s"
			}
			requestBuffering?: {
				enabled:  bool | *false
				maxSize?: string | *"10Mi"
			}
			compression?: {
				enabled: bool | *true
				types?: [...string] | *["gzip", "br"]
			}
		}
	}
}

// Observability Scope - unified logging, metrics, and tracing
#ObservabilityScope: #Trait & {
	#metadata: #traits: ObservabilityScope: {
		category: "operational"
		traitScope: ["scope"]
		provides: {
			observability: #ObservabilityScope.observability
		}
		requires: [
			"monitoring.coreos.com/v1.ServiceMonitor",
			"opentelemetry.io/v1alpha1.OpenTelemetryCollector",
		]
	}

	observability: {
		components: [...string]

		logging?: {
			enabled: bool | *true
			level:   "debug" | "info" | "warn" | "error" | *"info"
			format:  "json" | "text" | *"json"
			sampling?: {
				enabled: bool | *false
				rate?:   float | *0.1
			}
			destinations?: [...{
				type:      "stdout" | "file" | "syslog" | "elasticsearch" | "loki"
				endpoint?: string
				index?:    string
			}]
			enrichment?: {
				addTraceId:  bool | *true
				addHostname: bool | *true
				addPodInfo:  bool | *true
			}
		}

		metrics?: {
			enabled:    bool | *true
			interval?:  string | *"30s"
			retention?: string | *"15d"
			endpoints?: [...{
				path: string | *"/metrics"
				port: int | *9090
			}]
			customMetrics?: [...{
				name: string
				type: "counter" | "gauge" | "histogram" | "summary"
				labels?: [...string]
			}]
		}

		tracing?: {
			enabled: bool | *true
			sampler?: {
				type:   "always" | "never" | "probabilistic" | "adaptive"
				param?: float | *0.1
			}
			propagation?: "w3c" | "jaeger" | "b3" | *"w3c"
			exporter?: {
				type:      "jaeger" | "zipkin" | "otlp"
				endpoint:  string
				insecure?: bool | *false
			}
		}
	}
}

// Data Protection Scope - manages data encryption, backup, and recovery
#DataProtectionScope: #Trait & {
	#metadata: #traits: DataProtectionScope: {
		category: "contractual"
		traitScope: ["scope"]
		provides: {
			dataProtection: #DataProtectionScope.dataProtection
		}
		requires: [
			"cert-manager.io/v1.Certificate",
			"velero.io/v1.Backup",
		]
	}

	dataProtection: {
		components: [...string]

		encryption?: {
			atRest: {
				enabled:    bool | *true
				provider:   "native" | "vault" | "kms" | *"native"
				algorithm?: "AES256" | "AES128" | *"AES256"
				keyRotation?: {
					enabled:   bool | *true
					frequency: string | *"90d"
				}
			}
			inTransit: {
				enabled:        bool | *true
				minTLSVersion?: "1.2" | "1.3" | *"1.2"
				cipherSuites?: [...string]
			}
		}

		backup?: {
			enabled:   bool | *true
			schedule?: string | *"0 2 * * *" // Daily at 2 AM
			retention?: {
				daily?:   int | *7
				weekly?:  int | *4
				monthly?: int | *6
				yearly?:  int | *1
			}
			storage?: {
				type:            "s3" | "gcs" | "azure" | "local"
				bucket?:         string
				region?:         string
				encryptBackups?: bool | *true
			}
			hooks?: {
				pre?: [...string]
				post?: [...string]
			}
		}

		retention?: {
			dataClassification: "public" | "internal" | "confidential" | "restricted"
			retentionPeriod:    string
			deletionPolicy:     "soft" | "hard" | "archive"
			auditLog?: {
				enabled:   bool | *true
				retention: string | *"7y"
			}
		}
	}
}

// Resilience Scope - manages fault tolerance and recovery
#ResilienceScope: #Trait & {
	#metadata: #traits: ResilienceScope: {
		category: "operational"
		traitScope: ["scope"]
		provides: {
			resilience: #ResilienceScope.resilience
		}
		requires: [
			"resilience.io/v1.CircuitBreaker",
			"chaos-mesh.org/v1alpha1.NetworkChaos",
		]
	}

	resilience: {
		components: [...string]

		circuitBreaker?: {
			enabled:          bool | *true
			threshold:        int | *5
			interval:         string | *"30s"
			timeout:          string | *"60s"
			halfOpenRequests: int | *3
			onOpen?: {
				fallback?: "error" | "cache" | "default"
				notifyEndpoints?: [...string]
			}
		}

		retry?: {
			enabled:     bool | *true
			maxAttempts: int | *3
			backoff: {
				type:         "fixed" | "exponential" | "random"
				initialDelay: string | *"1s"
				maxDelay?:    string | *"30s"
				multiplier?:  float | *2.0
			}
			retryOn?: [...string] | *["5xx", "reset", "connect-failure"]
		}

		timeout?: {
			request:    string | *"30s"
			idle?:      string | *"60s"
			keepAlive?: string | *"120s"
		}

		bulkhead?: {
			enabled:       bool | *false
			maxConcurrent: int | *10
			maxWaiting?:   int | *10
			timeout?:      string | *"10s"
		}

		chaosEngineering?: {
			enabled: bool | *false
			experiments?: [...{
				type:      "network-delay" | "network-loss" | "pod-kill"
				schedule?: string
				duration?: string
				target?: {
					percentage?: int
					selector?: {...}
				}
			}]
		}
	}
}

// ===================================================================
// BUNDLE-LEVEL SCOPE TRAITS
// These traits apply at the bundle distribution level
// ===================================================================

// Multi-Tenancy Scope - manages tenant isolation and resource allocation
#MultiTenancyScope: #Trait & {
	#metadata: #traits: MultiTenancyScope: {
		category: "structural"
		traitScope: ["bundle"]
		provides: {
			multiTenancy: #MultiTenancyScope.multiTenancy
		}
		requires: [
			"tenancy.io/v1.Tenant",
			"quotas.io/v1.ResourceQuota",
		]
	}

	multiTenancy: {
		isolation: {
			type:          "namespace" | "cluster" | "virtual-cluster"
			networkPolicy: "strict" | "relaxed" | *"strict"
			rbac: {
				enabled: bool | *true
				model:   "flat" | "hierarchical" | *"hierarchical"
			}
		}

		tenants?: [...{
			id:   string
			name: string
			tier: "free" | "standard" | "premium" | "enterprise"
			quotas?: {
				cpu?:       string
				memory?:    string
				storage?:   string
				bandwidth?: string
			}
			features?: [...string]
			customDomain?: string
		}]

		quotas?: {
			enforcement: "soft" | "hard" | *"soft"
			notifications?: {
				thresholds?: [...int] | *[80, 90, 95]
				endpoints?: [...string]
			}
		}

		billing?: {
			enabled: bool | *false
			model:   "flat" | "usage" | "tiered"
			metering?: [...{
				resource: string
				unit:     string
				rate?:    float
			}]
		}
	}
}

// Geographic Distribution Scope - manages multi-region deployment
#GeographicScope: #Trait & {
	#metadata: #traits: GeographicScope: {
		category: "structural"
		traitScope: ["bundle"]
		provides: {
			geographic: #GeographicScope.geographic
		}
		requires: [
			"federation.io/v1.FederatedDeployment",
			"dns.io/v1.GeoDNS",
		]
	}

	geographic: {
		regions: [...{
			name:     string
			code:     string
			primary?: bool | *false
			endpoints?: [...string]
			capacity?: {
				weight?:  int | *100
				maxLoad?: int
			}
		}]

		routing?: {
			strategy: "latency" | "geographic" | "weighted" | "failover"
			healthChecks?: {
				enabled:             bool | *true
				interval?:           string | *"30s"
				timeout?:            string | *"5s"
				unhealthyThreshold?: int | *3
			}
			failover?: {
				automatic:        bool | *true
				gracePeriod?:     string | *"30s"
				preserveSession?: bool | *true
			}
		}

		dataLocality?: {
			enabled: bool | *false
			rules?: [...{
				region: string
				dataTypes?: [...string]
				enforcement: "strict" | "preferred"
			}]
		}

		compliance?: {
			gdpr?:          bool | *false
			dataResidency?: bool | *false
			sovereignClouds?: [...string]
		}
	}
}

// Release Management Scope - manages deployment strategies and rollouts
#ReleaseManagementScope: #Trait & {
	#metadata: #traits: ReleaseManagementScope: {
		category: "operational"
		traitScope: ["bundle"]
		provides: {
			release: #ReleaseManagementScope.release
		}
		requires: [
			"flagger.app/v1beta1.Canary",
			"argoproj.io/v1alpha1.Rollout",
		]
	}

	release: {
		strategy: {
			type: "rolling" | "canary" | "blue-green" | "feature-flag"

			rolling?: {
				maxSurge?:       string | int | *"25%"
				maxUnavailable?: string | int | *"25%"
				pauseDuration?:  string
			}

			canary?: {
				steps?: [...{
					weight:    int
					duration?: string
					analysis?: {...}
				}]
				trafficSplit?: {
					header?:   string
					cookie?:   string
					sourceIP?: bool
				}
			}

			blueGreen?: {
				prePromotionAnalysis?: {...}
				postPromotionAnalysis?: {...}
				scaleDownDelay?: string | *"30s"
				autoPromote?:    bool | *false
			}

			featureFlags?: {
				provider:        "launchdarkly" | "flagsmith" | "unleash"
				defaultBehavior: "on" | "off" | *"off"
			}
		}

		validation?: {
			preDeployment?: [...{
				type:      "smoke" | "integration" | "contract"
				timeout?:  string | *"5m"
				required?: bool | *true
			}]
			postDeployment?: [...{
				type:      "e2e" | "performance" | "security"
				timeout?:  string | *"15m"
				required?: bool | *false
			}]
			healthChecks?: {
				liveness?: {...}
				readiness?: {...}
				startup?: {...}
			}
		}

		rollback?: {
			automatic: bool | *true
			triggers?: [...{
				metric:    string
				threshold: float
				duration?: string
			}]
			maxHistory?: int | *10
			notifications?: [...{
				type:     "email" | "slack" | "webhook"
				endpoint: string
			}]
		}
	}
}

// Licensing Scope - manages software licensing and entitlements
#LicensingScope: #Trait & {
	#metadata: #traits: LicensingScope: {
		category: "contractual"
		traitScope: ["bundle"]
		provides: {
			licensing: #LicensingScope.licensing
		}
		requires: [
			"licensing.io/v1.License",
			"entitlements.io/v1.Entitlement",
		]
	}

	licensing: {
		model: "perpetual" | "subscription" | "usage" | "freemium" | "open-source"

		terms?: {
			duration?: string
			seats?:    int
			cores?:    int
			nodes?:    int
		}

		enforcement?: {
			type:           "soft" | "hard" | "grace-period"
			gracePeriod?:   string | *"30d"
			checkInterval?: string | *"24h"
			offlineMode?: {
				enabled:      bool | *true
				maxDuration?: string | *"7d"
			}
		}

		entitlements?: [...{
			feature: string
			enabled: bool
			limit?:  int | string
			expiry?: string
		}]

		compliance?: {
			auditLog: bool | *true
			reporting?: {
				frequency: "daily" | "weekly" | "monthly"
				endpoints?: [...string]
			}
			telemetry?: {
				enabled:    bool | *false
				anonymous?: bool | *true
			}
		}
	}
}

// Cost Optimization Scope - manages cost allocation and optimization
#CostOptimizationScope: #Trait & {
	#metadata: #traits: CostOptimizationScope: {
		category: "resource"
		traitScope: ["bundle", "scope"]
		provides: {
			costOptimization: #CostOptimizationScope.costOptimization
		}
		requires: [
			"finops.io/v1.Budget",
			"autoscaling.io/v1.Recommender",
		]
	}

	costOptimization: {
		budgets?: {
			monthly?: float
			alerts?: [...{
				threshold: int // percentage
				action:    "notify" | "throttle" | "suspend"
				recipients?: [...string]
			}]
			allocation?: {
				model: "proportional" | "priority" | "fixed"
				tags?: [...{
					key:         string
					value:       string
					percentage?: float
				}]
			}
		}

		rightSizing?: {
			enabled:            bool | *true
			analysisFrequency?: string | *"weekly"
			recommendations?: {
				cpu?: {
					targetUtilization?: int | *70
					bufferPercentage?:  int | *20
				}
				memory?: {
					targetUtilization?: int | *80
					bufferPercentage?:  int | *15
				}
				autoApply?: bool | *false
			}
		}

		spotInstances?: {
			enabled:             bool | *false
			maxPercentage?:      int | *50
			fallbackToOnDemand?: bool | *true
			diversification?: {
				enabled: bool | *true
				instanceTypes?: [...string]
				zones?: [...string]
			}
		}

		reserved?: {
			enabled:       bool | *false
			term:          "1-year" | "3-year"
			paymentOption: "all-upfront" | "partial-upfront" | "no-upfront"
			coverage?:     int | *70 // percentage
		}

		optimization?: {
			unusedResources?: {
				detectOrphaned: bool | *true
				autoCleanup?:   bool | *false
				retention?:     string | *"7d"
			}
			scheduling?: {
				nonProdShutdown?: {
					enabled:   bool | *false
					schedule?: string // cron expression
					excludeTags?: [...string]
				}
			}
		}
	}
}

// ===================================================================
// COMPOSED SCOPE TRAITS
// These combine multiple atomic traits for complex scenarios
// ===================================================================

// Production Readiness Scope - combines multiple operational concerns
#ProductionReadinessScope: #Trait & {
	#metadata: #traits: ProductionReadinessScope: {
		category: "operational"
		traitScope: ["scope", "bundle"]
		composes: [
			#ObservabilityScope.#metadata.#traits.ObservabilityScope,
			#ResilienceScope.#metadata.#traits.ResilienceScope,
			#PerformanceScope.#metadata.#traits.PerformanceScope,
		]
		provides: {
			productionReadiness: #ProductionReadinessScope.productionReadiness
		}
	}

	productionReadiness: {
		components: [...string]

		sla?: {
			availability: "99%" | "99.9%" | "99.99%" | "99.999%"
			responseTime?: {
				p50?: string
				p95?: string
				p99?: string
			}
			errorRate?: float
		}

		// Delegated to composed traits
		monitoring:  #ObservabilityScope.observability
		resilience:  #ResilienceScope.resilience
		performance: #PerformanceScope.performance
	}
}

// Secure Multi-Tenant Scope - combines security and multi-tenancy
#SecureMultiTenantScope: #Trait & {
	#metadata: #traits: SecureMultiTenantScope: {
		category: "structural"
		traitScope: ["bundle"]
		composes: [
			#MultiTenancyScope.#metadata.#traits.MultiTenancyScope,
			#DataProtectionScope.#metadata.#traits.DataProtectionScope,
			#NetworkIsolationScope.#metadata.#traits.NetworkIsolationScope,
		]
		provides: {
			secureMultiTenancy: #SecureMultiTenantScope.secureMultiTenancy
		}
	}

	secureMultiTenancy: {
		// Composed from underlying traits
		tenants: #MultiTenancyScope.multiTenancy.tenants
		isolation: {
			network: #NetworkIsolationScope.network
			tenant:  #MultiTenancyScope.multiTenancy.isolation
		}
		dataProtection: #DataProtectionScope.dataProtection

		// Additional security policies
		additionalPolicies?: {
			crossTenantAccess: "forbidden" | "audit-only" | "permitted"
			dataSegregation:   "logical" | "physical"
			complianceMode?:   "strict" | "standard"
		}
	}
}
