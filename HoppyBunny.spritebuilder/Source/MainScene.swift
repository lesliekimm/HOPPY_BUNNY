import Foundation

class MainScene: CCNode {
    // code connections
    weak var hero: CCSprite!                            // bunny
    weak var gamePhysicsNode: CCPhysicsNode!            // game physics node
    weak var ground1: CCSprite!                         // ground 1
    weak var ground2: CCSprite!                         // ground 2
    
    // variables
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    var grounds = [CCSprite]()                          // initialize empty array
    
    // called every time CCB file is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true                   // enable touch events
        grounds.append(ground1)                         // add ground1
        grounds.append(ground2)                         // add ground2
        
    }
    
    // applies action to touch event
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        hero.physicsBody.applyImpulse(ccp(0, 400))      // apply impulse w every touch
        hero.physicsBody.applyAngularImpulse(10000)     // apply rotation w every touch
        sinceTouch = 0
    }
    
    override func update(delta: CCTime) {
        // clamping means tesing & optionally changing given value so it doesn't exceed a specified
        // value range
        // limit upward velocity to 200 at most
        let velocityY = clampf(Float(hero.physicsBody.velocity.y), -Float(CGFloat.max), 200)
        hero.physicsBody.velocity = ccp(0, CGFloat(velocityY))
        
        // limit rotation of bunny and start downward rotation if no touch occurred in awhile
        sinceTouch += delta
        hero.rotation = clampf(hero.rotation, -30, 90)
        if (hero.physicsBody.allowsRotation) {
            let angularVelocity = clampf(Float(hero.physicsBody.angularVelocity), -2, 1)
            hero.physicsBody.angularVelocity = CGFloat(angularVelocity)
        }
        if (sinceTouch > 0.3) {
            let impulse = -18000.0 * delta
            hero.physicsBody.applyAngularImpulse(CGFloat(impulse))
        }
        
        // manipulate scroll speed of bunny
        hero.position = ccp(hero.position.x + scrollSpeed * CGFloat(delta), hero.position.y)
        // move the physics node
        gamePhysicsNode.position = ccp(gamePhysicsNode.position.x - scrollSpeed * CGFloat(delta), gamePhysicsNode.position.y)
        
        // loop the ground whenever a ground image is moved entirely outside the screen
        for ground in grounds {
            let groundWorldPosition = gamePhysicsNode.convertToWorldSpace(ground.position)
            let groundScreenPosition = convertToNodeSpace(groundWorldPosition)
            if groundScreenPosition.x <= (-ground.contentSize.width) {
                ground.position = ccp(ground.position.x + ground.contentSize.width * 2, ground.position.y)
            }
        }
    }
}
