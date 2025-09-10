# FPGA-Based Object Detection & Targeting System

**ECE 554 Capstone Project**  

[Award Article](https://engineering.wisc.edu/blog/student-innovation-and-alumni-experience-converge-at-ece-capstone-design-open-house/)

[Code Repository](https://github.com/hmrdo/ECE554-Capstone-Project)  
[Project Website](https://hmrdo.github.io/air-defense-project.github.io/)


---

## Overview

As part of a semester-long project, I collaborated with four classmates to design and implement an integrated hardware system that delivers real-time object detection and precise targeting. The primary constraint was the mandatory use of the Terasic DE1-SOC Cyclone V FPGA development board.

This project focused on leveraging hardware capabilities to achieve fast and accurate object detection, coupled with dynamic targeting via servo-driven laser positioning.

---

## Project Goals

- **Camera Integration**: Utilize the Terasic TRDB-D5M camera to capture real-time video.
- **FPGA Processing**: Implement real-time hardware logic for object detection through frame differencing.
- **Laser Targeting**: Control a servo-driven laser that dynamically points at detected objects.
- **Visualization**: Output real-time detection overlays via VGA to a monitor for easier debugging and demonstration.

---

## System Components

The system was divided into four primary modules:

1. **Object Tracking**: Detect and track moving objects within video frames.
2. **Coordinate Translation**: Convert detected pixel positions into real-world 3D coordinates.
3. **Laser Module**: Control a servo motor to position the laser accurately based on calculated coordinates.
4. **Top-Level State Machine**: Manage integration and coordination of all subsystems.

---

## Technical Approach

The FPGA hardware receives input frames from the camera, performs frame differencing to detect objects, and generates an "object detected" signal along with the object's x and y pixel coordinates.

These pixel coordinates are then processed by the coordinate translation module, converting them into accurate 3D positions. The resulting coordinates feed into the laser module, instructing the servo to align a laser pointer to the detected object in real-time.

Additionally, the VGA output provides a visual overlay, marking detected objects with bounding boxes, facilitating demonstration and debugging.

---

## Key Learnings

Throughout this project, our team gained substantial expertise in:

- FPGA development, specifically with the Terasic DE1-SOC Cyclone V board.
- Developing and optimizing computer vision algorithms.
- Integrating servo motors and Arduino controllers for precise mechanical control.
- Collaborative development practices, communication strategies, and the full software development lifecycle.

---

## Recognition

Due to our commitment and the project's technical excellence, our team received recognition from our professor for outstanding design and implementation, distinguishing us among numerous excellent projects presented by our peers.
