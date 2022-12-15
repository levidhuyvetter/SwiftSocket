#if os(Linux) || os(FreeBSD)
    import Glibc
#else
    import Darwin
#endif

public class Socket {
    private var socket:Int32
    
    public init() {
        #if os(Linux) || os(FreeBSD)
        let type = Int32(1)
        let proto = AF_INET
        self.socket = Glibc.socket(proto, type, 0)
        #else
        let type = SOCK_STREAM
        let proto = AF_INET
        self.socket = Darwin.socket(proto, type, 0)
        #endif
    }
    
    public func bind(port:UInt16) {
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t((port << 8) + (port >> 8))
        addr.sin_addr = in_addr(s_addr: in_addr_t(0))
        addr.sin_zero = (.zero, .zero, .zero, .zero, .zero, .zero, .zero, .zero)
        withUnsafePointer(to: &addr) { addrInPtr in
            let addrPtr = UnsafeRawPointer(addrInPtr).assumingMemoryBound(to: sockaddr.self)
            #if os(Linux) || os(FreeBSD)
            Glibc.bind(self.socket, addrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            #else
            Darwin.bind(self.socket, addrPtr, socklen_t(MemoryLayout<sockaddr_in>.size))
            #endif
        }
    }
    
    public func listen(_ cb:@escaping(String)->String) {
        #if os(Linux) || os(FreeBSD)
        Glibc.listen(self.socket, 5)
        #else
        Darwin.listen(self.socket, 5)
        #endif
        
        repeat {
            let client = accept(self.socket, nil, nil)
            let data = cb("")
            _ = data.withCString { ptr in
                send(client, ptr, Int(data.count), 0)
            }
            close(client)
        } while self.socket > -1
    }
}
