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
import Testing

@testable import Containerization

struct GuestMemoryInfoTests {

    @Test func parsesProcMeminfo() {
        let text = """
            MemTotal:        8276352 kB
            MemFree:          661584 kB
            MemAvailable:     662660 kB
            Buffers:             572 kB
            Cached:            84512 kB
            SwapTotal:             0 kB
            """
        let info = GuestMemoryInfo(procMeminfo: text)
        #expect(info != nil)
        #expect(info?.totalBytes == 8_276_352 * 1024)
        #expect(info?.freeBytes == 661_584 * 1024)
        #expect(info?.availableBytes == 662_660 * 1024)
    }

    @Test func rejectsMeminfoWithoutRequiredFields() {
        #expect(GuestMemoryInfo(procMeminfo: "MemTotal: 100 kB\nMemFree: 50 kB") == nil)
        #expect(GuestMemoryInfo(procMeminfo: "") == nil)
        #expect(GuestMemoryInfo(procMeminfo: "garbage\nlines here") == nil)
    }

    @Test func toleratesMalformedLines() {
        let text = """
            MemTotal:        8276352 kB
            broken line without colon value
            MemFree          missing colon 10
            MemFree:          661584 kB
            MemAvailable:     662660 kB
            """
        let info = GuestMemoryInfo(procMeminfo: text)
        #expect(info?.freeBytes == 661_584 * 1024)
    }
}
