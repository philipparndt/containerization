//===----------------------------------------------------------------------===//
// Copyright © 2026 Apple Inc. and the Containerization project authors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//===----------------------------------------------------------------------===//

import Foundation

/// A point-in-time view of the guest kernel's memory, read from the guest's
/// /proc/meminfo. Unlike container statistics (cgroup-scoped), these are
/// whole-VM numbers: with a virtio memory balloon attached, inflated balloon
/// pages count as used and reduce `availableBytes` while `totalBytes` stays
/// constant.
public struct GuestMemoryInfo: Sendable {
    /// MemTotal: total usable RAM of the guest.
    public let totalBytes: UInt64
    /// MemFree: completely unused pages.
    public let freeBytes: UInt64
    /// MemAvailable: the kernel's estimate of memory available for new
    /// workloads without swapping, including reclaimable page cache.
    public let availableBytes: UInt64

    /// Parse the fields out of /proc/meminfo content ("MemTotal: 8276352 kB").
    /// Returns nil when a required field is missing.
    public init?(procMeminfo text: String) {
        var fields: [Substring: UInt64] = [:]
        for line in text.split(separator: "\n") {
            let parts = line.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 2, parts[0].hasSuffix(":"), let value = UInt64(parts[1]) else {
                continue
            }
            // /proc/meminfo values are in kB (KiB).
            fields[parts[0].dropLast()] = value * 1024
        }
        guard let total = fields["MemTotal"],
            let free = fields["MemFree"],
            let available = fields["MemAvailable"]
        else {
            return nil
        }
        self.totalBytes = total
        self.freeBytes = free
        self.availableBytes = available
    }
}
