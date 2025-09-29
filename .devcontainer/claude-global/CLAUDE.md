# Guidelines

This document defines the project's rules, objectives, and progress management methods. Please proceed with the project according to the following content.

## Top-Level Rules

- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- To understand how to use a library, **always use the Context7 MCP** to retrieve the latest information.
- For temporary notes for design, create a markdown in `.tmp` and save it.
- **After using Write or Edit tools, ALWAYS verify the actual file contents using the Read tool**, regardless of what the system-reminder says. The system-reminder may incorrectly show "(no content)" even when the file has been successfully written.
- Please respond critically and without pandering to my opinions, but please don't be forceful in your criticism.

## Programming Rules

- Avoid hard-coding values unless absolutely necessary.
- Do not use `any` or `unknown` types in TypeScript.
- You must not use a TypeScript `class` unless it is absolutely necessary (e.g., extending the `Error` class for custom error handling that requires `instanceof` checks).

## Development Style - Specification-Driven Development

### Overview

When receiving development tasks, please follow the structured workflow below. This ensures requirement clarification, structured design, comprehensive testing, and efficient implementation using existing SpecKit commands.

### SpecKit-Integrated Workflow

#### Stage 1: Specification & Requirements
- Analyze user requests and convert them into clear functional requirements
- Use `/specify` command with detailed prompts for comprehensive specification
- Example: `/specify "Feature name. Think super hard and consider edge cases, security implications, and integration points"`
- Document requirements clearly with acceptance criteria

#### Stage 2: Design & Implementation Planning
- Create technical design based on requirements
- Use `/plan` command for structured implementation planning
- Focus on architecture, dependencies, and implementation strategy
- Consider performance, maintainability, and scalability

#### Stage 3: Task Breakdown & Management
- Break down design into implementable units
- Use `/tasks` command for detailed task decomposition
- **Always use TodoWrite tool for complex tasks (3+ steps)**
- Prioritize tasks by dependency and importance

#### Stage 4: Implementation with Verification
- Execute implementation following design and task specifications
- **Always verify file changes with Read tool after Write/Edit operations**
- Implement comprehensive error handling and input validation
- Follow existing project patterns and conventions

#### Stage 5: Testing & Quality Assurance
- Implement tests based on acceptance criteria
- Verify all functionality works as expected
- Check for security vulnerabilities and performance issues
- Document any breaking changes or migration steps

## Quality Standards

### Code Review Guidelines
- **Critical Analysis**: Provide honest, objective feedback without false agreement
- **Security Focus**: Always consider security implications of changes
- **Performance Impact**: Evaluate performance implications of implementations
- **Maintainability**: Ensure code is readable and maintainable
- **Test Coverage**: Verify adequate testing of new functionality

### Error Handling
- Implement proper exception handling for all operations
- Provide meaningful error messages to users
- Log errors appropriately without exposing sensitive information
- Design graceful fallbacks for non-critical failures

### Security Practices
- Never commit secrets, API keys, or sensitive information
- Validate and sanitize all user inputs
- Use proper authentication and authorization mechanisms
- Follow the principle of least privilege for permissions

## Efficiency Enhancement

### Parallel Processing
- **Tool Concurrency**: Execute independent tools in parallel within single messages
- **Batch Operations**: Group related file operations for efficiency
- **Search Optimization**: Use multiple search patterns simultaneously when exploring codebases

### File Operations
- **Verification Protocol**: Always Read files after Write/Edit operations
- **Path Management**: Use absolute paths to avoid confusion
- **Change Tracking**: Use git for version control and rollback capabilities

### Task Management
- **Todo Lists**: Use TodoWrite tool for tracking complex multi-step tasks
- **Progress Visibility**: Update task status in real-time
- **Dependency Management**: Identify and manage task dependencies clearly

## Integration Guidelines

### MCP Enhancement
- **MCP設定はプロジェクトごと**: 各プロジェクトの`.mcp.json`で個別管理
- **Context7**: Leverage for codebase analysis and library documentation
- **Serena**: Use for advanced code analysis and optimization suggestions
- **MarkItDown**: Convert HTML/PDF/Office to Markdown format
- **Textlint**: Utilize for Japanese document quality improvement

### Tool Selection
- **Search Strategy**: Use appropriate tools (Grep, Glob, Task) based on search scope
- **File Management**: Prefer editing existing files over creating new ones
- **Documentation**: Only create documentation when explicitly requested

### Performance Considerations
- **Build Time**: Maintain optimized build performance
- **Resource Usage**: Use minimal resources for maximum efficiency
- **Cache Utilization**: Leverage caching mechanisms effectively

---

**Configuration Version**: 1.0.0
**Last Updated**: 2025-09-28
**Based on**: nokonoko1203/claude-code-settings with SpecKit integration