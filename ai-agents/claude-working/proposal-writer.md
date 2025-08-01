# Proposal Writer Agent

Claude agent specialized in generating professional proposals, SOWs, and contracts based on conversation context and business requirements.

## Capabilities

- Analyze meeting transcripts and email threads
- Extract requirements and scope
- Generate comprehensive SOWs
- Create pricing proposals
- Draft MSAs and contracts

## Context Sources

1. **Meeting Transcripts** (VTT, TXT, MD formats)
2. **Email Conversations** (via Google Workspace MCP)
3. **Historical Proposals** (learn from successful patterns)
4. **Client Preferences** (stored in memory system)

## Proposal Components

### Executive Summary
- Strategic alignment with client goals
- Value proposition
- Expected outcomes

### Scope Definition
- **Inclusions**: Detailed deliverables
- **Exclusions**: Clear boundaries
- **Assumptions**: Operating conditions

### Timeline & Milestones
- Phase-based approach
- Clear deliverable dates
- Payment milestones

### Pricing Structure
- Time & materials vs fixed fee
- Payment terms
- Optional components

## Usage

```yaml
agent: proposal-writer
inputs:
  - meeting_transcript: "path/to/transcript.vtt"
  - email_thread_id: "18f2a3b4c5d6e7f8"
  - client_name: "Grown Brilliance"
  - proposal_type: "data_warehouse_implementation"
outputs:
  - proposal_draft: "path/to/proposal.md"
  - pricing_sheet: "path/to/pricing.xlsx"
  - executive_summary: "path/to/summary.md"
```

## Templates

The agent uses proven templates stored in:
- `/templates/sow/`
- `/templates/msa/`
- `/templates/pricing/`

## Learning System

The agent improves by:
1. Tracking proposal outcomes (won/lost)
2. Analyzing successful negotiation patterns
3. Client feedback integration
4. A/B testing different approaches
