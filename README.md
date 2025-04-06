<!--
SPDX-FileCopyrightText: 2025 Benoît Rolandeau <benoit.rolandeau@allcircuits.com>

SPDX-License-Identifier: MIT
-->

# esaip-lessons-server <!-- omit from toc -->

## Table of contents

- [Table of contents](#table-of-contents)
- [Presentation](#presentation)
- [Features](#features)

## Presentation

This project implements a **REST API server in Dart** for managing a smart home system. It supports retrieving houses and rooms, managing electricity states, and logging HTTP requests. Designed to be extendable with real-time WebSocket support

---

##  Features

- REST API with Shelf and Shelf Router
- Simulated in-memory data for houses and rooms
- Structured logging for requests
- Pre-configured versioned routes (`/api/v1`)
- Supports both "Mobile App" and "Things App" server ports
- Architecture supports WebSocket extension
---





