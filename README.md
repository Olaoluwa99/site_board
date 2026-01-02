# SiteBoard: Intelligent Site Monitoring & AI Analytics

<div align="center">

**Senior Mobile Engineer | Flutter & AI Integration**
*An offline-first, intelligent dashboard for on-site management and data visualization.*

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Olaoluwa%20Odewale-blue?style=flat&logo=linkedin)](https://linkedin.com/in/olaoluwa-odewale)
[![GitHub](https://img.shields.io/badge/GitHub-Olaoluwa99-black?style=flat&logo=github)](https://github.com/Olaoluwa99/site_board)
[![Email](https://img.shields.io/badge/Email-Contact%20Me-red?style=flat&logo=gmail)](mailto:Olaoluwadaniel99@gmail.com)

</div>

---

## 📖 Project Overview
**SiteBoard** is a robust cross-platform mobile application designed to streamline site management and reporting. It leverages **Generative AI** to convert raw data into actionable summaries and visualizes complex metrics through interactive charts.

Engineered with an **Offline-First** mindset, the app ensures critical data remains accessible even in remote locations with poor connectivity, syncing seamlessly once the connection is restored.

---

## 🛠 Tech Stack & Architecture

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![BLoC](https://img.shields.io/badge/State-BLoC-red?style=for-the-badge&logo=code&logoColor=white)
![Hive](https://img.shields.io/badge/DB-Hive%20NoSQL-orange?style=for-the-badge&logo=firebase&logoColor=white)
![fpdart](https://img.shields.io/badge/FP-fpdart-green?style=for-the-badge&logo=haskell&logoColor=white)
![Clean Architecture](https://img.shields.io/badge/Arch-Clean-blueviolet?style=for-the-badge)

---

## 📱 Application Showcase

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="left" width="120">
      <img src="https://github.com/user-attachments/assets/ed9a1bdc-c609-4453-9df3-e37d00e72e29" width="100" alt="SiteBoard Logo" />
    </td>
    <td align="right" valign="middle">
      <img src="https://img.shields.io/badge/Status-Work_In_Progress-orange?style=flat-square&height=30" height="30" alt="WIP" />
      <br/>
      <sub>Target Platform: Android & iOS</sub>
    </td>
  </tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="50%" align="center">
        <img src="https://github.com/user-attachments/assets/ad635f6c-b620-4afc-b679-401fe19fa6d8" width="95%" alt="Screen 1" />
    </td>
    <td width="50%" align="center">
        <img src="https://github.com/user-attachments/assets/f7b3487a-6333-485a-8ad1-2c4193b94ac4" width="95%" alt="Screen 2" />
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
        <img src="https://github.com/user-attachments/assets/39662a25-6e1d-43bc-819d-922ed393768d" width="95%" alt="Screen 3" />
    </td>
    <td width="50%" align="center">
        <img src="https://github.com/user-attachments/assets/a1855a5e-33a1-4c80-af79-b112be990d12" width="95%" alt="Screen 4" />
    </td>
  </tr>
</table>

---

## 🔍 Technical Deep Dive

### 🏗 Architecture: Clean Architecture + Functional Programming
This project enforces strict separation of concerns using Clean Architecture, enhanced by **Functional Programming** concepts.
* **fpdart Integration:** Utilized the `Either<Failure, Success>` monad to handle errors gracefully without `try-catch` blocks cluttering the domain layer.
* **Type Safety:** Strictly typed entity modeling ensures data integrity across the UI, Domain, and Data layers.

### ⚡ Offline-First Strategy (Hive)
To support users in remote areas:
* **Local Caching:** All data is persisted locally using **Hive**, a lightweight and fast NoSQL database.
* **Sync Logic:** A repository pattern mediates between the local data source and remote API, serving cached data immediately while fetching updates in the background.

### 🤖 AI & Visualization
* **AI Summaries:** Integrated LLMs to process site logs and generate concise, human-readable daily reports.
* **Data Viz:** Custom-built charts provide real-time visual feedback on site progress and resource allocation.

---

## 🤝 Roadmap
- [x] Core Architecture Setup (Clean Arch + BLoC)
- [x] Local Database Implementation (Hive)
- [x] AI Summary Generation
- [ ] Push Notifications
- [ ] iOS Production Build
- [ ] Dark Mode Polish

---

<div align="center">
  <sub>Created by Olaoluwa Daniel Odewale - 2026</sub>
</div>
