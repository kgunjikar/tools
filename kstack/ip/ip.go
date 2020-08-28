package ip

import (
	"fmt"

	"github.com/google/gopacket"
)

//HandlePacket
func HandlePacket(pkt gopacket.Packet) error {
	fmt.Printf("%v Received packet")
	return nil
}
