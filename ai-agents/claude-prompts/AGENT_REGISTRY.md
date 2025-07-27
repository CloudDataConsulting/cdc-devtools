# CDC Claude Agent Registry

A comprehensive catalog of specialized Claude agents for Cloud Data Consulting projects.

## Core Agents

### AI Model Orchestrator
- **File**: `core-agents/orchestrator.md`
- **Purpose**: Orchestrates multiple AI models for optimal performance and cost
- **Best for**: Complex projects requiring intelligent model selection
- **Key capabilities**: 
  - Model routing based on task complexity
  - Cost optimization strategies
  - Performance monitoring
  - Parallel model execution

### Technical Documentation Writer
- **File**: `core-agents/doc-writer.md`
- **Purpose**: Creates comprehensive technical documentation
- **Best for**: README files, API docs, architecture guides
- **Key capabilities**:
  - Multiple documentation formats
  - Code example generation
  - Diagram creation (Mermaid)
  - Style consistency

### Python Systems Engineer
- **File**: `core-agents/systems-engineer.md`
- **Purpose**: Builds production-grade Python systems
- **Best for**: Creating reusable packages, CLI tools, modular architectures
- **Key capabilities**:
  - Package structure design
  - Testing framework setup
  - CI/CD pipeline creation
  - Code refactoring

## Data Agents

### Snowflake Architect Pro
- **File**: `data-agents/snowflake-architect-pro.md`
- **Purpose**: Expert Snowflake database architecture and optimization
- **Best for**: Schema design, performance tuning, security implementation
- **Key capabilities**:
  - Consistent naming conventions
  - Performance optimization
  - External stage configuration
  - Comprehensive documentation

### Snowflake Data Architect
- **File**: `data-agents/snowflake-data-architect.md`
- **Purpose**: Data warehouse design and implementation
- **Best for**: Enterprise data architecture, data modeling
- **Key capabilities**:
  - Data model design
  - ETL/ELT patterns
  - Data governance
  - Scalability planning

### Snowflake RAG Architect
- **File**: `data-agents/snowflake-rag-architect.md`
- **Purpose**: Retrieval Augmented Generation systems using Snowflake
- **Best for**: Document processing, vector search, AI-powered analytics
- **Key capabilities**:
  - Vector database design
  - Document chunking strategies
  - Hybrid search implementation
  - Snowflake Cortex integration

### Data Integrity QA Engineer
- **File**: `data-agents/data-integrity-qa-engineer.md`
- **Purpose**: Ensures data quality and integrity across systems
- **Best for**: Data validation, migration testing, quality assurance
- **Key capabilities**:
  - Data validation frameworks
  - Migration verification
  - Constraint testing
  - Zero data loss assurance

### Streamlit Data App Builder
- **File**: `data-agents/streamlit-data-app-builder.md`
- **Purpose**: Creates data-intensive Streamlit applications
- **Best for**: MVPs, dashboards, Snowflake integrations
- **Key capabilities**:
  - Streamlit in Snowflake (SiS)
  - Multi-page applications
  - File processing interfaces
  - Complex visualizations

## DevOps Agents

### AWS Snowflake DevOps Engineer
- **File**: `devops-agents/aws-snowflake-devops.md`
- **Purpose**: Infrastructure as Code for AWS and Snowflake
- **Best for**: Terraform implementations, CI/CD pipelines
- **Key capabilities**:
  - Multi-environment deployments
  - S3-Snowflake integration
  - IAM role configuration
  - Cost optimization

### Cloud Storage Optimizer
- **File**: `devops-agents/cloud-storage-optimizer.md`
- **Purpose**: Optimizes cloud storage for cost and performance
- **Best for**: S3 lifecycle policies, storage architecture
- **Key capabilities**:
  - Lifecycle policy design
  - Cost analysis and reduction
  - Data validation workflows
  - Disaster recovery planning

### Security Compliance Engineer
- **File**: `devops-agents/security-compliance-engineer.md`
- **Purpose**: Implements security measures and ensures compliance
- **Best for**: Credential management, PII detection, audit trails
- **Key capabilities**:
  - Secure credential storage
  - Encryption implementation
  - Access control design
  - Compliance verification (GDPR/CCPA)

## Usage Patterns

### For New Data Projects
1. Start with `snowflake-architect-pro.md` for architecture
2. Add `data-integrity-qa-engineer.md` for quality assurance
3. Use `aws-snowflake-devops.md` for deployment

### For Application Development
1. Begin with `python-systems-engineer.md` for backend
2. Add `streamlit-data-app-builder.md` for frontend
3. Include `tech-docs-writer.md` for documentation

### For Infrastructure Projects
1. Use `aws-snowflake-devops.md` for IaC
2. Add `cloud-storage-optimizer.md` for storage
3. Include `security-compliance-engineer.md` for security

### For AI/ML Projects
1. Start with `ai-model-orchestrator.md` for coordination
2. Add `snowflake-rag-architect.md` for RAG systems
3. Use specialized agents as needed

## Agent Combination Examples

### Data Pipeline Project
```
snowflake-architect-pro.md → Design schemas
aws-snowflake-devops.md → Set up infrastructure  
data-integrity-qa-engineer.md → Validate data quality
tech-docs-writer.md → Document the pipeline
```

### Secure Application
```
python-systems-engineer.md → Build application
security-compliance-engineer.md → Implement security
streamlit-data-app-builder.md → Create UI
aws-snowflake-devops.md → Deploy securely
```

### Cost Optimization Initiative
```
cloud-storage-optimizer.md → Optimize storage
ai-model-orchestrator.md → Optimize AI costs
aws-snowflake-devops.md → Infrastructure efficiency
```

## Best Practices

1. **Agent Selection**
   - Choose the most specific agent for your task
   - Combine complementary agents for complex projects
   - Start with architecture agents before implementation

2. **Customization**
   - Add project-specific context to agents
   - Modify output formats as needed
   - Keep customizations in project documentation

3. **Version Control**
   - Track agent modifications in your project
   - Document why specific agents were chosen
   - Share successful combinations with the team

## Contributing New Agents

To add a new agent to the registry:
1. Follow the template in `templates/agent-template.md`
2. Place in appropriate category directory
3. Update this registry with description
4. Test with real project scenarios
5. Submit PR with examples

## Agent Metrics

Track agent effectiveness:
- **Usage frequency**: Which agents are used most
- **Success rate**: Project outcomes with specific agents
- **Combination patterns**: Common agent pairings
- **Customization needs**: Frequent modifications

Last updated: 2024-01-27