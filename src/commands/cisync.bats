# Runs prior to every test
setup() {
    # Load our script file.
    source ./src/scripts/cisync.sh
}

@test '1: cisync' {
    # Mock environment variables or functions by exporting them (after the script has been sourced)
    export MERGE_FROM="alpha"
    export MERGE_TO="master"

    # Capture the output of our "Greet" function
    result=$(Cisync)
    [ $? -eq 0 ]
}