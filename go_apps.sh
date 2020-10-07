#!/usr/bin/env bash

# Install Go apps

export PATH=/usr/local/go/bin:"$PATH"
echo "Installing Go apps..."
echo ""

# Only run if Go is present
if [ -x "$(command -v go)" ] > /dev/null 2>&1; then

    # Github Hub
    echo "Installing Github hub"
    go get -u github.com/github/hub

    # Command line two-factor authentication
    echo "Installing 2fa"
    go get -u rsc.io/2fa

    # benchcmp - tool to compare benchmarks made with:
    # GOMAXPROCS=12 go test crypto/tls -bench BenchmarkThroughput > test-a.txt
    # benchcmp test-a.txt test-b.txt
    echo "Installing benchcmp"
    go get -u golang.org/x/tools/cmd/benchcmp

    # Yaegi - Go command line interpreter
    echo "Installing yaegi"
    go get -u github.com/containous/yaegi/cmd/yaegi

    # Kubectx and Kubens
    echo "Installing kubectx and kubens"
    go get -u github.com/ahmetb/kubectx/cmd/kubectx
    go get -u github.com/ahmetb/kubectx/cmd/kubens

    # Hey web load test
    echo "Installing Hey"
    go get -u github.com/rakyll/hey
else
    echo "ERROR: You don't have Go installed."
    exit 1
fi
