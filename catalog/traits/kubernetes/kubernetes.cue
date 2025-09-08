package kubernetes

import (
	// Workload traits
	"jacero.io/oam/catalog/traits/kubernetes/workload"
	
	// Networking traits  
	"jacero.io/oam/catalog/traits/kubernetes/networking"
	
	// Storage traits
	"jacero.io/oam/catalog/traits/kubernetes/storage"
	
	// Configuration traits
	"jacero.io/oam/catalog/traits/kubernetes/configuration"
	
	// Scaling traits
	"jacero.io/oam/catalog/traits/kubernetes/scaling"
	
	// Security traits
	"jacero.io/oam/catalog/traits/kubernetes/security"
	
	// Observability traits
	"jacero.io/oam/catalog/traits/kubernetes/observability"
)

// Kubernetes Atomic Traits Catalog
// This file provides a comprehensive collection of atomic traits for Kubernetes resources

//////////////////////////////////////////////
// Workload Traits
//////////////////////////////////////////////

// Kubernetes Deployment for stateless workloads with rolling updates
Deployment: workload.#Deployment

// Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage  
StatefulSet: workload.#StatefulSet

// Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod
DaemonSet: workload.#DaemonSet

// Kubernetes Job for running batch or one-time tasks
Job: workload.#Job

// Kubernetes CronJob for running jobs on a scheduled basis
CronJob: workload.#CronJob

//////////////////////////////////////////////
// Networking Traits
//////////////////////////////////////////////

// Kubernetes Service for exposing an application running on a set of Pods as a network service
Service: networking.#Service

// Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster
Ingress: networking.#Ingress

// Kubernetes NetworkPolicy for controlling network traffic to and from pods
NetworkPolicy: networking.#NetworkPolicy

//////////////////////////////////////////////
// Storage Traits
//////////////////////////////////////////////

// Kubernetes PersistentVolumeClaim for requesting persistent storage
PersistentVolumeClaim: storage.#PersistentVolumeClaim

// Kubernetes StorageClass for defining classes of storage
StorageClass: storage.#StorageClass

//////////////////////////////////////////////
// Configuration Traits
//////////////////////////////////////////////

// Kubernetes ConfigMap for storing configuration data as key-value pairs
ConfigMap: configuration.#ConfigMap

// Kubernetes Secret for storing sensitive configuration data
Secret: configuration.#Secret

//////////////////////////////////////////////
// Scaling Traits
//////////////////////////////////////////////

// Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics
HorizontalPodAutoscaler: scaling.#HorizontalPodAutoscaler

// Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage
VerticalPodAutoscaler: scaling.#VerticalPodAutoscaler

//////////////////////////////////////////////
// Security Traits
//////////////////////////////////////////////

// Kubernetes ServiceAccount provides an identity for processes that run in a Pod
ServiceAccount: security.#ServiceAccount

// Kubernetes Role contains rules that represent a set of permissions within a namespace
Role: security.#Role

// Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users
RoleBinding: security.#RoleBinding

// Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level
ClusterRole: security.#ClusterRole

// Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide
ClusterRoleBinding: security.#ClusterRoleBinding

//////////////////////////////////////////////
// Observability Traits
//////////////////////////////////////////////

// Prometheus ServiceMonitor for scraping metrics from services
ServiceMonitor: observability.#ServiceMonitor

// Prometheus PodMonitor for scraping metrics directly from pods
PodMonitor: observability.#PodMonitor