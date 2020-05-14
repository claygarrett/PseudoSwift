
class Connection {
    let sourceOutlet: ValueOutlet
    let destintationOutlet: ValueOutlet
    let wire: Wire
    
    init(sourceOutlet: ValueOutlet, destintationOutlet: ValueOutlet, wire: Wire) {
        self.sourceOutlet = sourceOutlet
        self.destintationOutlet = destintationOutlet
        self.wire = wire
    }
    
    func clear() {
        self.wire.view.removeFromSuperview()
    }
}
