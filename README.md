# ReAct Agent - Flutter

A Flutter migration of the `swift-ai-agent-demo-1905` SwiftUI app. Demonstrates the **ReAct (Reasoning + Acting)** AI agent pattern using OpenAI GPT models, with step-by-step reasoning visualization and tool-based actions.

## Features

- **ReAct Agent Loop**: Iteratively thinks, acts with tools, observes results, and produces a final answer.
- **Tool Support**: Basic arithmetic calculations, file read/write in temp directory, and current time retrieval.
- **Real-time Timeline**: Live visualization of agent steps (thought, action, observation, final answer, error) with icons, colors, and timestamps.
- **Single-screen UI**: Card-based step timeline with auto-scrolling, matching the original SwiftUI design pixel-perfectly.

## Getting Started

### Prerequisites

- Flutter SDK ^3.7.0
- An OpenAI API key

### Running the App

Pass your OpenAI API key via `--dart-define`:

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-your-key-here
```

**Important**: Do not embed your API key in source code. Always use `--dart-define` at runtime.

### iOS Only

This app is designed for iOS. Run on an iOS simulator or device:

```bash
flutter run -d ios --dart-define=OPENAI_API_KEY=sk-your-key-here
```

## Architecture

The app follows an MVVM-like architecture mirroring the original SwiftUI implementation:

- **`lib/config/`** - Configuration (API key via `String.fromEnvironment`)
- **`lib/features/react_agent/domain/`** - Domain models (`AgentStep`, `AgentTool`, `ChatMessage`)
- **`lib/features/react_agent/services/`** - Business logic (`AgentService` for the ReAct loop, `OpenAIChatService` for OpenAI API)
- **`lib/features/react_agent/presentation/`** - UI (`ReactAgentScreen`, `StepCard`, `ReactAgentController`)
