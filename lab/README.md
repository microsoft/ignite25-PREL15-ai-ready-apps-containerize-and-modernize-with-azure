

These instructions support the instructor-led workshop **AI-Ready Apps: Containerize and Modernize with Azure**. The self-paced version is available in this repository for builders who want to explore GPU-powered Azure Container Apps, Ollama, and MCP session pools on their own schedule.

## Abstract

Modernize containerized applications with Azure by combining serverless GPUs, Azure OpenAI, and open-source models. You will deploy image generation workloads, retrofit existing services with Azure OpenAI, operate Ollama as a self-hosted model server, stand up MCP shell session pools, and finish by launching the Goose open-source agent on Azure Container Apps.

> [Click here to get to the lab instructions](./instructions/instructions.md)

## Pre-Requisites (Quick Check)

- Laptop with modern Chromium-based browser and the ability to run Azure Cloud Shell or local CLI tools
- Access to an Azure subscription with GPU workload profile quota and rights to deploy Azure Container Apps resources
- Azure CLI (with Container Apps extension), Azure Developer CLI (`azd`), and optionally Git installed and authenticated

## Learning Outcomes

- Map AI-ready workload patterns to Azure Container Apps GPU profiles and cost controls
- Deploy and operate a GPU-backed image generation application end to end
- Integrate Azure OpenAI into an existing containerized service with enterprise guardrails
- Reconfigure a GPU Container App to run Ollama and exercise the REST API
- Provision MCP shell session pools and automate remote execution via JSON-RPC
- Deploy the Goose agent stack with Azure Developer CLI and connect it to Ollama and optional MCP extensions
- Apply observability, scaling, and cold-start mitigation tactics for ACA GPU workloads

## Lab Structure

The workshop is organized into segments. Start with the overview in `lab/instructions/instructions.md`, then follow the linked markdown files for each segment (0–5) to complete the exercises at your own pace.

## Getting Started

Clone or fork this repository, review the segment guidance under `lab/instructions/`, and work through the segments in order. Segment 0 provides a 15-minute refresher before you provision the first GPU workloads in Segment 1.

## Discussions

Build your first agent with Azure AI Agent Service is an open source project supported by Microsoft. See the [SUPPORT.md](../SUPPORT.md) file for details on how to raise issues or contribute. If you enjoyed this workshop please give the repository a ⭐ and share it with others.

## Source Code

The source code for this session can be found in the [src](../src) folder of this repo.
