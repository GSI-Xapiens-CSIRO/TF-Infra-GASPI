#!/bin/bash

# Test Runner for CloudFront SSL Setup
# Comprehensive testing suite with multiple test types and reporting

set -euo pipefail

# ================================
# CONFIGURATION & CONSTANTS
# ================================

readonly SCRIPT_NAME="run-tests.sh"
readonly SCRIPT_VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly TESTS_DIR="$PROJECT_ROOT/tests"

# Test configuration
declare -A TEST_CONFIG=(
    [TIMEOUT]="300"                    # Test timeout in seconds
    [PARALLEL_JOBS]="4"                # Number of parallel test jobs
    [COVERAGE_THRESHOLD]="80"          # Minimum coverage percentage
    [RETRY_ATTEMPTS]="3"               # Number of retry attempts for flaky tests
    [TEST_ENVIRONMENT]="test"          # Default test environment
)

# Test directories
declare -A TEST_DIRS=(
    [unit]="$TESTS_DIR/unit"
    [integration]="$TESTS_DIR/integration"
    [e2e]="$TESTS_DIR/e2e"
    [security]="$TESTS_DIR/security"
    [performance]="$TESTS_DIR/performance"
)

# Colors for output
declare -A COLORS=(
    [RED]='\033[0;31m'
    [GREEN]='\033[0;32m'
    [YELLOW]='\033[1;33m'
    [BLUE]='\033[0;34m'
    [PURPLE]='\033[0;35m'
    [CYAN]='\033[0;36m'
    [WHITE]='\033[1;37m'
    [NC]='\033[0m'
)

# Test results
declare -A TEST_RESULTS=(
    [total]=0
    [passed]=0
    [failed]=0
    [skipped]=0
    [errors]=0
)

# ================================
# UTILITY FUNCTIONS
# ================================

log() { echo -e "${COLORS[GREEN]}[INFO]${COLORS[NC]} $*"; }
warn() { echo -e "${COLORS[YELLOW]}[WARN]${COLORS[NC]} $*"; }
error() { echo -e "${COLORS[RED]}[ERROR]${COLORS[NC]} $*" >&2; }
success() { echo -e "${COLORS[GREEN]}[SUCCESS]${COLORS[NC]} $*"; }
debug() { [[ "${DEBUG:-}" == "true" ]] && echo -e "${COLORS[CYAN]}[DEBUG]${COLORS[NC]} $*"; }

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check prerequisites
check_prerequisites() {
    log "Checking test prerequisites..."

    local missing_tools=()

    # Check required tools
    local required_tools=("bats" "jq" "aws")
    for tool in "${required_tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done

    # Check optional tools
    local optional_tools=("shellcheck" "shfmt" "docker")
    for tool in "${optional_tools[@]}"; do
        if ! command_exists "$tool"; then
            warn "Optional tool not found: $tool"
        fi
    done

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing_tools[*]}"
        log "Run './scripts/install-deps.sh --dev' to install missing dependencies"
        exit 1
    fi

    success "All prerequisites satisfied"
}

# Setup test environment
setup_test_environment() {
    log "Setting up test environment..."

    # Create test directories if they don't exist
    for test_type in "${!TEST_DIRS[@]}"; do
        mkdir -p "${TEST_DIRS[$test_type]}"
    done

    # Set environment variables
    export TEST_MODE=true
    export TEST_ENVIRONMENT="${TEST_CONFIG[TEST_ENVIRONMENT]}"
    export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    export AWS_PAGER=""

    # Create temporary directories
    export TEST_TEMP_DIR=$(mktemp -d)
    export TEST_OUTPUT_DIR="$PROJECT_ROOT/test-results"
    mkdir -p "$TEST_OUTPUT_DIR"

    # Backup any existing configuration
    if [[ -f "$PROJECT_ROOT/cloudfront-config.conf" ]]; then
        cp "$PROJECT_ROOT/cloudfront-config.conf" "$PROJECT_ROOT/cloudfront-config.conf.backup"
    fi

    debug "Test environment setup completed"
}

# Cleanup test environment
cleanup_test_environment() {
    log "Cleaning up test environment..."

    # Remove temporary directories
    if [[ -n "${TEST_TEMP_DIR:-}" && -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi

    # Restore configuration backup
    if [[ -f "$PROJECT_ROOT/cloudfront-config.conf.backup" ]]; then
        mv "$PROJECT_ROOT/cloudfront-config.conf.backup" "$PROJECT_ROOT/cloudfront-config.conf"
    fi

    # Cleanup any test AWS resources (if cleanup script exists)
    if [[ -f "$SCRIPT_DIR/cleanup-test-resources.sh" ]]; then
        "$SCRIPT_DIR/cleanup-test-resources.sh" || warn "Failed to cleanup test resources"
    fi

    debug "Test environment cleanup completed"
}

# ================================
# TEST EXECUTION FUNCTIONS
# ================================

# Run bats tests
run_bats_tests() {
    local test_dir="$1"
    local test_type="$2"
    local output_file="$TEST_OUTPUT_DIR/${test_type}-results.tap"

    if [[ ! -d "$test_dir" ]]; then
        warn "Test directory not found: $test_dir"
        return 0
    fi

    local test_files
    test_files=$(find "$test_dir" -name "*.bats" -type f)

    if [[ -z "$test_files" ]]; then
        warn "No test files found in: $test_dir"
        return 0
    fi

    log "Running $test_type tests..."

    local bats_args=(
        "--tap"
        "--timing"
        "--print-output-on-failure"
        "--output" "$TEST_OUTPUT_DIR"
    )

    # Add parallel execution for unit tests
    if [[ "$test_type" == "unit" ]] && command_exists parallel; then
        bats_args+=("--jobs" "${TEST_CONFIG[PARALLEL_JOBS]}")
    fi

    # Run tests with timeout
    if timeout "${TEST_CONFIG[TIMEOUT]}" bats "${bats_args[@]}" $test_files > "$output_file"; then
        success "$test_type tests passed"
        parse_bats_results "$output_file" "$test_type"
        return 0
    else
        local exit_code=$?
        error "$test_type tests failed (exit code: $exit_code)"
        parse_bats_results "$output_file" "$test_type"
        return $exit_code
    fi
}

# Parse bats test results
parse_bats_results() {
    local results_file="$1"
    local test_type="$2"

    if [[ ! -f "$results_file" ]]; then
        warn "Results file not found: $results_file"
        return
    fi

    local total passed failed skipped
    total=$(grep -c "^[0-9]" "$results_file" || echo 0)
    passed=$(grep -c "^ok" "$results_file" || echo 0)
    failed=$(grep -c "^not ok" "$results_file" || echo 0)
    skipped=$(grep -c "# skip" "$results_file" || echo 0)

    # Update global results
    TEST_RESULTS[total]=$((TEST_RESULTS[total] + total))
    TEST_RESULTS[passed]=$((TEST_RESULTS[passed] + passed))
    TEST_RESULTS[failed]=$((TEST_RESULTS[failed] + failed))
    TEST_RESULTS[skipped]=$((TEST_RESULTS[skipped] + skipped))

    # Display results for this test type
    echo "  $test_type: $passed passed, $failed failed, $skipped skipped (total: $total)"
}

# Run unit tests
run_unit_tests() {
    log "=== UNIT TESTS ==="
    run_bats_tests "${TEST_DIRS[unit]}" "unit"
}

# Run integration tests
run_integration_tests() {
    log "=== INTEGRATION TESTS ==="

    # Check AWS credentials for integration tests
    if ! aws sts get-caller-identity &>/dev/null; then
        warn "AWS credentials not configured. Skipping integration tests."
        log "Configure credentials with: aws configure"
        return 0
    fi

    # Verify we're not in production
    local account_id
    account_id=$(aws sts get-caller-identity --query Account --output text)

    if [[ -f "$PROJECT_ROOT/.aws-production-accounts" ]]; then
        if grep -q "$account_id" "$PROJECT_ROOT/.aws-production-accounts"; then
            error "Refusing to run integration tests in production account: $account_id"
            exit 1
        fi
    fi

    run_bats_tests "${TEST_DIRS[integration]}" "integration"
}

# Run end-to-end tests
run_e2e_tests() {
    log "=== END-TO-END TESTS ==="

    # E2E tests require full AWS setup
    if ! aws sts get-caller-identity &>/dev/null; then
        warn "AWS credentials required for E2E tests. Skipping."
        return 0
    fi

    # Create test configuration
    local test_config="$TEST_TEMP_DIR/e2e-test.conf"
    create_test_configuration "$test_config"

    # Export test configuration path
    export E2E_TEST_CONFIG="$test_config"

    run_bats_tests "${TEST_DIRS[e2e]}" "e2e"
}

# Run security tests
run_security_tests() {
    log "=== SECURITY TESTS ==="

    # Check for security testing tools
    if ! command_exists shellcheck; then
        warn "shellcheck not found. Install with: ./scripts/install-deps.sh --dev"
        return 0
    fi

    # Run ShellCheck on all scripts
    log "Running ShellCheck security analysis..."
    local shellcheck_results="$TEST_OUTPUT_DIR/shellcheck-results.txt"

    if find "$PROJECT_ROOT" -name "*.sh" -type f -exec shellcheck {} \; > "$shellcheck_results" 2>&1; then
        success "ShellCheck analysis passed"
    else
        error "ShellCheck found security issues:"
        cat "$shellcheck_results"
        TEST_RESULTS[failed]=$((TEST_RESULTS[failed] + 1))
    fi

    # Run additional security tests if available
    run_bats_tests "${TEST_DIRS[security]}" "security"
}

# Run performance tests
run_performance_tests() {
    log "=== PERFORMANCE TESTS ==="

    # Performance tests are optional and may require special setup
    if [[ ! -d "${TEST_DIRS[performance]}" ]]; then
        log "No performance tests found. Skipping."
        return 0
    fi

    # Check for performance testing tools
    if ! command_exists ab && ! command_exists wrk; then
        warn "No performance testing tools found (ab, wrk). Skipping performance tests."
        return 0
    fi

    run_bats_tests "${TEST_DIRS[performance]}" "performance"
}

# ================================
# CONFIGURATION AND SETUP
# ================================

# Create test configuration
create_test_configuration() {
    local config_file="$1"

    cat > "$config_file" << EOF
# Test configuration for CloudFront SSL Setup
# This configuration is used for automated testing
DOMAIN="test-example.com"
SUBDOMAIN="test.test-example.com"
ALB_DNS_NAME="test-alb-123456789.us-east-1.elb.amazonaws.com"
SECURITY_GROUP_ID="sg-test123456789"
ALB_REGION="us-east-1"
CERT_REGION="us-east-1"
CUSTOM_HEADER_NAME="X-Test-CloudFront-Secret"
CUSTOM_HEADER_VALUE="test-secret-value-$(date +%s)"
PRICE_CLASS="PriceClass_100"
DEFAULT_TTL="300"
ENABLE_MONITORING="false"
ENABLE_ACCESS_LOGS="false"
DEBUG_MODE="true"
DRY_RUN="true"
EOF

    debug "Test configuration created: $config_file"
}

# ================================
# COVERAGE AND REPORTING
# ================================

# Generate coverage report (if kcov is available)
generate_coverage_report() {
    if ! command_exists kcov; then
        log "kcov not available. Skipping coverage report."
        return 0
    fi

    log "Generating code coverage report..."

    local coverage_dir="$TEST_OUTPUT_DIR/coverage"
    mkdir -p "$coverage_dir"

    # Run coverage on main script
    kcov --include-pattern="$PROJECT_ROOT" \
         --exclude-pattern="/tmp,/tests" \
         "$coverage_dir" \
         "$PROJECT_ROOT/cloudfront-ssl-setup.sh" \
         --help > /dev/null 2>&1 || true

    # Check coverage threshold
    if [[ -f "$coverage_dir/index.html" ]]; then
        local coverage_percent
        coverage_percent=$(grep -o "covered:[^%]*%" "$coverage_dir/index.html" | grep -o "[0-9]*" | head -1)

        if [[ -n "$coverage_percent" ]]; then
            if [[ $coverage_percent -ge ${TEST_CONFIG[COVERAGE_THRESHOLD]} ]]; then
                success "Code coverage: $coverage_percent% (threshold: ${TEST_CONFIG[COVERAGE_THRESHOLD]}%)"
            else
                warn "Code coverage: $coverage_percent% (below threshold: ${TEST_CONFIG[COVERAGE_THRESHOLD]}%)"
            fi
        fi
    fi
}

# Generate HTML test report
generate_html_report() {
    log "Generating HTML test report..."

    local report_file="$TEST_OUTPUT_DIR/test-report.html"

    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>CloudFront SSL Setup - Test Report</title>
    <meta charset="UTF-8">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #f4f4f4; padding: 20px; border-radius: 5px; }
        .summary { margin: 20px 0; }
        .passed { color: #28a745; }
        .failed { color: #dc3545; }
        .skipped { color: #ffc107; }
        .section { margin: 20px 0; border: 1px solid #ddd; border-radius: 5px; }
        .section-header { background: #007bff; color: white; padding: 10px; }
        .section-content { padding: 10px; }
        pre { background: #f8f9fa; padding: 10px; border-radius: 3px; overflow-x: auto; }
        .timestamp { color: #666; font-size: 0.9em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>CloudFront SSL Setup - Test Report</h1>
        <p class="timestamp">Generated: $(date)</p>
        <p>Script Version: $SCRIPT_VERSION</p>
    </div>

    <div class="summary">
        <h2>Test Summary</h2>
        <p>Total Tests: <strong>${TEST_RESULTS[total]}</strong></p>
        <p class="passed">Passed: <strong>${TEST_RESULTS[passed]}</strong></p>
        <p class="failed">Failed: <strong>${TEST_RESULTS[failed]}</strong></p>
        <p class="skipped">Skipped: <strong>${TEST_RESULTS[skipped]}</strong></p>
    </div>
EOF

    # Add test results for each type
    for test_type in unit integration e2e security performance; do
        local results_file="$TEST_OUTPUT_DIR/${test_type}-results.tap"
        if [[ -f "$results_file" ]]; then
            cat >> "$report_file" << EOF
    <div class="section">
        <div class="section-header">
            <h3>${test_type^} Tests</h3>
        </div>
        <div class="section-content">
            <pre>$(cat "$results_file")</pre>
        </div>
    </div>
EOF
        fi
    done

    cat >> "$report_file" << EOF
</body>
</html>
EOF

    success "HTML report generated: $report_file"
}

# Generate JUnit XML report
generate_junit_report() {
    log "Generating JUnit XML report..."

    local junit_file="$TEST_OUTPUT_DIR/junit-results.xml"

    cat > "$junit_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="CloudFront SSL Setup Tests"
           tests="${TEST_RESULTS[total]}"
           failures="${TEST_RESULTS[failed]}"
           skipped="${TEST_RESULTS[skipped]}"
           time="$(date +%s)">
EOF

    # Parse TAP files and convert to JUnit format
    for test_type in unit integration e2e security performance; do
        local results_file="$TEST_OUTPUT_DIR/${test_type}-results.tap"
        if [[ -f "$results_file" ]]; then
            parse_tap_to_junit "$results_file" "$test_type" >> "$junit_file"
        fi
    done

    cat >> "$junit_file" << EOF
</testsuite>
EOF

    success "JUnit report generated: $junit_file"
}

# Parse TAP format to JUnit XML
parse_tap_to_junit() {
    local tap_file="$1"
    local test_type="$2"

    while IFS= read -r line; do
        if [[ $line =~ ^ok\ ([0-9]+)\ (.+)$ ]]; then
            local test_num="${BASH_REMATCH[1]}"
            local test_name="${BASH_REMATCH[2]}"
            echo "  <testcase classname=\"$test_type\" name=\"$test_name\" />"
        elif [[ $line =~ ^not\ ok\ ([0-9]+)\ (.+)$ ]]; then
            local test_num="${BASH_REMATCH[1]}"
            local test_name="${BASH_REMATCH[2]}"
            echo "  <testcase classname=\"$test_type\" name=\"$test_name\">"
            echo "    <failure message=\"Test failed\">$test_name</failure>"
            echo "  </testcase>"
        fi
    done < "$tap_file"
}

# ================================
# TEST FILTERS AND SELECTORS
# ================================

# Run specific test file
run_specific_test() {
    local test_file="$1"

    if [[ ! -f "$test_file" ]]; then
        error "Test file not found: $test_file"
        return 1
    fi

    log "Running specific test: $test_file"

    local output_file="$TEST_OUTPUT_DIR/specific-test-results.tap"

    if timeout "${TEST_CONFIG[TIMEOUT]}" bats --tap "$test_file" > "$output_file"; then
        success "Test passed: $(basename "$test_file")"
        parse_bats_results "$output_file" "specific"
        return 0
    else
        error "Test failed: $(basename "$test_file")"
        parse_bats_results "$output_file" "specific"
        return 1
    fi
}

# Run tests matching pattern
run_tests_by_pattern() {
    local pattern="$1"

    log "Running tests matching pattern: $pattern"

    local matching_tests
    matching_tests=$(find "${TEST_DIRS[@]}" -name "*.bats" -type f | grep -E "$pattern" || true)

    if [[ -z "$matching_tests" ]]; then
        warn "No tests found matching pattern: $pattern"
        return 0
    fi

    local output_file="$TEST_OUTPUT_DIR/pattern-test-results.tap"

    if timeout "${TEST_CONFIG[TIMEOUT]}" bats --tap $matching_tests > "$output_file"; then
        success "Pattern tests passed"
        parse_bats_results "$output_file" "pattern"
        return 0
    else
        error "Pattern tests failed"
        parse_bats_results "$output_file" "pattern"
        return 1
    fi
}

# ================================
# CONTINUOUS INTEGRATION SUPPORT
# ================================

# Setup for CI environment
setup_ci_environment() {
    log "Setting up CI environment..."

    # Set CI-specific configurations
    TEST_CONFIG[PARALLEL_JOBS]="2"  # Reduce for CI
    TEST_CONFIG[TIMEOUT]="600"      # Increase timeout for CI

    # Install missing dependencies in CI
    if [[ "${CI:-}" == "true" ]]; then
        log "Running in CI environment"

        # Install bats if not available
        if ! command_exists bats; then
            log "Installing bats-core for CI..."
            git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
            cd /tmp/bats-core
            sudo ./install.sh /usr/local
            cd -
        fi

        # Set AWS region for CI
        export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
    fi
}

# ================================
# PERFORMANCE AND MONITORING
# ================================

# Monitor test execution time
monitor_test_performance() {
    local start_time="$1"
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log "Test execution completed in ${duration}s"

    # Save performance metrics
    cat > "$TEST_OUTPUT_DIR/performance-metrics.json" << EOF
{
    "start_time": "$start_time",
    "end_time": "$end_time",
    "duration_seconds": $duration,
    "total_tests": ${TEST_RESULTS[total]},
    "tests_per_second": $(echo "scale=2; ${TEST_RESULTS[total]} / $duration" | bc -l 2>/dev/null || echo "0")
}
EOF
}

# ================================
# MAIN EXECUTION
# ================================

show_help() {
    cat << EOF
$SCRIPT_NAME - Test Runner for CloudFront SSL Setup

USAGE:
    $SCRIPT_NAME [OPTIONS] [TEST_TYPE]

TEST TYPES:
    unit            Run unit tests only
    integration     Run integration tests only
    e2e             Run end-to-end tests only
    security        Run security tests only
    performance     Run performance tests only
    all             Run all test types (default)

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -q, --quiet             Suppress non-essential output
    -f, --file FILE         Run specific test file
    -p, --pattern PATTERN   Run tests matching pattern
    -e, --env ENV           Set test environment (default: test)
    -j, --jobs N            Number of parallel jobs (default: 4)
    -t, --timeout N         Test timeout in seconds (default: 300)
    --coverage              Generate code coverage report
    --html                  Generate HTML report
    --junit                 Generate JUnit XML report
    --ci                    Setup for CI environment
    --dry-run               Show what would be tested without running
    --retry N               Number of retry attempts (default: 3)
    --fail-fast             Stop on first test failure
    --cleanup-only          Only run cleanup operations

EXAMPLES:
    $SCRIPT_NAME                        # Run all tests
    $SCRIPT_NAME unit                   # Run unit tests only
    $SCRIPT_NAME integration --ci       # Run integration tests in CI mode
    $SCRIPT_NAME -f tests/unit/config.bats        # Run specific test file
    $SCRIPT_NAME -p "aws.*"             # Run tests matching pattern
    $SCRIPT_NAME --coverage --html      # Run with coverage and HTML report

ENVIRONMENT VARIABLES:
    DEBUG=true              Enable debug output
    CI=true                 Running in CI environment
    AWS_DEFAULT_REGION      AWS region for tests (default: us-east-1)
    TEST_TIMEOUT            Override test timeout
    TEST_PARALLEL_JOBS      Override parallel jobs

For more information, see: https://github.com/xapiens/cloudfront-ssl-setup
EOF
}

main() {
    local test_types=()
    local verbose=false
    local quiet=false
    local specific_file=""
    local pattern=""
    local generate_coverage=false
    local generate_html=false
    local generate_junit=false
    local ci_mode=false
    local dry_run=false
    local fail_fast=false
    local cleanup_only=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                verbose=true
                export DEBUG=true
                shift
                ;;
            -q|--quiet)
                quiet=true
                shift
                ;;
            -f|--file)
                specific_file="$2"
                shift 2
                ;;
            -p|--pattern)
                pattern="$2"
                shift 2
                ;;
            -e|--env)
                TEST_CONFIG[TEST_ENVIRONMENT]="$2"
                shift 2
                ;;
            -j|--jobs)
                TEST_CONFIG[PARALLEL_JOBS]="$2"
                shift 2
                ;;
            -t|--timeout)
                TEST_CONFIG[TIMEOUT]="$2"
                shift 2
                ;;
            --coverage)
                generate_coverage=true
                shift
                ;;
            --html)
                generate_html=true
                shift
                ;;
            --junit)
                generate_junit=true
                shift
                ;;
            --ci)
                ci_mode=true
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --retry)
                TEST_CONFIG[RETRY_ATTEMPTS]="$2"
                shift 2
                ;;
            --fail-fast)
                fail_fast=true
                shift
                ;;
            --cleanup-only)
                cleanup_only=true
                shift
                ;;
            unit|integration|e2e|security|performance|all)
                test_types+=("$1")
                shift
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Default to all tests if none specified
    if [[ ${#test_types[@]} -eq 0 && -z "$specific_file" && -z "$pattern" ]]; then
        test_types=("all")
    fi

    # Set quiet mode
    if [[ "$quiet" == "true" ]]; then
        exec > /dev/null 2>&1
    fi

    # Cleanup only mode
    if [[ "$cleanup_only" == "true" ]]; then
        cleanup_test_environment
        exit 0
    fi

    log "CloudFront SSL Setup Test Runner v$SCRIPT_VERSION"

    # Record start time
    local start_time
    start_time=$(date +%s)

    # Set up trap for cleanup
    trap cleanup_test_environment EXIT

    # Setup CI environment if needed
    if [[ "$ci_mode" == "true" ]]; then
        setup_ci_environment
    fi

    # Check prerequisites
    check_prerequisites

    # Setup test environment
    setup_test_environment

    # Dry run mode
    if [[ "$dry_run" == "true" ]]; then
        log "DRY RUN MODE - Would execute the following tests:"
        for test_type in "${test_types[@]}"; do
            log "  - $test_type tests"
        done
        [[ -n "$specific_file" ]] && log "  - Specific file: $specific_file"
        [[ -n "$pattern" ]] && log "  - Pattern: $pattern"
        exit 0
    fi

    # Execute tests
    local overall_result=0

    # Run specific file
    if [[ -n "$specific_file" ]]; then
        run_specific_test "$specific_file" || overall_result=1
    fi

    # Run tests by pattern
    if [[ -n "$pattern" ]]; then
        run_tests_by_pattern "$pattern" || overall_result=1
    fi

    # Run test types
    for test_type in "${test_types[@]}"; do
        case "$test_type" in
            unit)
                run_unit_tests || overall_result=1
                ;;
            integration)
                run_integration_tests || overall_result=1
                ;;
            e2e)
                run_e2e_tests || overall_result=1
                ;;
            security)
                run_security_tests || overall_result=1
                ;;
            performance)
                run_performance_tests || overall_result=1
                ;;
            all)
                run_unit_tests || overall_result=1
                if [[ "$fail_fast" == "true" && $overall_result -ne 0 ]]; then
                    break
                fi

                run_integration_tests || overall_result=1
                if [[ "$fail_fast" == "true" && $overall_result -ne 0 ]]; then
                    break
                fi

                run_security_tests || overall_result=1
                if [[ "$fail_fast" == "true" && $overall_result -ne 0 ]]; then
                    break
                fi

                run_e2e_tests || overall_result=1
                if [[ "$fail_fast" == "true" && $overall_result -ne 0 ]]; then
                    break
                fi

                run_performance_tests || overall_result=1
                ;;
        esac

        if [[ "$fail_fast" == "true" && $overall_result -ne 0 ]]; then
            error "Test failed. Stopping due to --fail-fast option."
            break
        fi
    done

    # Generate reports
    if [[ "$generate_coverage" == "true" ]]; then
        generate_coverage_report
    fi

    if [[ "$generate_html" == "true" ]]; then
        generate_html_report
    fi

    if [[ "$generate_junit" == "true" ]]; then
        generate_junit_report
    fi

    # Monitor performance
    monitor_test_performance "$start_time"

    # Display final results
    echo ""
    log "=== TEST RESULTS SUMMARY ==="
    log "Total Tests: ${TEST_RESULTS[total]}"
    success "Passed: ${TEST_RESULTS[passed]}"
    if [[ ${TEST_RESULTS[failed]} -gt 0 ]]; then
        error "Failed: ${TEST_RESULTS[failed]}"
    else
        log "Failed: ${TEST_RESULTS[failed]}"
    fi
    if [[ ${TEST_RESULTS[skipped]} -gt 0 ]]; then
        warn "Skipped: ${TEST_RESULTS[skipped]}"
    else
        log "Skipped: ${TEST_RESULTS[skipped]}"
    fi

    # Final result
    if [[ $overall_result -eq 0 ]]; then
        success "All tests completed successfully!"
    else
        error "Some tests failed!"
    fi

    exit $overall_result
}

# Execute main function
main "$@"