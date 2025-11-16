<p align="center">
<a href="https://ignite.microsoft.com/">
<img src="img/Banner-ignite-25.png" alt="Microsoft Ignite 2025" width="1200"/>
</a>
</p>

# [Microsoft Ignite 2025](https://ignite.microsoft.com)


## 🔥 AI-Ready Apps: Containerize and Modernize with Azure

Welcome to the Microsoft Ignite 2025 session **PREL15: AI-Ready Apps - Containerize and Modernize with Azure**!

## 🎯 Overview

Modernize containerized apps with AI on Azure. This hands-on lab demonstrates how to quickly deploy powerful, flexible AI-powered applications to Azure Container Apps. You'll gain hands-on experience using Azure OpenAI and open-source models on serverless GPUs for cost-efficient AI inferencing, while securing enterprise-grade apps and ensuring compliance.

### What You'll Learn

- **Azure Container Apps**: Deploy containerized AI applications with serverless GPUs
- **Azure OpenAI Integration**: Build intelligent applications with GPT models using LangChain
- **Open-Source AI Models**: Run Ollama and local LLMs on GPU-enabled containers
- **Dynamic Sessions**: Execute untrusted code safely in isolated Python environments
- **AI Agent Development**: Build autonomous agents with MCP and Goose
- **Cost-Efficient AI**: Optimize AI inferencing with GPU-based compute
- **Enterprise Security**: Implement secure, compliant AI applications
- **Modern Development Practices**: Use Infrastructure as Code (IaC) and containerization

## 📚 Repository Structure

```
├── docs/           # Comprehensive documentation and MkDocs site
├── lab/            # Hands-on lab materials and instructions
│   ├── instructions/  # Step-by-step lab guides
│   └── README.md      # Lab overview and setup
├── src/            # Source code samples and templates
├── data/           # Sample data files
└── img/            # Images and diagrams
```

## 🚀 Getting Started

### Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed and configured
- WSL2 (Windows Subsystem for Linux) or Linux environment
- Python 3.12+
- VS Code or preferred IDE

### Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/Azure-Samples/ignite25-PREL15-ai-ready-apps-containerize-and-modernize-with-azure.git
   cd ignite25-PREL15-ai-ready-apps-containerize-and-modernize-with-azure
   ```

2. **Review the lab instructions**
   - See [`lab/README.md`](lab/README.md) for detailed setup and lab guide
   - Follow the step-by-step instructions in [`lab/instructions/`](lab/instructions/)

3. **Set up your Azure environment**
   - Ensure you have the required Azure resource providers registered
   - Configure your Azure CLI authentication

## 🧪 Lab Exercises

This lab consists of multiple segments covering:

1. **AI & GPU Playbook**: Understanding AI workloads and GPU acceleration on Azure
2. **Environment Setup**: Configure Azure resources and development environment
3. **Azure OpenAI Deployment**: Create and configure Azure OpenAI resources with GPT models
4. **Ollama & Open-Source Models**: Deploy local LLMs on serverless GPUs
5. **Dynamic Sessions**: Set up Azure Container Apps session pools for code execution
6. **MCP Shell Integration**: Implement Model Context Protocol for AI agents
7. **Goose AI Agent**: Build autonomous coding agents with Goose
8. **LangChain Integration**: Build AI-powered applications combining multiple AI services
9. **Testing & Deployment**: Test and deploy your containerized AI applications

See [`lab/README.md`](lab/README.md) for complete lab instructions.

## 📖 Documentation

Comprehensive documentation is available in the `/docs` directory and can be viewed as a MkDocs site:

```bash
pip install -r requirements.txt
mkdocs serve
```

Then navigate to `http://localhost:8000`

## 🔑 Key Technologies

- **Azure Container Apps**: Serverless container platform with GPU support and dynamic sessions
- **Azure OpenAI Service**: Enterprise-grade AI models (GPT-3.5/GPT-4)
- **Ollama**: Run open-source LLMs (Llama, Mistral, Phi) locally and on Azure
- **GPU Acceleration**: Serverless GPU compute for cost-efficient AI inferencing
- **LangChain**: Framework for building LLM-powered applications
- **MCP (Model Context Protocol)**: Connect AI agents to external tools and data
- **Goose AI Agent**: Autonomous coding agent for software development
- **Python**: Primary programming language
- **FastAPI**: Modern web framework for building APIs
- **Docker**: Containerization platform

## 📚 Learning Resources

| Topic | Link |
|:------|:-----|
| Azure Container Apps Overview | [https://learn.microsoft.com/azure/container-apps/overview](https://learn.microsoft.com/azure/container-apps/overview) |
| Azure OpenAI Service Documentation | [https://learn.microsoft.com/azure/ai-services/openai/overview](https://learn.microsoft.com/azure/ai-services/openai/overview) |
| Azure OpenAI Quickstart | [https://learn.microsoft.com/azure/ai-services/openai/quickstart](https://learn.microsoft.com/azure/ai-services/openai/quickstart) |
| Ollama Documentation | [https://ollama.com/](https://ollama.com/) |
| Azure Container Apps Dynamic Sessions | [https://learn.microsoft.com/azure/container-apps/sessions](https://learn.microsoft.com/azure/container-apps/sessions) |
| Code Interpreter in Dynamic Sessions | [https://learn.microsoft.com/azure/container-apps/sessions-code-interpreter](https://learn.microsoft.com/azure/container-apps/sessions-code-interpreter) |
| LangChain Python Documentation | [https://python.langchain.com/](https://python.langchain.com/) |
| LangChain Azure Integration | [https://python.langchain.com/docs/integrations/platforms/microsoft](https://python.langchain.com/docs/integrations/platforms/microsoft) |
| Model Context Protocol (MCP) | [https://modelcontextprotocol.io/](https://modelcontextprotocol.io/) |
| Azure Container Apps Security | [https://learn.microsoft.com/azure/container-apps/security](https://learn.microsoft.com/azure/container-apps/security) |
| Azure Well-Architected Framework | [https://learn.microsoft.com/azure/well-architected/](https://learn.microsoft.com/azure/well-architected/) |
| Learn at Ignite 2025 | [https://aka.ms/LearnAtIgnite](https://aka.ms/LearnAtIgnite) |
| Ignite 2025 Next Steps | [https://aka.ms/Ignite25-Next-Steps](https://aka.ms/Ignite25-Next-Steps?ocid=ignite25_nextsteps_cnl) | 
 

## 📋 Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Container Apps Dynamic Sessions](https://learn.microsoft.com/azure/container-apps/sessions)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/cognitive-services/openai/)
- [LangChain Documentation](https://python.langchain.com/)
- [Microsoft Ignite 2025](https://ignite.microsoft.com/)
- [Microsoft Learn At Ignite](https://aka.ms/LearnAtIgnite)
- [Ignite 2025 Next Steps](https://aka.ms/ignite25-next-steps)





## 🤝 Contributing

This project welcomes contributions and suggestions. Please see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details on our code of conduct.

## 📄 License

- Code: [MIT License](LICENSE)
- Documentation: [Creative Commons Attribution 4.0 License](LICENSE-DOCS)

## 🔒 Security

See [SECURITY.md](SECURITY.md) for information about reporting security vulnerabilities.

## 💬 Support

For support and questions, please see [SUPPORT.md](SUPPORT.md).

---

**Microsoft Ignite 2025** | Session PREL15

*Building the future of AI-ready applications with Azure*
