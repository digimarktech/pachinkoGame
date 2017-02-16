//
//  GameScene.swift
//  Project11
//
//  Created by Marc Aupont on 11/16/16.
//  Copyright © 2016 Digimark Technical Solutions. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel : SKLabelNode!
    var editingLabel : SKLabelNode!
    var numberOfBallsLabel: SKLabelNode!
    
    
    // property observer that will update label based on mode that we are in
    var editingMode: Bool = false {
        
        didSet {
            
            if editingMode {
                
                editingLabel.text = "Done"
                
            } else {
                
                editingLabel.text = "Edit"
            }
            
        }
        
    }
    
    //this property obeserver will update our label anytime score is set. It is called after score is updated
    var score:Int = 0 {
        
        didSet {
            
            scoreLabel.text = "Score: \(score)"
        }
        
    }
    
    //this property observer will update our ballsLeft label as the user uses the balls
    var balls:Int = 5 {
        
        didSet {
            
            numberOfBallsLabel.text = "Balls Left: \(balls)"
        }
    }
    
    //essentially the viewDidLoad method
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        // set up background picture
        let background = SKSpriteNode(imageNamed: "background.jpg")
        
        //center it
        background.position = CGPoint(x: 512, y: 384)
        
        //draw it and ignore any alpha values
        background.blendMode = .replace
        
        //place this behind everything else
        background.zPosition = -1
        
        //add background to scene
        addChild(background)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        
        //created a method so that we could create multiple slots without duplicating code
        makeSlot(at: CGPoint(x: 128, y: 0) , isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0) , isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0) , isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0) , isGood: false)
        
        //created a method so that we could create multiple bouncers without duplicating code
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        //create score label and place at top right of screen
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        //create a numberOfBalls label and place in the top center of screen
        numberOfBallsLabel = SKLabelNode(fontNamed: "Chalkduster")
        numberOfBallsLabel.text = "Balls Left: 5"
        numberOfBallsLabel.position = CGPoint(x: 500, y: 700)
        addChild(numberOfBallsLabel)
        
        //create a edit label and place at top left of screen
        editingLabel = SKLabelNode(fontNamed: "Chalkduster")
        editingLabel.text = "Edit"
        editingLabel.position = CGPoint(x: 80, y: 700)
        addChild(editingLabel)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first {
            
            // get the location where the user touched the screen
            let location = touch.location(in: self)
            
            let viewHeight = self.view!.bounds.height
            
            let highestYValue = viewHeight - 80
            
            let lowestYValue = viewHeight - 290
            
            let objects = nodes(at: location)
            
            if objects.contains(editingLabel) {
                
                editingMode = !editingMode
                
            } else {
                
                if editingMode {
                    
                    
                    //create a box
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt() , height: 16)
                    
                    // create a box with a Random Color from Helper.swift class and random size
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    
                    box.name = "box"
                    
                    //rotate the box randomly
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    
                    //set the position of the box based on where the user touches
                    box.position = location
                    
                    //create a physics body based on size of box
                    box.physicsBody = SKPhysicsBody(rectangleOf: size)
                    
                    box.physicsBody!.isDynamic = false
                    
                    //add box to the scene
                    addChild(box)
                    
                    
                    
                } else {
                    
                    //Only generate a ball if the user taps near top of the screen
                    if lowestYValue ... highestYValue ~= location.y {
                        
                        if balls > 0 {
                            
                            //generate a random ball color
                            let ballImage = generateRandomBall()
                            
                            //create a ball from ballImage passed in above
                            let ball = SKSpriteNode(imageNamed: ballImage)
                            
                            //assigning name to node so it can be referenced by name later
                            ball.name = "ball"
                            
                            //create a physics body around that whole ball
                            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                            
                            //inform me about every collision that happens
                            ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
                            
                            //this value determines the "bounciness" of the ball
                            ball.physicsBody!.restitution = 0.4
                            
                            //ball will start from where the user tapped
                            ball.position = location
                            
                            //add the ball to the scene
                            addChild(ball)
                            
                            balls -= 1
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
    }
    
    //function is called when first contact happens.
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.node?.name == "ball" {
            
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
            
        } else if contact.bodyB.node?.name == "ball" {
            
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
            
        }
        
        if contact.bodyA.node?.name == "box" {
            
            anotherCollisionBetween(box: contact.bodyA.node!, object: contact.bodyB.node!)
            
        } else if contact.bodyB.node?.name == "box" {
            
            anotherCollisionBetween(box: contact.bodyB.node!, object: contact.bodyA.node!)
            
        }
        
    }
    
    //function creates a bouncer and places it at the position specified
    func makeBouncer(at position: CGPoint) {
        
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        
        bouncer.position = position
        
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0 )
        
        //inform me whenever something touches bouncer
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask
        
        bouncer.physicsBody!.isDynamic = false
        
        addChild(bouncer)
    }
    
    //function makes a slot image and places it on scene based on location. Image is determined by boolean
    func makeSlot(at position: CGPoint, isGood: Bool) {
        
        //create a slotBase and slotGlow sprite
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        //update image based on whether slot is good or not
        if isGood {
            
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            
            //assigning name to node so it can be referenced by name later
            slotBase.name = "good"
            
        } else {
            
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            
            //assigning name to node so it can be referenced by name later
            slotBase.name = "bad"
        }
        
        //set the position of slotBase and slotGlow based on position passed in
        slotBase.position = position
        slotGlow.position = position
        
        //give the slotBase a physics body so we can detect when balls fall on a certain base
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        
        //when objects collide with slotBase, don't move it
        slotBase.physicsBody!.isDynamic = false
        
        //add a slotBase and slotGlow to the scene
        addChild(slotBase)
        addChild(slotGlow)
        
        //create spinning action that rotates for 10 seconds
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        
        //continuously run the spin action forever
        let spinForever = SKAction.repeatForever(spin)
        
        //exectute the spin action on the slotGlow object
        slotGlow.run(spinForever)
        
    }
    
    //function determines what to do when a collision happens between ball and slot
    func collisionBetween(ball: SKNode, object: SKNode) {
        
        if object.name == "good" {
            
            destroy(ball: ball)
            score += 1
            balls += 1
            
        } else if object.name == "bad" {
            
            destroy(ball: ball)
            score -= 1
            
        }
        
    }
    
    //function determines what to do when collision happens between box and ball
    func anotherCollisionBetween(box: SKNode, object: SKNode) {
        
        if object.name == "ball" {
            
            destroy(box: box)
        }
    }
    
    //function that essentially removes ball from game
    func destroy(ball: SKNode) {
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            
            fireParticles.position = ball.position
            
            addChild(fireParticles)
            
        }
        
        ball.removeFromParent()
    }
    
    //function that removes box from the game
    func destroy(box: SKNode) {
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            
            fireParticles.position = box.position
            
            addChild(fireParticles)
            
        }
        
        box.removeFromParent()
        
    }
    
    //function generates random number than selects ball image based on number generated
    func generateRandomBall() -> String {
        
        let randomNumber = RandomInt(min: 1, max: 7)
        
        switch randomNumber {
            
        case 1:
            return "ballBlue"
            
        case 2:
            return "ballCyan"
            
        case 3:
            return "ballGreen"
            
        case 4:
            return "ballGrey"
            
        case 5:
            return "ballPurple"
            
        case 6:
            return "ballRed"
            
        case 7:
            return "ballYellow"
            
        default:
            return "ballRed"
            
        }
    }
    
}
