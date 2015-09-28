import Foundation

class MainScene: CCNode {
    // code connections
    weak var hero: CCSprite!                            // bunny
    weak var gamePhysicsNode: CCPhysicsNode!            // game physics node
    weak var ground1: CCSprite!                         // ground 1
    weak var ground2: CCSprite!                         // ground 2
    weak var obstaclesLayer : CCNode!
    
    // variables
    var sinceTouch: CCTime = 0
    var scrollSpeed: CGFloat = 80
    var grounds = [CCSprite]()                          // initialize empty array
    var obstacles: [CCNode] = []
    
    // constants
    let firstObstaclePosition: CGFloat = 280
    let distanceBetweenObstacles: CGFloat = 160
    
    // called every time CCB file is loaded
    func didLoadFromCCB() {
        userInteractionEnabled = true                   // enable touch events
        grounds.append(ground1)                         // add ground1
        grounds.append(ground2)                         // add ground2
        
        for i in 0...2 {
            spawnNewObstacle()
        }
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
        
        for obstacle in obstacles.reverse() {
            let obstacleWorldPosition = gamePhysicsNode.convertToWorldSpace(obstacle.position)
            let obstacleScreenPosition = convertToNodeSpace(obstacleWorldPosition)
            
            // obstacle moved past left side of screen?
            if obstacleScreenPosition.x < (-obstacle.contentSize.width) {
                obstacle.removeFromParent()
                // obstacles.removeAtIndex(find(obstacles, obstacle)!)
                
                // for each removed obstacle, add a new one
                spawnNewObstacle()
            }
        }
    }
    
    // spawn obstacles
    func spawnNewObstacle() {
        // get the previous obstacle's position
        var prevObstaclePos = firstObstaclePosition
        if obstacles.count > 0 {
            prevObstaclePos = obstacles.last!.position.x
        }
        
        // create and add a new obstacle
        let obstacle = CCBReader.load("Obstacle") as! Obstacle
        obstacle.position = ccp(prevObstaclePos + distanceBetweenObstacles, 0)
        obstacle.setupRandomPosition()
        obstaclesLayer.addChild(obstacle)
        obstacles.append(obstacle)
    }
}
