# GitOps Policy Control Plane

Control Plane repository defines the desired state of shared infrastructure components and enables self-service onboarding process for the application developer teams.

Repository contains the following directories:

* **bootstrap/control-plane** - This bootstrap uses App of Apps to deploy Application Sets. Apply this bootstrap into a control plane cluster that is running an management tools like ArgoCD, defines what resource need to be install on this cluster, the cluster by convention needs to be name "in-cluster", this makes it compatible with ArgoCD SaaS like Akuity Platform. If using ArgoCD SaaS do not deploy this bootstrap.
* **charts** - Defines the custom charts
* **environments** - Defines the resources to be deploy per environment type (ie, dev, qa, staging, prod, etc), includes helm values to override the global ones in the chart directory mentioned above
