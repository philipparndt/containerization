//===----------------------------------------------------------------------===//
// Copyright © 2025-2026 Apple Inc. and the Containerization project authors.
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

import ContainerizationExtras

/// A network interface whose virtio-net device is backed by an open file
/// descriptor — a connected datagram socket whose peer is a userspace network
/// stack (e.g. gvisor-tap-vsock served over a vfkit unixgram socket). The VMM
/// exchanges raw ethernet frames with that stack, which terminates the guest's
/// TCP/IP and re-originates connections from the host. This enables transparent
/// host-network egress without a host bridge or NAT (the vfkit/gvproxy model).
public struct FileHandleInterface: Interface {
    public var ipv4Address: CIDRv4
    public var ipv4Gateway: IPv4Address?
    public var ipv6Address: CIDRv6?
    public var ipv6Gateway: IPv6Address?
    public var macAddress: MACAddress?
    public var mtu: UInt32

    /// File descriptor of the connected datagram socket backing the device.
    /// Ownership stays with the caller; the device wraps it without closing.
    public let fileDescriptor: Int32

    public init(
        fileDescriptor: Int32,
        ipv4Address: CIDRv4,
        ipv4Gateway: IPv4Address?,
        ipv6Address: CIDRv6? = nil,
        ipv6Gateway: IPv6Address? = nil,
        macAddress: MACAddress? = nil,
        mtu: UInt32 = 1500
    ) {
        self.fileDescriptor = fileDescriptor
        self.ipv4Address = ipv4Address
        self.ipv4Gateway = ipv4Gateway
        self.ipv6Address = ipv6Address
        self.ipv6Gateway = ipv6Gateway
        self.macAddress = macAddress
        self.mtu = mtu
    }
}
