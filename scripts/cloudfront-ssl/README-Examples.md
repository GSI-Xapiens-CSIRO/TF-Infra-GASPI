## 📁 Examples Folder Summary

### 🔧 `examples/dev.conf`

- **Purpose:** Development and testing environment
- **Key Features:**
  - Cost-optimized with `PriceClass_100`
  - Short cache TTLs (5 minutes) for rapid iteration
  - Debug mode enabled
  - More lenient error thresholds (15%)
  - Access logs disabled to reduce costs
  - Development team notifications
  - No WAF to reduce complexity

### 🧪 `examples/staging.conf`

- **Purpose:** Pre-production testing and validation
- **Key Features:**
  - Balanced performance with `PriceClass_200`
  - Production-like configurations for testing
  - Enhanced monitoring and load testing support
  - Access logs enabled to test log pipeline
  - Cross-region testing capabilities
  - CI/CD integration ready
  - Security testing features

### 🚀 `examples/prod.conf`

- **Purpose:** Production environment with maximum reliability
- **Key Features:**
  - Global performance with `PriceClass_All`
  - Aggressive caching for optimal performance (24 hours default)
  - Comprehensive security with WAF integration
  - Strict error thresholds (5%)
  - Full backup and disaster recovery
  - Compliance and audit capabilities
  - Blue/Green and Canary deployment support
  - 24/7 production monitoring

## 📊 `examples/xignals-prod.conf`

- **Purpose:** Xignals Observability Platform specific configuration
- **Key Features:**
  - **Real-time optimized:** Short cache TTLs (5 minutes) for live data
  - **Observability-specific headers:** Trace IDs, request IDs, observability sources
  - **API endpoint optimization:** Different caching for metrics, logs, traces
  - **Multi-tenant support:** Tenant isolation and per-tenant caching
  - **Self-monitoring:** Monitor the monitoring platform
  - **Integration-ready:** Prometheus, Grafana, Datadog, Splunk support
  - **Data lifecycle management:** Hot, warm, cold data tiers
  - **WebSocket and SSE support:** For real-time streaming
  - **Enhanced security:** Stricter thresholds for observability data
  - **Cost optimization:** Aggressive compression for observability data

## 🎯 `Usage Patterns`

### Development Workflow

```
# Start with development
./cloudfront-ssl-setup.sh --config examples/dev.conf

# Promote to staging
./cloudfront-ssl-setup.sh --config examples/staging.conf

# Deploy to production
./cloudfront-ssl-setup.sh --config examples/production.conf
```

### Xignals Platform Deployment

```
# Deploy Xignals observability platform
./cloudfront-ssl-setup.sh --config examples/xignals-prod.conf

# Test with staging first
cp examples/xignals-prod.conf examples/xignals-staging.conf

# Edit for staging-specific values
./cloudfront-ssl-setup.sh --config examples/xignals-staging.conf
```