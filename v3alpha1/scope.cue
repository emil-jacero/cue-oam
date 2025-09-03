package v3alpha1

import (
)

//////////////////////////////////////////////
//// Scopes
//////////////////////////////////////////////

// This scope will implement logic to manage shared network configurations between components
#SharedNetwork: #Scope & {
	#metadata: #scopes: SharedNetwork: {
		type: "network"
        description: "Creates a logical network for components. Implemented differently based on the platform."
	}
	...
}
