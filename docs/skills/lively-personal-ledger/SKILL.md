# Lively Personal Ledger — Master UI/UX Design Review and Codex Handoff Skill

## 1. Purpose

This skill governs the design review, visual direction, Codex handoff, implementation review, and approval cycle for the Nepal-first personal money-tracking Flutter application in this repository.

It exists to prevent:
- generic AI-generated fintech UI
- disconnected screen-by-screen styling
- uncontrolled redesigns
- visual changes that break working product logic
- Codex inventing design decisions without approval
- feature expansion during visual-design work

The skill must be read before any visual-design audit, redesign prompt, or implementation review.

---

## 2. Current Product Source of Truth

This product is a **Nepal-first personal money tracker**, not a restrictive budgeting or financial-coaching app.

### Core purpose
- Record income and expenses quickly
- Maintain transaction history
- Show where money went
- Present monthly financial activity clearly
- Let users explore records by category or income source

### Core product principle
**Show facts, not judgment.**

### Do not introduce
- overspending warnings
- budgeting pressure
- financial coaching
- savings advice
- guilt-based language
- fake bank connectivity
- fake cloud synchronisation
- AI-generated financial recommendations
- cryptocurrency, investments, credit scores, loans, or banking features

### Current navigation
- Home
- Transactions
- Central Add Transaction action
- Summary
- Profile

### Current supported features
- Add Expense
- Add Income
- Edit Transaction
- Delete Transaction
- Repeat Transaction
- Undo after creation
- Recent categories and income sources
- Session-based payment-method preference
- Today, Yesterday, and custom date
- Search and filtering
- Monthly Summary
- Interactive category exploration
- Category Details
- Transaction Details
- Honest first-use states
- Privacy and Data information
- Drift/SQLite local persistence

### Current data truth
- Records are stored locally on the device using Drift/SQLite
- Records remain after the app closes
- No bank or digital-wallet connection exists
- No account exists
- No cloud backup or sync exists
- No analytics SDK transmits financial records

Older budgeting documents or prototype instructions do not override this current tracking-first direction.

---

## 3. Approved Visual Direction

### Direction name
**Lively Personal Ledger**

### Design statement
**Serious with money. Light in interaction.**

### Emotional qualities
- Trustworthy
- Warm
- Tactile
- Personal
- Professional
- Lightly playful
- Smooth
- Responsive

### The product should feel
- enjoyable enough for daily use
- accurate enough for financial records
- modern without becoming a generic neo-bank
- expressive without becoming childish
- calm without becoming visually empty
- locally relevant without using decorative cultural clichés

### The product should not feel
- like a wireframe
- like a default Material 3 demo
- like an AI-generated fintech dashboard
- corporate and cold
- overly card-based
- overly decorative
- gamified
- visually noisy
- animation-heavy

---

## 4. Approved Visual Foundation

These tokens are the starting direction. Codex may refine exact implementation values only when required for contrast, accessibility, or consistency, and must report any change.

### Core colours

```text
canvasWarm          #F7F7F3
surfacePrimary      #FFFFFF
surfaceTinted       #F0F2FF
surfaceStrong       #20243B

inkPrimary          #17191F
inkSecondary        #6C7280
inkOnStrong         #FFFFFF
inkOnStrongMuted    rgba(255,255,255,0.72)

brandCobalt         #4859E8
brandPressed        #3947C7
brandSoft           #EDEFFF

incomeAccent        #168B65
incomeSoft          #E7F7F0

expenseAccentStrong #F04438
expenseText         #C43A31
expenseSoft         #FFF0EE

warmAccent          #F4B64A

borderSubtle        rgba(23,25,31,0.10)
dividerSubtle       rgba(23,25,31,0.08)
```

### Shape system

```text
compactControlRadius    12
inputAndChipRadius      16
utilitySurfaceRadius    20
signatureSurfaceRadius  28
pillRadius               only for true filters or status
```

Do not round every container identically.

### Surface hierarchy

1. **Signature surface**
   - Reserved for Recorded Balance and other hero financial information
   - Highest visual identity
   - Strong tonal contrast
   - Used sparingly

2. **Utility surface**
   - Inputs, filters, selectors, actions
   - Clear but secondary

3. **Flat content**
   - Transaction rows, settings rows, metadata, section groups
   - Avoid wrapping every section in a card

### Typography direction

Preferred family: **Manrope**.

Use another accessible geometric-humanist sans only when Manrope cannot be integrated cleanly.

Requirements:
- tabular figures for financial values where supported
- strong numeric hierarchy
- avoid excessive bold text
- headings feel confident, not heavy
- body copy remains plain and readable
- NPR must be visually related to the amount, not separated randomly
- long amounts must not clip

Suggested roles:

```text
displayFinancial   40–44 / semibold / tabular
titleLarge         28–30 / semibold
titleMedium        20–22 / semibold
sectionTitle       18–20 / semibold
bodyLarge          16–17 / regular-medium
bodyMedium         14–15 / regular
labelLarge         14–15 / semibold
labelSmall         12–13 / medium
```

### Motion system

```text
tapFeedback        90–120ms
selection          160–190ms
navigation         220–260ms
screenTransition   240–300ms
financialValue     260–340ms
dialogOrSheet      220–280ms
```

Motion principles:
- acknowledge actions
- create continuity
- never delay saving or navigation
- prefer opacity and transform
- avoid expensive dynamic blur
- avoid random durations
- no decorative looping animation
- respect reduced-motion settings
- preserve 60fps behaviour on the physical Android device

---

## 5. Architecture That Must Be Preserved

- Flutter and Dart
- Riverpod
- go_router
- Drift/SQLite persistence
- feature-first architecture
- existing repository boundary
- integer-based Money model
- centralised currency and date formatting
- semantic design tokens
- existing navigation structure
- existing calculations and filtering
- existing transaction stream as the runtime source of truth
- existing tests unless intentionally updated

### Codex must not
- place financial calculations inside widgets
- add another state-management system
- add another routing system
- bypass the repository
- store formatted currency strings
- use double for financial values
- duplicate Transaction Details
- create a second transaction source
- replace Drift
- redesign unrelated screens without approval
- delete working functionality
- commit, push, or merge automatically

---

## 6. Collaboration Workflow

Always follow this sequence:

```text
Current screenshots
→ design audit
→ discussion
→ direction decision
→ Codex handoff prompt
→ implementation
→ physical-device testing
→ new screenshots
→ implementation review
→ focused correction prompt
→ repeat until approved
→ commit and merge
```

Do not jump directly from screenshots to implementation before the design direction is approved.

---

## 7. Operating Modes

### Mode A — Current-Screen Audit

Use when the user sends screenshots of the current product.

Review:
- screen purpose
- first visual focus
- hierarchy
- layout
- spacing rhythm
- typography
- financial-number presentation
- colour roles
- surface hierarchy
- component consistency
- interaction clarity
- accessibility
- trust
- emotional quality
- generic AI-pattern risk
- implementation feasibility

Output:
1. What works
2. What feels generic or weak
3. Why it matters
4. Recommended correction
5. Priority
6. Whether a redesign or refinement is needed

Do not create a Codex prompt until the user approves a direction.

### Mode B — Direction Exploration

Use when the current design lacks identity or the user requests a redesign.

Output:
1. Two or three meaningfully different directions
2. Emotional and visual qualities
3. Motion character
4. Benefits
5. Risks
6. Recommended direction

Once one direction is approved, stop proposing alternatives unless the user explicitly reopens the direction decision.

### Mode C — Codex Handoff

Use only after a design direction or correction is approved.

The prompt must be self-contained and must include:
- product context
- approved design direction
- current problems
- exact scope
- screen-by-screen changes
- component rules
- token changes
- motion rules
- architecture restrictions
- responsive requirements
- accessibility requirements
- performance requirements
- tests
- verification commands
- report format
- Git restrictions

Codex does not need screenshots when the prompt describes the approved decisions precisely.

### Mode D — Implementation Review

Use when the user sends screenshots after Codex implementation.

Compare the implementation against:
- the approved direction
- the handoff prompt
- prior screenshots
- user-reported behaviour
- physical-device observations

Output:
1. What matches
2. What does not match
3. Regressions
4. Performance or accessibility concerns
5. Focused correction prompt
6. Approval or rejection decision

Do not reopen the whole design direction for small implementation errors.

---

## 8. Screenshot Review Method

For each screen, identify:

### A. Purpose
What user question or action does this screen support?

### B. First focus
What receives attention first, and should it?

### C. Information hierarchy
Are primary, secondary, and supporting information visually distinct?

### D. Surface logic
Is the screen using cards only where they create useful hierarchy?

### E. Typography
Are headings, labels, metadata, and financial values intentionally typeset?

### F. Spacing
Does whitespace create rhythm, or merely empty space?

### G. Colour
Is colour semantic, branded, accessible, and controlled?

### H. Shape language
Do radii and component forms follow a deliberate family?

### I. Interaction
Are press, selected, disabled, loading, success, error, and destructive states clear?

### J. Motion
Would motion create continuity or become decoration?

### K. Accessibility
Check:
- contrast
- touch target
- text scaling
- colour-independent meaning
- semantics
- focus order
- reduced motion
- long values
- narrow widths

### L. Identity
Would the screen still be recognisable if the logo were removed?

### M. AI-slop detection
Flag:
- identical rounded cards everywhere
- pale colour blocks without purpose
- random gradients
- generic outline-icon rows
- oversized empty states
- decorative charts
- safe but characterless typography
- random pastel categories
- generic floating action navigation
- visual decisions that cannot be explained

---

## 9. Anti-AI-Slop Rules

Do not solve plainness with:
- random gradients
- glassmorphism
- neon colour
- large blurred background blobs
- 3D mascots
- confetti
- cryptocurrency visuals
- excessive shadows
- animation on every element
- a unique colour for every component
- decorative charts
- floating cards without hierarchy

Every visual decision must have at least one purpose:
- hierarchy
- comprehension
- trust
- speed
- continuity
- feedback
- identity

---

## 10. Signature Interaction Principles

### Navigation
- Use a floating utility dock
- Use a smoothly moving active indicator
- Active icon may lift 2–3px
- Labels remain stable and readable
- Central Add action is visually integrated but clearly distinct
- Add press uses compression and spring return
- Navigation must not flash, jump, or rebuild visibly

### Financial values
- Use tabular figures
- Animate value changes only when state actually changes
- Avoid counting animations on every rebuild
- Preserve accuracy during motion
- Reduced motion shows immediate values

### Chips and selectors
- Press compression
- Short selection transition
- Clear selected indicator beyond colour
- No excessive bounce

### Lists
- Rows feel tactile but remain calm
- Insert/delete animation is brief and predictable
- Avoid staggered animation on every screen visit

### Charts
- Animate initial sweep only when appropriate
- Selection is more important than decoration
- Place custom-painted charts inside RepaintBoundary
- Do not animate entire chart on unrelated state changes

---

## 11. Screen-Specific Direction

### Home
- Recorded Balance is the signature component
- Quick Add is tactile and immediately understandable
- This Month becomes a compact activity strip, not a generic card
- Recent Transactions uses strong ledger rhythm
- Avoid large dead zones
- Preserve honest balance explanation

### Add/Edit Transaction
- Amount entry is the dominant interaction
- Type switch is smooth and semantically coloured
- Recent categories feel distinct from the full list
- Category selection uses motion plus a non-colour indicator
- Optional details expand smoothly
- Sticky Save supports disabled, enabled, loading, and success states
- Do not change the field order without explicit approval

### Transactions
- Strong date grouping
- Search and filters do not dominate unnecessarily
- Rows resemble a modern ledger, not a settings list
- Empty state is specific to financial records
- Insert/delete feedback is smooth

### Summary
- Monthly summary is compact and financial
- Chart and category rows feel connected
- Selection is obvious without relying only on colour
- Preserve Category Details journey
- Avoid chart-as-decoration

### Transaction Details
- Amount and category form one strong header
- Metadata is compact and readable
- Edit and Repeat are intentional actions
- Delete remains separated and destructive
- Avoid large unused lower space

### Profile and Privacy
- Avoid administrative prototype appearance
- Use flat grouped settings where possible
- Display accurate local-storage status
- Developer information must reflect Drift/SQLite, not in-memory storage
- Privacy copy must remain truthful

---

## 12. Performance Rules

The user wants smooth interaction with almost no visible rendering or lag.

Codex must:
- avoid rebuilding entire screens for local visual state
- keep local UI state local
- use focused Riverpod watches
- use const widgets where practical
- use RepaintBoundary around custom chart painters
- prefer transform and opacity animations
- avoid expensive blur
- avoid nested animated layouts that trigger repeated full relayout
- profile obvious jank on the connected Android device
- preserve persistence and data flow during redesign

Visual smoothness is not permission to change architecture unnecessarily.

---

## 13. Accessibility Requirements

Minimum expectations:
- WCAG 2.2 AA contrast where applicable
- minimum 48 logical-pixel touch targets for primary controls
- text scaling to 2× without clipping
- 320px and 768px layout checks
- semantic labels for financial values and important actions
- colour is never the only signal
- reduced-motion support
- logical focus order
- accessible dialogs and sheets
- no hidden tooltip-only information
- long NPR values remain readable

---

## 14. Codex Prompt Quality Standard

A weak instruction:
> Make the app look premium and modern.

An acceptable instruction:
> Replace the current Home balance card with the approved signature surface using the project’s surfaceStrong token, 28px radius, white tabular financial typography, integrated income/expense supporting values, and a short value-transition animation that runs only when the underlying summary changes. Preserve all current providers, calculations, information-dialog behaviour, and Drift persistence.

Every major instruction should define:
- affected component
- desired result
- visual rule
- interaction rule
- preserved behaviour
- acceptance criteria

---

## 15. Implementation Review Checklist

Before approval, verify:

### Visual
- Does it match Lively Personal Ledger?
- Does it still look generic?
- Is the hierarchy stronger?
- Is every card necessary?
- Is colour controlled?
- Is typography intentional?
- Does the navigation feel distinctive?
- Does the product have a recognisable visual signature?

### Interaction
- Are taps acknowledged?
- Are animations smooth?
- Are duration and easing consistent?
- Is the central Add action satisfying but not distracting?
- Does reduced motion work?

### Product
- Are all facts accurate?
- Is copy neutral and non-judgmental?
- Is Drift persistence preserved?
- Are current features still reachable?

### Technical
- No calculation changes
- No repository bypass
- No navigation regression
- No duplicated screens
- No unnecessary dependency
- Tests pass
- Debug APK builds
- Physical-device test performed

---

## 16. Final Approval Rules

A visual pass is approved only when:
- it matches the selected direction
- it improves identity and emotional quality
- it preserves usability
- it preserves product logic
- it remains accessible
- it performs smoothly on the physical device
- the user approves the screenshots
- automated tests pass
- no unrelated scope was introduced

Do not recommend commit, push, or merge before visual and physical-device approval.
