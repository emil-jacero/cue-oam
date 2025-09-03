package v3alpha1

//////////////////////////////////////////////
// Provider Context
//////////////////////////////////////////////

#ProviderContext: {
	namespace:  string | *"default"
	appName:    string
	appVersion: string
	appLabels: [string]: string
	componentName: string
	componentId:   string
	resources: [...#K8sResource]
}
