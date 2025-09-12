package schema

import (
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/meta"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/workload"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/networking"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/storage"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/configuration"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/scaling"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/security"
	"jacero.io/oam/catalog/traits/platforms/kubernetes/v2alpha2/schema/observability"
)

// Kubernetes API Object Schemas
// This file provides a comprehensive collection of upstream Kubernetes API object schemas
// All schemas use the official k8s.io CUE modules with proper apiVersion and kind defaults

//////////////////////////////////////////////
// Core Metadata
//////////////////////////////////////////////

// Core metadata definitions
#Object: meta.#Object

#ObjectMeta: meta.#ObjectMeta

//////////////////////////////////////////////
// Workload Schemas
//////////////////////////////////////////////

// Apps/v1 workload resources
#Deployment:       workload.#Deployment
#DeploymentSpec:   workload.#DeploymentSpec
#DeploymentStatus: workload.#DeploymentStatus

#StatefulSet:       workload.#StatefulSet
#StatefulSetSpec:   workload.#StatefulSetSpec
#StatefulSetStatus: workload.#StatefulSetStatus

#DaemonSet:       workload.#DaemonSet
#DaemonSetSpec:   workload.#DaemonSetSpec
#DaemonSetStatus: workload.#DaemonSetStatus

// Batch/v1 job resources
#Job:       workload.#Job
#JobSpec:   workload.#JobSpec
#JobStatus: workload.#JobStatus

#CronJob:     workload.#CronJob
#CronJobSpec: workload.#CronJobSpec

#CronJobStatus: workload.#CronJobStatus

//////////////////////////////////////////////
// Networking Schemas
//////////////////////////////////////////////

// Core/v1 networking
#Service:       networking.#Service
#ServiceSpec:   networking.#ServiceSpec
#ServiceStatus: networking.#ServiceStatus
#ServicePort:   networking.#ServicePort

// Networking/v1 resources
#Ingress:       networking.#Ingress
#IngressSpec:   networking.#IngressSpec
#IngressStatus: networking.#IngressStatus

#NetworkPolicy:     networking.#NetworkPolicy
#NetworkPolicySpec: networking.#NetworkPolicySpec

#NetworkPolicyStatus: networking.#NetworkPolicyStatus

//////////////////////////////////////////////
// Storage Schemas
//////////////////////////////////////////////

// Core/v1 storage
#PersistentVolumeClaim:       storage.#PersistentVolumeClaim
#PersistentVolumeClaimSpec:   storage.#PersistentVolumeClaimSpec
#PersistentVolumeClaimStatus: storage.#PersistentVolumeClaimStatus

// Storage/v1 resources
#StorageClass:     storage.#StorageClass
#StorageClassSpec: storage.#StorageClassSpec

#TopologySelectorTerm: storage.#TopologySelectorTerm

//////////////////////////////////////////////
// Configuration Schemas
//////////////////////////////////////////////

// Core/v1 configuration
#ConfigMap:     configuration.#ConfigMap
#ConfigMapSpec: configuration.#ConfigMapSpec

#Secret: configuration.#Secret

#SecretSpec: configuration.#SecretSpec

//////////////////////////////////////////////
// Scaling Schemas
//////////////////////////////////////////////

// Autoscaling/v2 resources
#HorizontalPodAutoscaler:       scaling.#HorizontalPodAutoscaler
#HorizontalPodAutoscalerSpec:   scaling.#HorizontalPodAutoscalerSpec
#HorizontalPodAutoscalerStatus: scaling.#HorizontalPodAutoscalerStatus

// External autoscaling resources
#VerticalPodAutoscaler:     scaling.#VerticalPodAutoscaler
#VerticalPodAutoscalerSpec: scaling.#VerticalPodAutoscalerSpec

#VerticalPodAutoscalerStatus: scaling.#VerticalPodAutoscalerStatus

//////////////////////////////////////////////
// Security Schemas (RBAC)
//////////////////////////////////////////////

// Core/v1 security
#ServiceAccount:     security.#ServiceAccount
#ServiceAccountSpec: security.#ServiceAccountSpec

// RBAC/v1 resources
#Role:       security.#Role
#RoleSpec:  security.#RoleSpec
#PolicyRule: security.#PolicyRule

#RoleBinding: security.#RoleBinding
#RoleBindingSpec: security.#RoleBindingSpec
#Subject:     security.#Subject
#RoleRef:     security.#RoleRef

#ClusterRole:     security.#ClusterRole
#ClusterRoleSpec: security.#ClusterRoleSpec
#AggregationRule: security.#AggregationRule

#ClusterRoleBinding: security.#ClusterRoleBinding
#ClusterRoleBindingSpec: security.#ClusterRoleBindingSpec

//////////////////////////////////////////////
// Observability Schemas (Prometheus)
//////////////////////////////////////////////

// Monitoring.coreos.com/v1 resources
#ServiceMonitor:     observability.#ServiceMonitor
#ServiceMonitorSpec: observability.#ServiceMonitorSpec
#Endpoint:           observability.#Endpoint

#PodMonitor:         observability.#PodMonitor
#PodMonitorSpec:     observability.#PodMonitorSpec
#PodMetricsEndpoint: observability.#PodMetricsEndpoint

// Common monitoring types
#BasicAuth:            observability.#BasicAuth
#SecretKeySelector:    observability.#SecretKeySelector
#TLSConfig:            observability.#TLSConfig
#ConfigMapKeySelector: observability.#ConfigMapKeySelector
#RelabelConfig:        observability.#RelabelConfig
