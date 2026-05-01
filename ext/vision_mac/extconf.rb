# frozen_string_literal: true

require "swift_gem/mkmf"

SwiftGem::Mkmf.create_swift_makefile(
  "vision_mac/vision_mac",
  package: "VisionMac",
  source_dir: __dir__
)
