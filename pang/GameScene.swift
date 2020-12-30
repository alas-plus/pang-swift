//
//  GameScene.swift
//  pang
//
//  Created by Steven Hughes on 12/13/20.
//

import SpriteKit
import GameplayKit

let wallCategory : UInt32 = 1 << 0
let paddleCategory : UInt32 = 1 << 1

class Walls : SKNode {
    
    private var top, bottom : SKShapeNode
    private var topPos, bottomPos : CGPoint
    private var wallSize : CGSize
    
    init(name : String, scene : GameScene) {
        topPos = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.985)
        bottomPos = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.015)
        wallSize =  CGSize(width: scene.size.width, height: scene.size.height * 0.025)
        
        let topPhysicsBody = SKPhysicsBody(rectangleOf: wallSize)
        topPhysicsBody.affectedByGravity = false;
        topPhysicsBody.isDynamic = false;
        topPhysicsBody.collisionBitMask = wallCategory
        topPhysicsBody.contactTestBitMask = wallCategory

        let bottomPhysicsBody = SKPhysicsBody(rectangleOf: wallSize)
        bottomPhysicsBody.affectedByGravity = false;
        bottomPhysicsBody.isDynamic = false;
        bottomPhysicsBody.collisionBitMask = wallCategory
        bottomPhysicsBody.contactTestBitMask = wallCategory
            
        top = SKShapeNode(rectOf: wallSize)
        top.name = "\(name)_top"
        top.fillColor = SKColor.white
        top.position = topPos
        top.physicsBody = topPhysicsBody
        
        bottom = SKShapeNode(rectOf: wallSize)
        bottom.name = "\(name)_bottom"
        bottom.fillColor = SKColor.white
        bottom.position = bottomPos
        bottom.physicsBody = bottomPhysicsBody
        
        super.init()
        
        self.addChild(top)
        self.addChild(bottom)
        
        scene.addChild(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Ball {
    private var ball : SKShapeNode
    private var ballRadius, ballSpeed, ballAngle, goalRight, goalLeft : CGFloat
    private var ballOrigin : CGPoint
    
    init(name : String, scene : GameScene) {
        ballRadius = scene.size.height * 0.01
        ballOrigin = CGPoint(x: scene.size.width * 0.5, y: scene.size.height * 0.5)
        ballSpeed = scene.size.height * 0.005
        ballAngle = CGFloat.random(in: 0.00 ... 360.0)
        
        goalLeft = 0
        goalRight = scene.size.width
        
        ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.name = name
        ball.fillColor = SKColor.white
        ball.position = ballOrigin
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.allowsRotation = false
        ball.physicsBody?.friction = 0
        ball.physicsBody?.restitution = 1
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.collisionBitMask = wallCategory | paddleCategory
        ball.physicsBody?.contactTestBitMask = wallCategory | paddleCategory
        
        scene.addChild(ball)
        moveBall()
    }
    
    func resetBall() {
        ball.position = ballOrigin
        ballAngle += 1 // CGFloat.random(in: 0.00 ... 360.0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        moveBall()
    }
    
    func moveBall() {
        var step, theta, bX, bY : CGFloat
        var normalizedAngle = ballAngle.truncatingRemainder(dividingBy: 360.0)
        if normalizedAngle < 0 {
            normalizedAngle = 360.0 + normalizedAngle
        }
        if normalizedAngle <= 90 {
            step = 0
        } else if normalizedAngle <= 180 {
            step = 180
        } else if normalizedAngle <= 270 {
            step = 270
        } else {
            step = 360
        }
        // Get x and y components of vector
        theta = abs(step - normalizedAngle)
        bX = cos(theta) * ballSpeed
        bY = sin(theta) * ballSpeed
        
        ball.physicsBody?.applyImpulse(CGVector(dx: bX, dy: bY))
    }
}

class Paddle : SKNode{
    private var paddle : SKShapeNode
    private var paddleSpeed, paddleWidth, paddleHeight, paddleCeiling, paddleFloor : CGFloat
    private var paddleOrigin : CGPoint
    
    init(name : String, right: Bool, scene : GameScene) {
        paddleSpeed = scene.size.height * 0.001
        paddleWidth = scene.size.width * 0.025
        paddleHeight = scene.size.height * 0.2
        paddleCeiling = (scene.size.height * 0.97) - (0.5 * paddleHeight)
        paddleFloor = 0 + (0.5 * paddleHeight) + (scene.size.height * 0.03)
        
        if right {
            paddleOrigin = CGPoint(x: scene.size.width * 0.05, y: scene.size.height * 0.5)
        } else {
            paddleOrigin = CGPoint(x: scene.size.width * 0.95, y: scene.size.height * 0.5)
        }
        
        
        paddle = SKShapeNode(rectOf: CGSize(width: paddleWidth, height: paddleHeight))
        paddle.name = name
        paddle.fillColor = SKColor.white
        paddle.position = paddleOrigin
        
        paddleSpeed = scene.size.height / 20
        
        paddle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: paddleWidth, height: paddleHeight))
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.allowsRotation = false
        paddle.physicsBody?.friction = 1
        paddle.physicsBody?.linearDamping = 1
        paddle.physicsBody?.restitution = 0
        paddle.physicsBody?.collisionBitMask = paddleCategory
        paddle.physicsBody?.contactTestBitMask = paddleCategory
        
        let paddleRangeY = SKConstraint.positionY(SKRange(lowerLimit: paddleFloor, upperLimit: paddleCeiling))
        let paddleRangeX = SKConstraint.positionX(SKRange(lowerLimit: paddleOrigin.x, upperLimit: paddleOrigin.x))
        paddle.constraints = [ paddleRangeX, paddleRangeY ]
        
        super.init()
        
        self.addChild(paddle)
        scene.addChild(self)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movePlayer(upPressed : Bool, downPressed : Bool) {
        if upPressed && !downPressed {
            // Move up
//            paddle.position.y = min(paddleCeiling, paddle.position.y + paddleSpeed)
            paddle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: paddleSpeed))
        } else if downPressed && !upPressed {
            // Move down
//            paddle.position.y = max(paddleFloor, paddle.position.y - paddleSpeed)
            paddle.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -paddleSpeed))
        } else {
            paddle.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        }
    }
    
}

class GameScene: SKScene {
    private var playerOne : Paddle!
    private var playerTwo : Paddle!
    private var walls : Walls!
    private var ball : Ball!

    private var upPressed = false
    private var downPressed = false
    
    override func didMove(to view: NSView) {
        walls = Walls(name: "walls", scene: self)
        playerOne = Paddle(name: "playerOne", right: true, scene: self)
        playerTwo = Paddle(name: "playerTwo", right: false, scene: self)
        ball = Ball(name: "ball_sprite", scene: self)
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 125: // down
            downPressed = true
        case 126: // up
            upPressed = true
        case 049: // space
            ball.resetBall()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 125: // down
            downPressed = false
        case 126: //up
            upPressed = false
        default:
            print("keyUp: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        playerOne.movePlayer(upPressed: upPressed, downPressed: downPressed)
        playerTwo.movePlayer(upPressed: upPressed, downPressed: downPressed)
//        ball.update()
        moveEnemy()
    }
    
    func initializePlayer() {
    }
    
    func moveEnemy() {
        
    }
    
//    override func didMove(to view: SKView) {
//
//        // Get label node from scene and store it for use later
//        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
//        if let label = self.label {
//            label.alpha = 0.0
//            label.run(SKAction.fadeIn(withDuration: 2.0))
//        }
//
//        // Create shape node to use during mouse interaction
//        let w = (self.size.width + self.size.height) * 0.05
//        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
//
//        if let spinnyNode = self.spinnyNode {
//            spinnyNode.lineWidth = 2.5
//
//            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
//            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
//                                              SKAction.fadeOut(withDuration: 0.5),
//                                              SKAction.removeFromParent()]))
//        }
//    }
//
//
//    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
//    }
//
//    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
//    }
//
//    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
//    }
//
//    override func mouseDown(with event: NSEvent) {
//        self.touchDown(atPoint: event.location(in: self))
//    }
//
//    override func mouseDragged(with event: NSEvent) {
//        self.touchMoved(toPoint: event.location(in: self))
//    }
//
//    override func mouseUp(with event: NSEvent) {
//        self.touchUp(atPoint: event.location(in: self))
//    }
//
//    override func keyDown(with event: NSEvent) {
//        switch event.keyCode {
//        case 0x31:
//            if let label = self.label {
//                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
//            }
//        default:
//            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
//        }
//    }
}
