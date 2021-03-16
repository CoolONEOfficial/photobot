//
//  File.swift
//
//
//  Created by Nickolay Truhin on 24.02.2021.
//

import Foundation
import Fluent

final class PromotionModel: Model, PromotionProtocol {
    typealias TwinType = Promotion

    static let schema = "promotions"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "auto_apply")
    var autoApply: Bool

    @Field(key: "name")
    var name: String?

    @Field(key: "description")
    var description: String?
    
    @Field(key: "promocode")
    var promocode: String?
    
    @Field(key: "impact")
    var impact: PromotionImpact!
    
    @Field(key: "condition")
    var condition: PromotionCondition!

    required init() { }
}
