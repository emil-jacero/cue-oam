package kubernetes

import (
	"jacero.io/oam/catalog/traits/kubernetes/workload"
	"jacero.io/oam/catalog/traits/kubernetes/networking"
	"jacero.io/oam/catalog/traits/kubernetes/storage"
	"jacero.io/oam/catalog/traits/kubernetes/configuration"
	"jacero.io/oam/catalog/traits/kubernetes/scaling"
	"jacero.io/oam/catalog/traits/kubernetes/security"
	"jacero.io/oam/catalog/traits/kubernetes/observability"
)

// Kubernetes Atomic Traits Catalog
// This file provides a comprehensive collection of atomic traits for Kubernetes resources

//////////////////////////////////////////////
// Workload Traits
//////////////////////////////////////////////

// Kubernetes Deployment for stateless workloads with rolling updates
#Deployment: workload.#Deployment
#Deployments: workload.#Deployments

// Kubernetes StatefulSet for stateful workloads with stable network identities and persistent storage
#StatefulSet: workload.#StatefulSet
#StatefulSets: workload.#StatefulSets

// Kubernetes DaemonSet ensures that all (or some) nodes run a copy of a pod
#DaemonSet: workload.#DaemonSet
#DaemonSets: workload.#DaemonSets

// Kubernetes Job for running batch or one-time tasks
#Job: workload.#Job
#Jobs: workload.#Jobs

// Kubernetes CronJob for running jobs on a scheduled basis
#CronJob: workload.#CronJob

//////////////////////////////////////////////
// Networking Traits
//////////////////////////////////////////////

// Kubernetes Service for exposing an application running on a set of Pods as a network service
#Service: networking.#Service
#Services: networking.#Services

// Kubernetes Ingress for HTTP and HTTPS access to services from outside the cluster
#Ingress: networking.#Ingress

// Kubernetes NetworkPolicy for controlling network traffic to and from pods
#NetworkPolicy: networking.#NetworkPolicy

//////////////////////////////////////////////
// Storage Traits
//////////////////////////////////////////////

// Kubernetes PersistentVolumeClaim for requesting persistent storage
#PersistentVolumeClaim: storage.#PersistentVolumeClaim
#PersistentVolumeClaims: storage.#PersistentVolumeClaims

// Kubernetes StorageClass for defining classes of storage
#StorageClass: storage.#StorageClass

//////////////////////////////////////////////
// Configuration Traits
//////////////////////////////////////////////

// Kubernetes ConfigMap for storing configuration data as key-value pairs
#ConfigMap: configuration.#ConfigMap
#ConfigMaps: configuration.#ConfigMaps

// Kubernetes Secret for storing sensitive configuration data
#Secret: configuration.#Secret
#Secrets: configuration.#Secrets

//////////////////////////////////////////////
// Scaling Traits
//////////////////////////////////////////////

// Kubernetes HorizontalPodAutoscaler for automatic scaling of pods based on observed CPU utilization or custom metrics
#HorizontalPodAutoscaler: scaling.#HorizontalPodAutoscaler

// Kubernetes VerticalPodAutoscaler for automatic adjustment of resource requests based on usage
#VerticalPodAutoscaler: scaling.#VerticalPodAutoscaler

//////////////////////////////////////////////
// Security Traits
//////////////////////////////////////////////

// Kubernetes ServiceAccount provides an identity for processes that run in a Pod
#ServiceAccount: security.#ServiceAccount
#ServiceAccounts: security.#ServiceAccounts

// Kubernetes Role contains rules that represent a set of permissions within a namespace
#Role: security.#Role
#Roles: security.#Roles

// Kubernetes RoleBinding grants permissions defined in a Role to a user or set of users
#RoleBinding: security.#RoleBinding
#RoleBindings: security.#RoleBindings

// Kubernetes ClusterRole contains rules that represent a set of permissions at the cluster level
#ClusterRole: security.#ClusterRole
#ClusterRoles: security.#ClusterRoles

// Kubernetes ClusterRoleBinding grants permissions defined in a ClusterRole to a user or set of users cluster-wide
#ClusterRoleBinding: security.#ClusterRoleBinding
#ClusterRoleBindings: security.#ClusterRoleBindings

//////////////////////////////////////////////
// Observability Traits
//////////////////////////////////////////////

// Prometheus ServiceMonitor for scraping metrics from services
#ServiceMonitor: observability.#ServiceMonitor

// Prometheus PodMonitor for scraping metrics directly from pods
#PodMonitor: observability.#PodMonitor
