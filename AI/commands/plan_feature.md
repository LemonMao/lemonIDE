# Description
Make plan about how to implement the feature as user's requirements.

# Operation:

Phase 1: Requirement Discovery and Definition

1. Requirement Elaboration: Automatically generate more detailed user stories from the user's initial description.
2. EARS Structuring: Requirements will be organized into EARS (Easy Approach to Requirements Syntax) format to ensure clarity and lack of ambiguity.
3. Augmentation: Automatically consider edge cases and security requirements.
4. Approval and Generation: After confirmation, output content to #Requirement definition.

Phase 2: Design Exploration and Visualization

1. Technical Analysis and Recommendations: Analyze existing technology stacks (if provided) and offer design recommendations.
   You should describe why using this design. What's the benifits?
2. Architecture Visualization: Generate system architecture diagrams using Mermaid; simple logical architecture diagrams are sufficient.
3. Interface Definition: Generate necessary function interfaces or API interfaces according to requirements.
4. Approval and Generation: After design confirmation, output content to #Design exploration.

Phase 3: Implementation Plan and Quality Assurance

1. Best Practice Application: Automatically integrate security, performance, and architecture best practices.
 • Reasons and Trade-offs: Explain why these suggestions are made, and the potential benefits and trade-offs (e.g., performance, development time).
 • Potential Alternatives: If there are multiple implementation approaches, list and analyze their pros and cons.
2. Quality Checkpoints: Set automatic quality check standards for each phase.
3. Dependency and Risk Analysis: Optimize implementation order and identify risk mitigation measures.
4. Approval and Generation: After design confirmation, output content to #Implementation plan.

# OUTPUT example:
```md
# Requirement definition

# Design exploration

# Implementation plan
```

# Rules

1. Don't modify codes. Just make plan.
2. Output should be always Chinese. But some subjects, technical terms, and common nouns in computer science should not be translated.
These untranslated English words should be inlined using Markdown format. For example: `server`, `client`, `host`, `URL`, `URI`, `memory`, `storage`, ...
