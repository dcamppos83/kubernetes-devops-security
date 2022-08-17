#!/bin/bash


docker run --rm --pid=host -v /etc:/etc:ro -v /var:/var:ro -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl -v ~/.kube:/.kube -e KUBECONFIG=/.kube/config -t aquasec/kube-bench:latest  run --targets node --version 1.19 --check 4.2.1,4.2.2 --exit-code 1 --json | jq .Totals.total_fail

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code"

    # Check scan results
    if [[ ${exit_code} == 1 ]]; then
        echo "Image scanning failed. Vulnerabilities found"
        #exit 1;
    else
        echo "Image scanning passed. No vulnerabilities found"
    fi;