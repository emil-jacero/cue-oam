package kubernetes

// Helper functions
#transformProbe: {
	probe: _
	transformedProbe: {
		if probe.httpGet != _|_ {
			httpGet: {
				if probe.httpGet.path != _|_ {path: probe.httpGet.path}
				port: probe.httpGet.port
				if probe.httpGet.scheme != _|_ {scheme: probe.httpGet.scheme}
			}
		}
		if probe.tcpSocket != _|_ {
			tcpSocket: port: probe.tcpSocket.port
		}
		if probe.exec != _|_ {
			exec: {
				if probe.exec.command != _|_ {command: probe.exec.command}
			}
		}
		if probe.initialDelaySeconds != _|_ {initialDelaySeconds: probe.initialDelaySeconds}
		if probe.periodSeconds != _|_ {periodSeconds: probe.periodSeconds}
		if probe.timeoutSeconds != _|_ {timeoutSeconds: probe.timeoutSeconds}
		if probe.successThreshold != _|_ {successThreshold: probe.successThreshold}
		if probe.failureThreshold != _|_ {failureThreshold: probe.failureThreshold}
	}
}
