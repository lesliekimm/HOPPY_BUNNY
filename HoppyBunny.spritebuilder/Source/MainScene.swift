import Foundation

class MainScene: CCNode {
    // code connections
    weak var hero: CCSprite!                            // bunny
    
    // variables
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    
    // called every time CCB file is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true                   // enable touch events
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
    }
}
