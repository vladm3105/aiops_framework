# Claude Agent Google Cloud Run Deployment Guide

This guide provides step-by-step instructions for Claude agents to deploy containerized applications to Google Cloud Run.

## Prerequisites

### Required Tools
- Google Cloud CLI (`gcloud`) installed and authenticated
- Docker (optional, for building custom images)
- jq (for JSON processing)
- curl (for health checks)

### Google Cloud Setup
- Google Cloud project with appropriate permissions
- Billing account enabled
- Required APIs enabled (Cloud Run, Cloud Build, Container Registry)

### Authentication
```bash
# Login to Google Cloud
gcloud auth login

# Set default project (if you have multiple)
gcloud config set project PROJECT_ID

# Verify authentication and project
gcloud config list
```

## Quick Start - Deploy Simple Service

### Step 1: Basic Cloud Run Deployment
```bash
# Navigate to GCP deployment directory
cd .ai_devops/gcp

# Deploy default hello-world service
./scripts/deploy-cloud-run.sh
```

This will deploy:
- Service name: `simple-app`
- Image: `gcr.io/cloudrun/hello` (Google's hello-world image)
- Environment: `development`
- Region: `us-central1`

### Step 2: Verify Deployment
```bash
# Check deployment status
./scripts/validate-cloud-run.sh simple-app

# View service details
./scripts/manage-cloud-run.sh status simple-app

# View service logs
./scripts/manage-cloud-run.sh logs simple-app
```

## Custom Deployment Instructions

### Deploy Custom Application

```bash
# Deploy with custom parameters
./scripts/deploy-cloud-run.sh \
  "my-web-service" \
  "gcr.io/my-project/webapp:v1.0" \
  "production" \
  "my-project-id" \
  "us-west1"
```

Parameters:
1. `service_name` - Unique name for your Cloud Run service
2. `image_name` - Container image (GCR, Artifact Registry, or Docker Hub)
3. `environment` - development/staging/production
4. `project_id` - Google Cloud project ID
5. `region` - Google Cloud region

### Using Configuration Files

Edit `configs/gcp-deployment.json` for your specific needs:

```json
{
  "gcp_deployment": {
    "default_project": "my-project-id",
    "default_region": "us-central1",
    "environments": {
      "production": {
        "min_instances": 1,
        "max_instances": 100,
        "cpu_limit": "2",
        "memory_limit": "2Gi"
      }
    }
  }
}
```

Then deploy:
```bash
./scripts/deploy-cloud-run.sh my-service gcr.io/my-project/app:latest production
```

## Deployment Strategies

### Blue-Green Deployment

For zero-downtime deployments with traffic splitting:

```bash
# Deploy new version (green) with no traffic
gcloud run deploy my-service-green \
  --image gcr.io/my-project/app:v2.0 \
  --region us-central1 \
  --no-traffic

# Validate green deployment
./scripts/validate-cloud-run.sh my-service-green

# Gradually shift traffic to green
gcloud run services update-traffic my-service \
  --to-revisions=my-service-green=10 \
  --region us-central1

# If successful, shift all traffic
gcloud run services update-traffic my-service \
  --to-revisions=my-service-green=100 \
  --region us-central1

# Remove old version
gcloud run services delete my-service-blue --region us-central1 --quiet
```

### Canary Deployment

For gradual traffic increase:

```bash
# Deploy canary version
gcloud run deploy my-service \
  --image gcr.io/my-project/app:v2.0 \
  --region us-central1 \
  --tag canary \
  --no-traffic

# Direct 5% traffic to canary
gcloud run services update-traffic my-service \
  --to-tags canary=5 \
  --region us-central1

# Monitor metrics and gradually increase
gcloud run services update-traffic my-service \
  --to-tags canary=25 \
  --region us-central1

# If successful, promote canary to serve all traffic
gcloud run services update-traffic my-service \
  --to-tags canary=100 \
  --region us-central1
```

## Configuration Management

### Environment Variables

Set environment-specific variables:

```bash
# Deploy with environment variables
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --set-env-vars "API_URL=https://api.mycompany.com,LOG_LEVEL=info,ENABLE_METRICS=true" \
  --region us-central1
```

### Secrets Management

For sensitive data, use Google Secret Manager:

```bash
# Create secret
gcloud secrets create database-password --data-file=password.txt

# Deploy service with secret
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --set-secrets "DATABASE_PASSWORD=database-password:latest" \
  --region us-central1
```

### Service Account and IAM

```bash
# Create service account
gcloud iam service-accounts create my-service-account \
  --description="Service account for my Cloud Run service"

# Grant necessary permissions
gcloud projects add-iam-policy-binding my-project \
  --member="serviceAccount:my-service-account@my-project.iam.gserviceaccount.com" \
  --role="roles/cloudsql.client"

# Deploy with custom service account
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --service-account my-service-account@my-project.iam.gserviceaccount.com \
  --region us-central1
```

## Monitoring and Logging

### Basic Monitoring

```bash
# View real-time logs
gcloud run services logs read my-service --region us-central1 --follow

# Get service metrics
gcloud run services describe my-service --region us-central1 \
  --format="table(spec.template.spec.containers[0].resources.limits)"
```

### Cloud Monitoring Integration

```bash
# View service in Cloud Console
echo "https://console.cloud.google.com/run/detail/us-central1/my-service"

# Create monitoring policy
gcloud alpha monitoring policies create \
  --policy-from-file=monitoring-policy.yaml
```

### Log Analysis with Cloud Logging

```bash
# Query logs using Cloud Logging
gcloud logging read 'resource.type="cloud_run_revision" AND resource.labels.service_name="my-service"' \
  --limit=50 \
  --format=json

# Create log-based metrics
gcloud logging metrics create error_rate \
  --description="Count of error logs" \
  --log-filter='resource.type="cloud_run_revision" AND severity="ERROR"'
```

## Performance Optimization

### Cold Start Optimization

```bash
# Deploy with minimum instances to reduce cold starts
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --min-instances 1 \
  --region us-central1

# Use startup CPU boost for faster cold starts
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --cpu-boost \
  --region us-central1
```

### Resource Optimization

```bash
# Configure optimal resources based on load testing
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --cpu 2 \
  --memory 2Gi \
  --concurrency 100 \
  --max-instances 50 \
  --region us-central1
```

### Request Timeout Configuration

```bash
# Set appropriate timeout for your application
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --timeout 900 \
  --region us-central1
```

## Troubleshooting Guide

### Common Issues

#### Service Won't Start

```bash
# Check service status and events
gcloud run services describe my-service --region us-central1

# Check revision status
gcloud run revisions describe my-service-00001 --region us-central1

# View detailed logs
gcloud run services logs read my-service --region us-central1 --limit=100
```

#### Image Pull Failures

```bash
# For Container Registry, ensure authentication
gcloud auth configure-docker

# For Artifact Registry
gcloud auth configure-docker us-central1-docker.pkg.dev

# Check image exists
gcloud container images list --repository=gcr.io/my-project

# Verify image details
gcloud container images describe gcr.io/my-project/app:latest
```

#### Traffic Routing Issues

```bash
# Check traffic allocation
gcloud run services describe my-service --region us-central1 \
  --format="table(status.traffic[].revisionName,status.traffic[].percent)"

# Reset traffic to latest revision
gcloud run services update-traffic my-service \
  --to-latest \
  --region us-central1
```

#### Performance Issues

```bash
# Check resource utilization
./scripts/manage-cloud-run.sh metrics my-service

# Analyze request patterns
gcloud logging read 'resource.type="cloud_run_revision" AND httpRequest.requestMethod!=""' \
  --format="table(timestamp,httpRequest.requestMethod,httpRequest.status,httpRequest.latency)"

# Check for cold starts
gcloud logging read 'resource.type="cloud_run_revision" AND textPayload:"Cold start"' \
  --limit=10
```

## Security Best Practices

### Container Security

1. **Use Official Base Images**: Start with minimal, official base images
2. **Scan for Vulnerabilities**: Enable vulnerability scanning in Container Registry
3. **Non-Root User**: Run containers as non-root user
4. **Minimal Privileges**: Use principle of least privilege for service accounts

```bash
# Enable vulnerability scanning
gcloud container images scan gcr.io/my-project/app:latest

# Check scan results
gcloud container images list-tags gcr.io/my-project/app \
  --show-occurrences \
  --format="table(digest,tags,timestamp)"
```

### Network Security

```bash
# Deploy with VPC connector for private network access
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --vpc-connector my-vpc-connector \
  --vpc-egress private-ranges-only \
  --region us-central1

# Restrict ingress to internal traffic only
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --ingress internal \
  --region us-central1
```

### Binary Authorization

```bash
# Enable Binary Authorization for container signing
gcloud container binauthz policy import policy.yaml

# Deploy with Binary Authorization enforcement
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --binary-authorization default \
  --region us-central1
```

## Cost Management

### Resource Right-Sizing

```bash
# Monitor actual resource usage
gcloud logging read 'resource.type="cloud_run_revision" AND jsonPayload.message:"Container memory utilization"' \
  --format="table(timestamp,jsonPayload.memory_utilization)"

# Adjust resources based on usage patterns
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --cpu 1 \
  --memory 512Mi \
  --region us-central1
```

### Scaling Optimization

```bash
# Configure autoscaling based on traffic patterns
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --min-instances 0 \
  --max-instances 10 \
  --concurrency 50 \
  --region us-central1
```

### Cost Monitoring

```bash
# Export billing data to BigQuery for analysis
gcloud billing accounts list
gcloud billing budgets create --billing-account BILLING_ACCOUNT_ID \
  --budget-file budget.yaml
```

## Advanced Scenarios

### Multi-Region Deployment

```bash
# Deploy to multiple regions for high availability
regions=("us-central1" "us-east1" "europe-west1")

for region in "${regions[@]}"; do
  gcloud run deploy my-service \
    --image gcr.io/my-project/app:latest \
    --region $region \
    --platform managed
done

# Set up global load balancer
gcloud compute url-maps create my-service-lb \
  --default-backend-service my-service-backend
```

### CI/CD Integration

```bash
# Cloud Build configuration for automated deployment
cat > cloudbuild.yaml << EOF
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/\$PROJECT_ID/app:\$COMMIT_SHA', '.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/\$PROJECT_ID/app:\$COMMIT_SHA']
- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  entrypoint: gcloud
  args: ['run', 'deploy', 'my-service', '--image', 'gcr.io/\$PROJECT_ID/app:\$COMMIT_SHA', '--region', 'us-central1']
EOF

# Trigger build
gcloud builds submit --config cloudbuild.yaml .
```

### Database Integration

```bash
# Deploy with Cloud SQL connection
gcloud run deploy my-service \
  --image gcr.io/my-project/app:latest \
  --add-cloudsql-instances my-project:us-central1:my-database \
  --set-env-vars "DATABASE_URL=/cloudsql/my-project:us-central1:my-database" \
  --region us-central1
```

## Automation and AI Integration

### AI-Powered Deployment Analysis

The framework includes pre-configured prompts for Claude to analyze deployments:

```bash
# Use Claude prompts for deployment analysis
claude-prompt: "cloud_run_analysis"
# Input: Service configuration JSON
# Output: Optimization recommendations

# Deployment strategy generation
claude-prompt: "deployment_strategy" 
# Input: Application requirements
# Output: Step-by-step deployment plan

# Troubleshooting assistance
claude-prompt: "troubleshooting"
# Input: Error logs and service status
# Output: Diagnostic steps and solutions
```

### Automated Decision Making

Claude agents can use this framework to:

1. **Analyze** service requirements and recommend optimal configurations
2. **Deploy** services using validated scripts and best practices  
3. **Monitor** service health and performance metrics
4. **Optimize** resource allocation based on usage patterns
5. **Troubleshoot** issues using integrated diagnostic tools

## Support and Resources

### Useful Commands Reference

```bash
# Quick service status
gcloud run services list --region us-central1

# Service URL
gcloud run services describe my-service --region us-central1 --format="value(status.url)"

# Latest revision
gcloud run services describe my-service --region us-central1 --format="value(status.latestCreatedRevisionName)"

# Traffic allocation
gcloud run services describe my-service --region us-central1 --format="table(status.traffic[].revisionName,status.traffic[].percent)"
```

### Additional Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference/run)
- [Container Best Practices](https://cloud.google.com/solutions/best-practices-for-building-containers)

---

This guide provides comprehensive instructions for Claude agents to successfully deploy and manage containerized applications on Google Cloud Run. Follow the step-by-step procedures and adapt them to your specific requirements.