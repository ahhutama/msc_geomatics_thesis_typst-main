#import "../template.typ": *

= Introduction <chap:intro>

== Motivation

== Objective

== Research Questions

This research aims to compare patch-based and object-based deep learning methods for automated urban extent extraction from multi-temporal Dutch Bonnebladen maps and assess their effectiveness for urban growth analysis.

Main research question of this research is:
_"To what extent do patch-based and object-based deep
learning approaches differ in their effectiveness for extracting urban extent from multi-temporal
Dutch historical topographic maps for enabling urban growth analysis"_


Sub-research question:
1. "How can patch-based classification method be adapted for nation-wide urban extent extraction from Dutch Bonnebladen maps?"
2. "How can object-based classification method be adapted for building block geometries extraction from Dutch Bonnebladen maps?"
3. "What is the accuracy and reliability of patch-based versus object-based classification to detect urban extent in historical topographic maps?”
4. "How do extraction results vary across different time periods of the Dutch Bonnebladen map series?"
5. "What spatial analysis methods can be applied to extracted urban extent to quantify and characterize urban growth patterns across multiple temporal periods?"
6. "What are the relative strengths, limitations, and trade-offs between patch-level and object-level approaches for urban extent extraction?"

== Scope of Research

- Due to the nature and limitation of historical maps, several types of analysis are out of scope, e.g. vertical urban densification, instance-level building tracking, analysis of specific building transformation types (demolition, construction, merging, splitting) 
- Digitization and georeferencing of historical maps (pre-georeferenced maps via IIIF will be used)
- Use of additional historical data sources (cadastral records, building registries, textual archives)


== Thesis Outline

[todo]

The thesis document is structured into 6 chapters. Following the introduction, the theoretical background knowledge is presented in @chap:relatedwork[Chapter] that is needed to understand the implementation of the U-Net as well as related research outcomes. In @chap:methodology[Chapter], an overview of the employed methodology is given to outline each working step of collecting data, preprocessing data, and analyzing the results. Based on this, the technical implementation of the methodology is explained in detail in Chapter 4. Furthermore, it defines the study area and the data used for the implementation. Moreover, the technical modifications of the employed U-Net are described. Following this, the results of the model are summarized and analyzed in Chapter 5. In the final chapter (Chapter 6), the results are summarized and discussed by answering the research questions. Additionally, the contribution of this thesis to current research is described as well as suggestions for potential future work.