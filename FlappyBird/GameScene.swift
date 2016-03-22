//
//  GameScene.swift
//  FlappyBird
//
//  Created by Alex Nguyen on 2015-12-28.
//  Copyright (c) 2015 Alex Nguyen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //Declare bird node
    var bird = SKSpriteNode()
    //Declare background node
    var background = SKSpriteNode()
    //Declare pipe1
    var pipe1 = SKSpriteNode()
    //Declare pipe2
    var pipe2 = SKSpriteNode()
    //Game over variable
    var gameOver = false
    //Score
    var score = 0
    //Score Label
    var scoreLabel = SKLabelNode()
    //Game over label
    var gameOverLabel = SKLabelNode()
    //Group collector
    var movingObjects = SKSpriteNode()
    //Label container
    var labelContainer = SKSpriteNode()
    
    enum ColliderType: UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    func makeBackground(){
        //Create background texture
        let backgroundTexture = SKTexture(imageNamed: "bg.png")
        
        //Apply texture to background
        background = SKSpriteNode(texture: backgroundTexture)
        
        //Center the background
        background.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        //Set the size to the size of the screen
        background.size.height = self.frame.height
        
        //Move background left
        let moveBackground = SKAction.moveByX(-backgroundTexture.size().width, y: 0, duration: 10.0)
        let replaceBackground = SKAction.moveByX(backgroundTexture.size().width, y: 0, duration: 0)
        
        //Move background left forever
        let moveBackgroundForever = SKAction.repeatActionForever(SKAction.sequence([moveBackground, replaceBackground]))
        
        for var i: CGFloat = 0; i < 3; i++ {
            //Apply texture to background
            background = SKSpriteNode(texture: backgroundTexture)
            
            //Center the background
            background.position = CGPoint(x: backgroundTexture.size().width/2 + backgroundTexture.size().width*i, y: CGRectGetMidY(self.frame))
            
            //Set the size to the size of the screen
            background.size.height = self.frame.height
            //Loop background
            background.runAction(moveBackgroundForever)
            
            //Fix flickering issue
            background.zPosition = 1
            
            //Add the background
            movingObjects.addChild(background)
        }
    }
    override func didMoveToView(view: SKView) {
        //View did load method essentially
        
        //Set up physics world
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(labelContainer)
        
        makeBackground()
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame)-100, self.frame.size.height - 70)
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
        
        //Bird textures
        let birdTexture = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        //Bird flap
        let animation = SKAction.animateWithTextures([birdTexture, birdTexture2], timePerFrame: 0.1)
        
        //Repeating flapping bird
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        //Create bird from texture
        bird = SKSpriteNode(texture: birdTexture)
        
        //Create physics body to the bird
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height/2)
        
        //Apply gravity
        bird.physicsBody!.dynamic = true
        
        //Give the bird position at center of the screen
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        
        //Add action to bird
        bird.runAction(makeBirdFlap)
        
        //Fix Flickering issue
        bird.zPosition = 4
        
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.allowsRotation = false
        
        //Add the vird to the screen
        self.addChild(bird)
        
        //Create a ground node (test for colision)
        let ground = SKNode()
        ground.position = (CGPointMake(0,0))//Set position to be at the bottom
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1)) //Size size, screen.width*1 pixels
        ground.physicsBody!.dynamic = false //Don't want the ground to fall off our screen
        
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        
        self.addChild(ground) //Add ground to the scene
        
        _ = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: Selector("makePipes"), userInfo: nil, repeats: true)
    }
    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue {
            score++
            scoreLabel.text = String(score)
            //Speed up the game a little bit
            self.speed = self.speed + 0.1
        } else {
            if gameOver == false {
                gameOver = true
                self.speed = 0
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 20
                gameOverLabel.text = "GAME OVER! TAP TO PLAY AGAIN"
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                gameOverLabel.zPosition = 6
            
                labelContainer.addChild(gameOverLabel)
            }
        }
    }
    func makePipes(){
        //Define the gap height
        let gapHeight = bird.size.height*4
        
        let movementAmount = arc4random() % UInt32(self.frame.size.height / 2)
        
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width*2, y: 0, duration: NSTimeInterval(self.frame.size.width/100))
        
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        
        //Create the top pipe (pipe1)
        let pipeTexture = SKTexture(imageNamed: "pipe1.png")
        let pipe1 = SKSpriteNode(texture: pipeTexture)
        pipe1.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) + pipeTexture.size().height/2 + gapHeight / 2 + pipeOffset)
        
        //Set priotity
        pipe1.zPosition = 2
        
        pipe1.runAction(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody?.dynamic = false
        movingObjects.addChild(pipe1)
        
        //Create the bottom pipe (pipe2)
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        let pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight / 2 + pipeOffset)
        //Fix flickering issue
        pipe2.zPosition = 3
        pipe2.runAction(moveAndRemovePipes)
        //Physics collision
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipeTexture.size())
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody?.dynamic = false
        movingObjects.addChild(pipe2)
        
        var gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width, y: CGRectGetMidY(self.frame)+pipeOffset)
        gap.runAction(moveAndRemovePipes)
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody!.dynamic = false //Don't want gravity
        
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //Called when a touch begins
        if gameOver == false {
            //Set speed of the bird to 0
            bird.physicsBody!.velocity = CGVectorMake(0,0)
            bird.physicsBody!.applyImpulse(CGVectorMake(0,60))
        } else {
            score = 0
            scoreLabel.text = "0"
            bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
            bird.physicsBody?.velocity = CGVectorMake(0,0)
            movingObjects.removeAllChildren()
            labelContainer.removeAllChildren()
            makeBackground()
            self.speed = 1
            gameOver = false
            
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
