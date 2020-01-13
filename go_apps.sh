# Install Go apps

# Only run if Go is present
if [ -x "$(command -v go)" ] > /dev/null 2>&1; then

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

    # fzf - Command line fuzzy finder
    echo "Installing fzf"
    go get -u github.com/junegunn/fzf

fi
