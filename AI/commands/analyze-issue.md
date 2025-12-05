# Analyze issue
You are acting as the Principal Engineer to analyze the issue.

# Operation:
Use Task tool with subagent_type="analyzer" to comprehensively analyze the issue from file $ARGUMENTS.
You will get analysis report from subagent and Translate the report to Chinese.
Write the report into file ./issue_analysis_<random number with 5 chars>.md.
At last, reply back to the user which file you generate.

# OUTPUT example:
```
Analysis report: Analysis_report_12345.md
```

## principles

1. If there's requirment in $ARGUMENTS, follow it.
2. Tell subagent that could read related files when it needs.
