package v2alpha2

import (
	// 1. Workload - Application runtime and execution models
	workload "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/workload"

	// 2. Data - State management, configuration, and persistence  
	data "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/data"

	// 3. Connectivity - Networking, service discovery, and integration
	connectivity "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/connectivity"

	// 4. Security - Protection, authentication, and authorization
	security "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/security"

	// 5. Observability - Monitoring, logging, tracing, and visibility
	observability "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/observability"

	// 6. Governance - Policies, constraints, and compliance
	// governance "jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/governance"
)

// Kubernetes Atomic Traits Catalog
// This file provides a comprehensive collection of atomic traits for Kubernetes resources

//////////////////////////////////////////////
// Workload Domain Traits
//////////////////////////////////////////////

// Kubernetes Deployment for stateless workloads with rolling updates
#Deployment: workload.#Deployment

// Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage
#StatefulSet: workload.#StatefulSet

// Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod
#DaemonSet: workload.#DaemonSet

// Kubernetes Job for running batch or one-time tasks
#Job: workload.#Job

// Kubernetes CronJob for running jobs on a scheduled basis
#CronJob: workload.#CronJob

// Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics
#HorizontalPodAutoscaler: workload.#HorizontalPodAutoscaler

// Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage
#VerticalPodAutoscaler: workload.#VerticalPodAutoscaler

//////////////////////////////////////////////
// Data Domain Traits
//////////////////////////////////////////////

// Kubernetes ConfigMap for storing configuration data as key-value pairs
#ConfigMap: data.#ConfigMap

// Kubernetes Secret for storing sensitive configuration data
#Secret: data.#Secret

// Kubernetes PersistentVolumeClaim for requesting persistent storage
#PersistentVolumeClaim: data.#PersistentVolumeClaim

// Kubernetes StorageClass for defining classes of storage
#StorageClass: data.#StorageClass

//////////////////////////////////////////////
// Connectivity Domain Traits
//////////////////////////////////////////////

// Kubernetes Service for exposing an application running on a set of Pods as a network service
#Service: connectivity.#Service

// Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster
#Ingress: connectivity.#Ingress

// Kubernetes NetworkPolicy for controlling network traffic to and from pods
#NetworkPolicy: connectivity.#NetworkPolicy

//////////////////////////////////////////////
// Security Domain Traits
//////////////////////////////////////////////

// Kubernetes ServiceAccount provides an identity for processes that run in a Pod
#ServiceAccount:  security.#ServiceAccount
#ServiceAccounts: security.#ServiceAccounts

// Kubernetes Role contains rules that represent a set of permissions within a namespace
#Role:  security.#Role
#Roles: security.#Roles

// Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users
#RoleBinding:  security.#RoleBinding
#RoleBindings: security.#RoleBindings

// Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level
#ClusterRole:  security.#ClusterRole
#ClusterRoles: security.#ClusterRoles

// Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide
#ClusterRoleBinding: security.#ClusterRoleBinding

#ClusterRoleBindings: security.#ClusterRoleBindings

//////////////////////////////////////////////
// Observability Domain Traits
//////////////////////////////////////////////

// Prometheus ServiceMonitor for scraping metrics from services
#ServiceMonitor: observability.#ServiceMonitor

// Prometheus PodMonitor for scraping metrics directly from pods
#PodMonitor: observability.#PodMonitor

//////////////////////////////////////////////
// Governance Domain Traits
//////////////////////////////////////////////

// (Governance traits to be implemented)
// #ResourceQuota: governance.#ResourceQuota
// #PriorityClass: governance.#PriorityClass
// #PodDisruptionBudget: governance.#PodDisruptionBudget
