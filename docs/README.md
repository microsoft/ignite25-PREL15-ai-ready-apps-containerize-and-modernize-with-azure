# Documentation

Welcome to the documentation for **AI-Ready Apps: Containerize and Modernize with Azure**!

## 📖 About This Documentation

This documentation site provides comprehensive guides, tutorials, and reference materials for modernizing containerized AI applications on Azure. Learn to deploy powerful AI applications using Azure Container Apps with GPU support, Azure OpenAI, open-source models with Ollama, dynamic code execution, and AI agent development.

## 🚀 Viewing the Documentation

This site is built with [MkDocs](https://www.mkdocs.org/) and uses the Material theme for a modern, searchable documentation experience.

### Local Development

To view the documentation locally:

1. **Install dependencies**
   ```bash
   pip install -r ../requirements.txt
   ```

2. **Start the development server**
   ```bash
   cd ..
   mkdocs serve
   ```

3. **Open in your browser**
   - Navigate to `http://localhost:8000`
   - Changes auto-reload as you edit

### Build Static Site

To build the static documentation site:

```bash
mkdocs build
```

The built site will be in the `site/` directory.

## 📚 Documentation Structure

### Getting Started

- **Overview**: Introduction to Azure Container Apps Dynamic Sessions
- **Prerequisites**: Required tools, accounts, and knowledge
- **Quick Start**: Get up and running quickly
- **Architecture**: Understanding the solution architecture

### Tutorials & Guides

- **Lab Instructions**: Step-by-step hands-on lab exercises
- **Deployment Guide**: Deploy applications to Azure
- **Configuration**: Configure Azure resources and applications
- **Best Practices**: Security, performance, and reliability guidelines

### Reference

- **Azure Resources**: Details about Azure services used
- **API Reference**: Application and Azure API documentation
- **CLI Commands**: Common Azure CLI commands and scripts
- **Troubleshooting**: Solutions to common issues

### Examples

- **Code Samples**: Working code examples
- **Use Cases**: Real-world application scenarios
- **Integration Patterns**: Architectural patterns and integrations

## 🔧 Customization

### Configuration

The site is configured in [`mkdocs.yml`](../mkdocs.yml). Key settings:

```yaml
site_name: AI-Ready Apps: Containerize and Modernize with Azure
theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - toc.integrate
    - search.suggest
    - search.highlight
```

### Custom Styling

Custom CSS is located in [`assets/extra.css`](assets/extra.css).

### Custom Templates

Template overrides are in [`overrides/`](overrides/) directory.

## 📝 Contributing to Documentation

We welcome contributions! To contribute:

1. **Edit Markdown files** in the `docs/` directory
2. **Preview changes** locally with `mkdocs serve`
3. **Submit a pull request** with your improvements

### Writing Guidelines

- Use clear, concise language
- Include code examples where applicable
- Add diagrams for complex concepts
- Test all commands and code samples
- Follow the existing structure and style

### Markdown Features

MkDocs Material supports enhanced Markdown features:

- **Admonitions**: Call-out boxes for notes, warnings, tips
- **Code Blocks**: Syntax highlighting with copy button
- **Tabs**: Organize content in tabs
- **Tables**: Responsive data tables
- **Icons & Emojis**: Visual elements
- **Diagrams**: Mermaid diagrams support

## 🎯 Key Topics

### GPU-Accelerated AI on Azure

Deploy cost-efficient AI workloads:

- Serverless GPU compute
- GPU vs CPU performance comparison
- Cost optimization strategies
- Workload patterns and best practices

### Azure Container Apps Dynamic Sessions

Learn about secure, isolated Python environments for code execution:

- Architecture and components
- Security and isolation
- Session lifecycle management
- Best practices

### Azure OpenAI Integration

Integrate GPT models into your applications:

- Model deployment and configuration
- LangChain integration
- Prompt engineering
- Token management and cost control

### Open-Source Models with Ollama

Run local LLMs on Azure:

- Deploying Llama, Mistral, Phi models
- GPU-accelerated inferencing
- Model selection and optimization
- Hybrid cloud/local deployments

### AI Agent Development

Build autonomous AI agents:

- **MCP (Model Context Protocol)**: Connect agents to tools and data
- **Goose Agent**: Autonomous coding and development
- Agent architectures and patterns
- Tool integration and orchestration

### LangChain Framework

Build LLM-powered applications:

- Agents and tools
- Memory and context
- Chains and workflows
- Multi-model integration
- Custom tool development

### Security & Compliance

Implement secure, enterprise-grade AI applications:

- RBAC and identity management
- Network isolation and sandboxing
- Data protection and privacy
- Compliance considerations (GDPR, HIPAA)
- Secure AI inferencing

## 🔗 External Resources

### Microsoft Learn

- [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/cognitive-services/openai/)
- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)

### Community Resources

- [LangChain Documentation](https://python.langchain.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Python Azure SDK](https://learn.microsoft.com/python/azure/)

### Sample Code

- [Container Apps Dynamic Sessions Samples](https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples)
- [Azure OpenAI Samples](https://github.com/Azure-Samples/openai)
- [LangChain Templates](https://github.com/langchain-ai/langchain/tree/master/templates)

## 🛠️ Tools & Extensions

### Recommended VS Code Extensions

- **Python**: Python language support
- **Azure Tools**: Azure resource management
- **Markdown All in One**: Enhanced Markdown editing
- **MkDocs Material**: MkDocs preview support

### CLI Tools

- **Azure CLI**: Azure resource management
- **azd**: Azure Developer CLI
- **kubectl**: Kubernetes management (if using AKS)

## 📞 Support

Need help? Here's how to get support:

- **Lab Issues**: See [`../lab/README.md`](../lab/README.md) troubleshooting section
- **Azure Support**: [Azure Support Plans](https://azure.microsoft.com/support/plans/)
- **Community**: [Microsoft Q&A](https://learn.microsoft.com/answers/)
- **GitHub Issues**: Report issues in this repository

## 📄 License

- Documentation: [Creative Commons Attribution 4.0](../LICENSE-DOCS)
- Code Samples: [MIT License](../LICENSE)

---

**Microsoft Ignite 2025** | Session PREL15

*Comprehensive documentation for building AI-ready applications with Azure*
