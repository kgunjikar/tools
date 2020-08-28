package rx

import (
	"github.com/google/gopacket"
	"github.com/google/gopacket/pcap"
	"github.com/kgunjikar/kstack/ip"
)

var intName string
var packetSize int32

//RxInit
func RxInit() {
	rxConfig()
	rxStart()
}

func rxConfig() {
	intName = "eth0"
	packetSize = 1600
}

func rxStart() {
	if handle, err := pcap.OpenLive(intName, packetSize, true, pcap.BlockForever); err != nil {
		panic(err)
	} else if err := handle.SetBPFFilter("tcp and port 80"); err != nil { // optional
		panic(err)
	} else {
		packetSource := gopacket.NewPacketSource(handle, handle.LinkType())
		for packet := range packetSource.Packets() {
			ip.HandlePacket(packet) // Do something with a packet here.
		}
	}
}
