# Sprint Change Proposal: Story 1.2 Scope Correction

**Proposal ID**: SCP-2025-11-05-001
**Submitted By**: PM John
**Date**: 2025-11-05
**Priority**: High (Critical Scope Error)
**Status**: Documentation Corrections Completed - Awaiting Approval

---

## Executive Summary

A critical scope error was identified in Epic 1 (Developer Experience Improvements) planning documents. **Story 1.2 was incorrectly scoped as "Add Terraform Infrastructure Alternative"** when the actual requirement is **"Fix Bicep Infrastructure and Enhance Deployment Automation"**.

This proposal documents the systematic correction of all affected planning documents (~150+ Terraform references across 8 files) and requests approval to proceed with Story 1.2 implementation using the corrected scope.

---

## Issue Identification

### Root Cause
Misunderstanding of project requirements during initial planning. The project has existing Bicep infrastructure in `/infra` directory that requires fixes and automation enhancement, NOT a Terraform alternative.

### Discovery
- **Identified By**: QA Review (INFRA-001)
- **Date Identified**: 2025-11-05
- **Severity**: High (incorrect scope affects entire story implementation)

### Evidence
1. Project repository contains `/infra` directory with Bicep modules
2. NO `/terraform` directory exists in the project
3. `azure.yaml` configured for Azure Developer CLI (azd) orchestrating Bicep
4. Story 1.1 Windows setup documentation correctly references `azd up` (Bicep deployment)
5. README.md uses `azd` workflow throughout

---

## Impact Assessment

### Files Affected
**Total**: 8 files
**Total Terraform References Removed/Corrected**: ~150+

### Breakdown by File

| File | Lines Affected | Changes | Status |
|------|---------------|---------|--------|
| `docs/prd.md` | ~50+ references | Replaced Terraform scope with Bicep automation | ✅ Completed (previous PM session) |
| `docs/stories/epic-1-developer-experience-improvements.md` | Multiple sections | Updated Story 1.2 description and requirements | ✅ Completed (previous PM session) |
| `docs/stories/story-1.2-bicep-infrastructure-automation.md` | Entire file | Complete rewrite from Terraform to Bicep scope | ✅ Completed (previous PM session) |
| `docs/architecture.md` | ~100+ references | Component 2 complete rewrite, deployment workflows updated | ✅ Completed (current session) |
| `docs/architecture/tech-stack.md` | 16+ references | Removed Terraform sections, added Bicep automation details | ✅ Completed (current session) |
| `docs/architecture/source-tree.md` | 10+ references | Removed /terraform directory, updated scripts section | ✅ Completed (current session) |
| `docs/architecture/coding-standards.md` | ~90 lines | Removed Terraform Standards section, added Bicep/Automation standards | ✅ Completed (current session) |
| `docs/stories/story-1.1-windows-setup-instructions.md` | 2 notes | Added epic scope clarification and QA remediation note | ✅ Completed (current session) |

---

## Corrected Story 1.2 Scope

### New Title
"Fix Bicep Infrastructure and Enhance Deployment Automation"

### New Goal
Enable one-command deployment (`azd up`) that provisions all Azure resources AND automatically populates `.env` file without manual configuration steps.

### Key Requirements

#### Phase 1: Bicep Infrastructure Fixes
- Audit all Bicep modules in `/infra/modules/` for errors and incompleteness
- Fix broken or missing resource configurations
- Ensure all 7 notebooks' infrastructure requirements are met
- Validate deployment works in clean Azure subscription

#### Phase 2: Deployment Automation Enhancement
- Add post-provision hooks to `azure.yaml`
- Create cross-platform automation scripts:
  - `scripts/populate_env.sh` (bash for Linux/Mac)
  - `scripts/populate_env.ps1` (PowerShell for Windows)
- Scripts automatically create `.env` from `azd env get-values` output
- No manual copying of environment variables required

### Technology Stack Changes

**Before (Incorrect)**:
- Add Terraform as IaC alternative
- Create `/terraform` directory structure
- Provide Terraform deployment option parallel to Bicep

**After (Correct)**:
- Fix existing Bicep infrastructure for reliability
- Enhance Azure Developer CLI workflow with automation
- Add bash/PowerShell scripts for cross-platform .env automation
- Maintain Bicep as ONLY IaC approach

---

## Changes by Document Type

### Architecture Documents

**docs/architecture.md**:
- **Component 2 Section**: Complete rewrite from "Terraform Infrastructure Configuration" to "Bicep Infrastructure Fixes & Automation Enhancement"
- **Integration Strategy**: Changed from "Bicep OR Terraform" to "Enhanced Bicep with automation"
- **Deployment Workflows**: Replaced Terraform workflows with enhanced azd automation workflows
- **Tech Stack Table**: Removed HCL/Terraform entries, added Bash/PowerShell automation
- **Mermaid Diagram**: Updated to show Bicep automation flow instead of Terraform alternative

**docs/architecture/tech-stack.md**:
- Removed "Terraform (New Enhancement)" section entirely
- Removed HCL language entry
- Added "Deployment Enhancement (Story 1.2)" section documenting azd hooks and automation scripts
- Updated VS Code extensions (removed Terraform extension)
- Updated infrastructure deployment time to include automation script timing

**docs/architecture/source-tree.md**:
- Removed `/terraform/` directory from repository structure
- Updated `.env` generation methods (automated via hooks, not Terraform outputs)
- Removed Terraform Standards section from file naming conventions
- Added detailed documentation for new `populate_env.sh` and `populate_env.ps1` scripts
- Marked legacy scripts appropriately

**docs/architecture/coding-standards.md**:
- Removed entire "Terraform Standards" section (~90 lines)
- Added "Bicep Standards" section with formatting, naming, and fixing guidelines
- Added "Automation Script Standards" section for bash and PowerShell
- Updated commit message examples (removed Terraform references)
- Updated branch naming examples
- Updated code review checklist (removed `terraform fmt`, added `az bicep build` and script testing)

### Product Documents

**docs/prd.md** (Completed in previous session):
- ~50+ Terraform references replaced with Bicep automation
- User stories updated to reflect automation goals
- Acceptance criteria corrected for Bicep enhancements
- Technical approach sections rewritten

**docs/stories/epic-1-developer-experience-improvements.md** (Completed in previous session):
- Story 1.2 title and description corrected
- Dependencies and relationships updated
- Success criteria adjusted

**docs/stories/story-1.2-bicep-infrastructure-automation.md** (Completed in previous session):
- Entire file rewritten (replaced old story-1.2-terraform-infrastructure.md)
- 16 detailed acceptance criteria for Bicep fixes and automation
- Implementation guidance for two-phase approach
- Cross-platform testing requirements
- Risk assessment updated

**docs/stories/story-1.1-windows-setup-instructions.md**:
- Added clarification note in Notes section
- Documented that Story 1.2 is Bicep fixes (not Terraform)
- Noted QA-identified INFRA-001 issue resolution

---

## Verification Results

### Grep Verification (Post-Correction)

| File | Terraform References | Status |
|------|---------------------|--------|
| `docs/architecture.md` | 2 (historical/meta only*) | ✅ Pass |
| `docs/architecture/tech-stack.md` | 0 | ✅ Pass |
| `docs/architecture/source-tree.md` | 0 | ✅ Pass |
| `docs/architecture/coding-standards.md` | 0 | ✅ Pass |
| `docs/prd.md` | 2 (historical/meta only*) | ✅ Pass |
| `docs/stories/epic-1*.md` | 3 (historical/meta only*) | ✅ Pass |
| `docs/stories/story-1.2*.md` | 4 (historical/meta only*) | ✅ Pass |

**Meta/Historical References**: Change log entries, scope correction notes, and final document update notes documenting THIS correction. These are appropriate to retain for historical tracking.

### Operational Terraform References
**Count**: 0 ✅

All operational Terraform references (deployment instructions, technology decisions, implementation guidance) have been successfully removed and replaced with correct Bicep automation scope.

---

## Implementation Impact

### What Changes
1. **Story 1.2 Implementation Approach**: From building Terraform alternative to fixing Bicep and adding automation
2. **Developer Work**: Focus on Bicep module debugging and cross-platform script development instead of Terraform module creation
3. **Testing Strategy**: Test Bicep fixes and automation scripts on 3 platforms (Windows, Linux, macOS)
4. **Documentation**: Architecture docs now accurately reflect automation enhancement approach

### What Stays the Same
1. **Story 1.1 Scope**: Windows setup documentation (unchanged, already correct)
2. **Epic 1 Goals**: Improve developer experience (goal unchanged, approach corrected)
3. **Python Code**: Zero changes to notebooks or Python source (constraint maintained)
4. **Existing Bicep**: `/infra` directory structure maintained (being fixed, not replaced)

### Timeline Impact
- **Correction Time**: 2 PM agent sessions (completed)
- **Implementation Time**: Story 1.2 complexity unchanged (fixing Bicep vs creating Terraform = similar effort)
- **Epic 1 Timeline**: No significant delay expected (documentation correction only)

---

## Risk Assessment

### Risks Mitigated by This Correction
1. **Technical Debt Prevention**: Avoided creating redundant Terraform infrastructure
2. **Maintenance Burden**: Single IaC approach (Bicep) vs maintaining two parallel systems
3. **User Confusion**: Clear single deployment path instead of "Bicep OR Terraform" choice
4. **Scope Creep**: Story 1.2 now focused on fixing existing system, not building new alternative

### Remaining Risks
1. **Bicep Fixes Complexity**: Unknown severity of existing Bicep issues until audit completed
   - **Mitigation**: Phase 1 audit will identify issues; escalate to Architect if major redesign needed
2. **Cross-Platform Automation**: Bash/PowerShell parity challenges
   - **Mitigation**: Comprehensive testing on all 3 platforms; simple script logic (call azd, write .env)

---

## Recommendations

### Immediate Actions
1. ✅ **[COMPLETED]** Correct all planning documents (8 files, ~150+ references)
2. **[PENDING]** Approve corrected Story 1.2 scope
3. **[PENDING]** Hand off to Dev agent for Story 1.1 finalization (if not complete)
4. **[PENDING]** Hand off to Dev agent for Story 1.2 implementation (Phase 1: Bicep audit and fixes)

### Story 1.2 Implementation Sequencing
**Phase 1**: Bicep Infrastructure Fixes
1. Audit `/infra/modules/` for errors
2. Fix identified issues
3. Test deployment in clean Azure subscription
4. Validate all 7 notebooks' resources are provisioned

**Phase 2**: Automation Enhancement
1. Create `scripts/populate_env.sh` (bash)
2. Create `scripts/populate_env.ps1` (PowerShell)
3. Update `azure.yaml` with post-provision hooks
4. Test automation on Windows 11, Linux, macOS
5. Update README.md with automated workflow

### Quality Gates
- [ ] Story 1.2 Phase 1 complete: `azd up` succeeds in clean subscription, all resources provisioned
- [ ] Story 1.2 Phase 2 complete: `.env` auto-created on all platforms, all 7 notebooks run successfully
- [ ] Epic 1 complete: Windows users can run `azd up` → notebooks work (zero manual config)

---

## Approval Request

### Requested Approvals
- [ ] **Product Owner**: Approve corrected Story 1.2 scope
- [ ] **Architect**: Confirm Bicep fix approach aligns with infrastructure standards
- [ ] **Dev Team Lead**: Acknowledge implementation approach and timeline

### Questions for Stakeholders
1. **For PO**: Does corrected Story 1.2 scope (Bicep fixes + automation) meet Epic 1 goals?
2. **For Architect**: Are there known issues with existing Bicep that should be flagged before Dev agent starts?
3. **For Dev Lead**: Should Story 1.1 be completed/merged before starting Story 1.2, or can they proceed in parallel?

---

## Supporting Documentation

### Key Reference Documents
- **Corrected Story**: `docs/stories/story-1.2-bicep-infrastructure-automation.md`
- **Epic Definition**: `docs/stories/epic-1-developer-experience-improvements.md`
- **Architecture**: `docs/architecture.md` (Component 2: Bicep Infrastructure Fixes & Automation Enhancement)
- **Technical Details**: `docs/architecture/tech-stack.md` (Deployment Enhancement section)

### Change History
| Date | Session | Changes | Agent |
|------|---------|---------|-------|
| 2025-11-05 | PM Session 1 | PRD, Epic, Story 1.2 rewrite, Architecture.md intro | PM John |
| 2025-11-05 | PM Session 2 | Architecture.md Component 2 rewrite, all architecture shards, Story 1.1 notes, verification | PM John |

---

## Next Steps

### If Approved
1. **Story 1.1**: Continue/finalize Windows setup documentation implementation
2. **Story 1.2 Phase 1**: Dev agent begins Bicep infrastructure audit and fixes
3. **Story 1.2 Phase 2**: Dev agent implements automation scripts after Phase 1 complete
4. **Epic 1 Completion**: QA testing across all platforms, PR creation, merge to main

### If Clarification Needed
- PM available for questions via this proposal document
- Can provide additional detail on any section
- Can adjust Story 1.2 acceptance criteria if needed based on stakeholder feedback

---

## Summary

This Sprint Change Proposal documents the correction of a critical scope error in Epic 1 Story 1.2. All affected planning documents (8 files, ~150+ references) have been systematically corrected to reflect the accurate scope: **Bicep Infrastructure Fixes and Deployment Automation Enhancement** (not Terraform alternative).

The corrected scope is aligned with project architecture, reduces complexity, and maintains focus on improving the existing Bicep-based deployment workflow. Implementation approach is well-defined with clear phases, acceptance criteria, and quality gates.

**Recommendation**: Approve corrected Story 1.2 scope and proceed with implementation.

---

**Prepared by**: PM John (BMad Framework PM Agent)
**Review Status**: Awaiting stakeholder approval
**Document Version**: 1.0
**Last Updated**: 2025-11-05

---

**END OF SPRINT CHANGE PROPOSAL**
