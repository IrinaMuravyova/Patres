//
//  NetworkMonitor.swift
//  Patres
//
//  Created by Irina Muravyeva on 07.03.2025.
//

import Network
import Combine

class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)  
    
    var isConnected: Bool {
        isConnectedSubject.value
    }
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnectedSubject.send(path.status == .satisfied)
        }
        monitor.start(queue: queue)
    }
}
