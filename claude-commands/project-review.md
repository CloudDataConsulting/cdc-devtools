# Comprehensive Project Review

Conduct a thorough, multi-perspective analysis of the current project state and generate a comprehensive status report.

## Objective
Generate a detailed `project-status-report.md` at the project root that provides actionable insights into project health, maturity, and improvement opportunities.

## Agent Assignment Strategy
Utilize specialized agents based on project characteristics:

### Core Analysis Agents
- **Project Manager**: Overall project health, timeline assessment, stakeholder alignment
- **Technical Writer**: Documentation quality, knowledge gaps, user experience
- **Software Engineer (Python)**: Code quality, architecture patterns, technical debt
- **Data Architect**: Data flow design, storage strategies, pipeline efficiency
- **Infrastructure Engineer**: Deployment readiness, scalability, monitoring

### Conditional Agents (Use as applicable)
- **Security Specialist**: Security posture, compliance requirements
- **DevOps Engineer**: CI/CD maturity, deployment automation
- **UI/UX Expert**: Interface design, user experience (for user-facing projects)
- **Analytics Engineer**: Metrics, observability, performance tracking

## Analysis Framework

### 1. Project Discovery
- **Codebase Structure**: Architecture patterns, module organization
- **Dependencies**: External libraries, internal dependencies, version management
- **Configuration**: Environment management, settings, secrets handling
- **Testing**: Coverage, quality, automation level

### 2. Maturity Assessment
- **Development Stage**: Prototype/MVP/Production-ready
- **Code Quality**: Standards compliance, maintainability, technical debt
- **Documentation**: Completeness, accuracy, developer experience
- **Testing Strategy**: Unit/integration/end-to-end coverage

### 3. Production Readiness Evaluation
- **Deployment**: Automation, rollback capabilities, environment parity
- **Monitoring**: Logging, metrics, alerting, observability
- **Security**: Authentication, authorization, data protection
- **Performance**: Scalability, resource optimization, bottlenecks

### 4. Architectural Review
- **Design Patterns**: Current vs. recommended approaches
- **Scalability**: Horizontal/vertical scaling considerations
- **Maintainability**: Code organization, separation of concerns
- **Integration Points**: API design, data flow, external dependencies

## Deliverable Requirements

### Project Status Report Structure
```markdown
# Project Status Report

## Executive Summary
- Current stage and overall health
- Key achievements and blockers
- Critical recommendations

## Technical Assessment
- Architecture overview
- Code quality metrics
- Performance characteristics
- Security posture

## Maturity Analysis
- Development practices
- Testing coverage
- Documentation quality
- Deployment readiness

## Recommendations
- Priority 1 (Critical)
- Priority 2 (Important)
- Priority 3 (Enhancement)

## Action Plan
- Immediate next steps
- 30/60/90-day milestones
- Resource requirements
```

## Success Criteria
- Actionable recommendations with clear priorities
- Realistic timeline for improvements
- Specific technical metrics and targets
- Clear risk assessment and mitigation strategies
