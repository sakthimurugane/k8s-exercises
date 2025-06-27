Installing Cloud Provider KIND

Cloud Provider KIND can be installed using golang

go install sigs.k8s.io/cloud-provider-kind@latest

sudo cloud-provider-kind

LB_IP=$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')


# should output foo and bar on separate lines 
for _ in {1..10}; do
  curl ${LB_IP}:5678
done


