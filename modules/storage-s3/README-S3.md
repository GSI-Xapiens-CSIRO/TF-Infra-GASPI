## LifeCyle Storage Class S3

### S3 Storage Classes Comparison Table

| Feature | STANDARD | STANDARD_IA | GLACIER | DEEP_ARCHIVE |
|---------|----------|-------------|----------|--------------|
| Access Time | Immediate (milliseconds) | Milliseconds | Minutes to Hours | Up to 12 Hours |
| Availability | 99.99% | 99.9% | 99.99% | 99.99% |
| Durability | 99.999999999% | 99.999999999% | 99.999999999% | 99.999999999% |
| Minimum Storage Duration | None | 30 Days | 90 Days | 180 Days |
| Minimum Object Size | None | 128KB | 40KB | 40KB |
| Retrieval Fee | None | Per GB retrieved | Per GB retrieved | Per GB retrieved |
| First Byte Latency | Milliseconds | Milliseconds | Select Minutes/Hours | Hours |
| Storage Cost (relative) | Highest (100%) | ~50% of STANDARD | ~20% of STANDARD | ~10% of STANDARD |

### Use Case Comparison

| Storage Class | Ideal Use Cases | Not Recommended For |
|--------------|-----------------|-------------------|
| STANDARD | Active data, frequent access | Long-term archival |
| STANDARD_IA | Infrequent access, quick retrieval needed | Small files (<128KB) |
| GLACIER | Long-term backup, regulatory data | Frequently accessed data |
| DEEP_ARCHIVE | 20+ year retention, rarely accessed | Time-sensitive retrieval |

### Retrieval Options and Times

| Storage Class | Retrieval Option | Retrieval Time | Cost Level |
|--------------|------------------|----------------|------------|
| STANDARD | Standard | Immediate | Free |
| STANDARD_IA | Standard | Immediate | Low |
| GLACIER | Expedited | 1-5 Minutes | Highest |
| GLACIER | Standard | 3-5 Hours | Medium |
| GLACIER | Bulk | 5-12 Hours | Lowest |
| DEEP_ARCHIVE | Standard | 12 Hours | Low |
| DEEP_ARCHIVE | Bulk | 48 Hours | Lowest |

### Cost Components

| Cost Factor | STANDARD | STANDARD_IA | GLACIER | DEEP_ARCHIVE |
|------------|----------|-------------|----------|--------------|
| Storage | Highest | Medium | Low | Lowest |
| Requests | Low | Medium | High | High |
| Retrieval | Free | Low | Medium-High | High |
| Minimum Billing Size | None | 128 KB | 40 KB | 40 KB |
| Early Delete Fee | No | Yes (30 days) | Yes (90 days) | Yes (180 days) |