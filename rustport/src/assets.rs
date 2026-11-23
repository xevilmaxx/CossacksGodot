//! Donor asset readers, executed at runtime against the donor install path.
//!
//! Planned formats (private use only - never copy donor bytes into the repo):
//! * DXT1/3/5 `.dds` textures
//! * `.oss` skinned animation (24-byte header + geom/weights/bone tracks)
//! * `.osm` static mesh (`IDP2`, section offsets at header longs 12/13/14)
//! * `.aaf` ASCII action ranges (`"name",start,end,morph`)
//!
//! Stub - implemented by T6-R05.
