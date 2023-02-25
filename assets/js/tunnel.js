import { MembraneWebRTC } from '@jellyfish-dev/membrane-webrtc-js'

export default class Tunnel {
  constructor (lv) {
    this.lv = lv
    this.localStream = ''

    this.webrtc = new MembraneWebRTC({
      callbacks: {
        onSendMediaEvent: (mediaEvent) => {
          this.lv.pushEvent('mediaEvent', { data: mediaEvent })
        },
        onJoinSuccess: (peerId, peersInRoom) => {
          this.localStream.getTracks().forEach((track) =>
            this.webrtc.addTrack(track, this.localStream)
          )

        },
        onTrackReady: ({ stream, peer, metadata }) => {
          document.querySelector('#remote-stream').srcObject = stream
        }
      }
    })

    this.lv.handleEvent('mediaEvent', (event) => {
      this.webrtc.receiveMediaEvent(event.event)
    })
  }

  join = async () => {
    this.localStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true })
    this.webrtc.join({})
  }
}
