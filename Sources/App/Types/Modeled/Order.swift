//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 06.03.2021.
//

import Foundation
import ValidatedPropertyKit
import Botter
import Vapor
import Fluent

final class Order: OrderProtocol {
    
    typealias TwinType = OrderModel
    
    var id: UUID?
    var stylistId: UUID?
    var makeuperId: UUID?
    var studioId: UUID?
    var interval: DateInterval = .init()
    var price: Int = 0
    
    required init() {}
    
}

extension Order: ModeledType {
    var isValid: Bool {
        true
    }
    
    func save(app: Application) throws -> EventLoopFuture<TwinType> {
        guard isValid else {
            throw ModeledTypeError.validationError(self)
        }
        return try TwinType.create(other: self, app: app)
    }
}
