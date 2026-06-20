# iOS Movie Application

An iOS application built to explore and discover movies using The Movie Database (TMDB) API. This project demonstrates professional iOS development practices, focusing on clean architecture, reactive programming, and robust network state handling.

## General Plans

- **Architecture:** MVVM (Model-View-ViewModel)
- **Features:** Core movie browsing, detailed movie views, and proper error handling.

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Install Dependencies

Install the required CocoaPods dependencies:

```bash
pod install
```

Then open the workspace file:

```bash
open MovieApp.xcworkspace
```

### 3. Configure TMDB API Key

Open the following configuration file:

```text
Resource+DefaultsFile/Configurations/Dev.xcconfig
```

Update the values below:

```text
BASE_URL=https://api.themoviedb.org/3
TMDB_API_KEY=set_api_key_here
```

Replace:

```text
TMDB_API_KEY=set_api_key_here
```

with your actual TMDB API key.

### 4. Run the Application

Build and run the project using Xcode.