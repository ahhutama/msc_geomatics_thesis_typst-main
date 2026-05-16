#import "../template.typ": *
#import "../other_tools/styled-blocks.typ": block-discussion, block-todo

= Related Work <chap:relatedwork>

In this chapter, an overview of the related work is provided. The first section discusses

== Historical Maps as Sources for Urban Transformation Studies
#highlight[Outline:]
- Role of historical topographic maps in studying urban change
  - Historical maps and their importance containing meaningful information about the past. Rich collection of historical maps in the western world, particularly in the Netherlands (e.g. TMK, Bonnebladen, Rivierkaart, Kadastrale Kaart 1832)
- Dutch historical mapping context: Bonnebladen map series
- Challenges in making digitized maps computationally accessible


== Feature Extraction from Historical Maps
#block-todo[Outline:]
- Overview of approaches: manual, rule-based, and automated
- Deep learning for historical map content extraction
  - Require large volume of labeled training data, which is often scarce for historical maps, especially for limited homogeneousmap corpus (e.g. municipality map series)
  - Existing pre-trained DL model are generic and not exclusive for historical maps (SAM2, ?)
- Specific challenges: cartographic heterogeneity, visual noise, degradation

=== Synthetic Training Data Generation
- The problem of scarce labeled training data for historical maps
- Unpaired image-to-image translation: CycleGAN
- Bootstrapping strategies for training data
- Limited map corpus (municipality map series)


== Urban Change Detection Methods (?) - digabung ga sama yang 2.1
Pixel-based vs. object-based change detection (OBCD)
Urban growth metrics and spatial analysis
Applying change detection to historical multi-temporal map data

== Map Accessibility and Geospatial Standards
#highlight[- Outline: (what has been done?)]
- IIIF as infrastructure for accessing historical map collections
  - Publication of Dutch historical maps as IIIF resources. Used by many institutions as standards.
- Georeferencing and IIIF tile services (Allmaps)
  - IIIF handle georeferencing. Institution able to georeference their maps. The georeferenced maps can also be accessed via IIIF. 










== Urban Transformation / Change Analysis
- Outline