# AI-Ready Apps: Containerize and Modernize with Azure

[![Microsoft Ignite 2025](img/banner.png)](https://ignite.microsoft.com/)

Welcome to the Microsoft Ignite 2025 session **PREL15: AI-Ready Apps - Containerize and Modernize with Azure**!

## 🎯 Overview

This hands-on lab demonstrates how to build, containerize, and deploy AI-powered applications using Azure Container Apps Dynamic Sessions. You'll learn to integrate Azure OpenAI with Python applications, manage code execution in secure sandboxed environments, and modernize applications for the cloud.

### What You'll Learn

- **Azure Container Apps Dynamic Sessions**: Execute untrusted code safely in isolated Python environments
- **Azure OpenAI Integration**: Build intelligent applications with GPT models using LangChain
- **Cloud-Native Architecture**: Design and deploy scalable, AI-ready applications
- **Secure Code Execution**: Implement sandboxed environments for dynamic code execution
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

1. **Environment Setup**: Configure Azure resources and development environment
2. **Azure OpenAI Deployment**: Create and configure Azure OpenAI resources
3. **Dynamic Sessions**: Set up Azure Container Apps session pools
4. **LangChain Integration**: Build AI-powered applications with code execution
5. **Testing & Deployment**: Test and deploy your containerized application

See [`lab/README.md`](lab/README.md) for complete lab instructions.

## 📖 Documentation

Comprehensive documentation is available in the `/docs` directory and can be viewed as a MkDocs site:

```bash
pip install -r requirements.txt
mkdocs serve
```

Then navigate to `http://localhost:8000`

## 🔑 Key Technologies

- **Azure Container Apps**: Serverless container platform with dynamic sessions
- **Azure OpenAI Service**: Enterprise-grade AI models (GPT-3.5/GPT-4)
- **LangChain**: Framework for building LLM-powered applications
- **Python**: Primary programming language
- **FastAPI**: Modern web framework for building APIs
- **Docker**: Containerization platform

## 📋 Additional Resources

- [Azure Container Apps Documentation](https://learn.microsoft.com/azure/container-apps/)
- [Azure Container Apps Dynamic Sessions](https://learn.microsoft.com/azure/container-apps/sessions)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/cognitive-services/openai/)
- [LangChain Documentation](https://python.langchain.com/)
- [Microsoft Ignite 2025](https://ignite.microsoft.com/)

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
