//
//  File.swift
//  
//
//  Created by Nickolay Truhin on 20.03.2021.
//

import Foundation
import Botter
import Vapor

class OrdersNodeController: NodeController {
    func create(app: Application) throws -> EventLoopFuture<Node> {
        Node.create(
            systemic: true,
            name: "Orders node",
            messagesGroup: .list(.orders),
            entryPoint: .orders, app: app
        )
    }
    
    func getListSendMessages(platform: AnyPlatform, in node: Node, _ payload: NodePayload?, context: PhotoBotContextProtocol, listType: MessageListType, indexRange: Range<Int>) throws -> EventLoopFuture<([SendMessage], Int)>? {
        guard listType == .orders else { return nil }
        let (app, user) = (context.app, context.user)
        
        return OrderModel.query(on: app.db).count().flatMap { count in
            OrderModel.query(on: app.db).range(indexRange).all().throwingFlatMap { orders in
                try orders.enumerated().map { (index, model) -> Future<SendMessage> in
                    try Order.create(other: model, app: app).flatMap { order in
                        order.state(app: app).flatMap { orderState in
                            context.user.nodePayload = .checkout(orderState)
                            return MessageFormatter.shared.format(
                                [
                                    "Заказ от @" + .replacing(by: .username) + " (" + .replacing(by: .orderId) + "):",
                                    .replacing(by: .orderBlock),
                                    .replacing(by: .priceBlock),
                                ].joined(separator: "\n"),
                                platform: platform,
                                context: context
                            ).flatMapThrowing { text in
                                SendMessage(
                                    text: text,
                                    keyboard: [ (!order.isCancelled && user.isAdmin) ? [
                                        try .init(text: "Отменить", action: .callback, eventPayload: .cancelOrder(id: order.id!))
                                    ] : []]
                                )
                            }
                        }
                    }
                }.flatten(on: app.eventLoopGroup.next())
            }
            .map { ($0, count) }
        }
    }

    func handleEventPayload(_ event: MessageEvent, _ eventPayload: EventPayload, _ replyText: inout String, context: PhotoBotContextProtocol) throws -> EventLoopFuture<[Message]>? {
        guard case let .cancelOrder(orderId) = eventPayload else { return nil }
        
        let (app, user, platform, bot) = (context.app, context.user, context.platform, context.bot)
        
        return OrderModel.find(orderId, on: app.db)
            .unwrap(or: PhotoBotError.orderByIdNotFound)
            .flatMap { order in
            
                order.isCancelled = true
                
                return order.save(on: app.db).throwingFlatMap { _ in
                    try user.pushToActualNode(to: event, context: context)
                }.flatMap { messages in
                    order.fetchWatchers(app: app).flatMap { watchers in
                        order.state(app: app).flatMap { orderState in
                            
                            func getMessage(_ platform: AnyPlatform) -> Future<String> {
                                context.user.nodePayload = .checkout(orderState)
                                return MessageFormatter.shared.format(
                                    [
                                        "Заказ был отменен от @" + .replacing(by: .username) + " (" + .replacing(by: .orderId) + "):",
                                        .replacing(by: .orderBlock),
                                        .replacing(by: .priceBlock),
                                    ].joined(separator: "\n"),
                                    platform: platform, context: context
                                )
                            }
                            
                            return watchers.map { watcher in
                                let platformIds = watcher.platformIds
                                
                                let platformId = platformIds.first(for: platform) ?? platformIds.first!
                                return getMessage(platformId.any).throwingFlatMap { text in
                                    try bot.sendMessage(.init(
                                        destination: platformId.sendDestination,
                                        text: text
                                    ), platform: platformId.any, context: context)
                                }
                            }.flatten(on: app.eventLoopGroup.next()).map { messages + $0.reduce([], +) }
                        }
                    }.map { messages + $0 }
                }
        }
    }
    
}
