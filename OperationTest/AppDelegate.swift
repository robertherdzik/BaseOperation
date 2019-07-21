import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    var queue = OperationQueue()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        performExampleCode()
    }
    
    func performExampleCode() {
        let sleepOp = SleepOperation()
        let parseOp = ParseOperation()
        let completionOp = BlockOperation {
            print("completionOp " + sleepOp.result)
        }
        completionOp.addDependency(sleepOp)
        completionOp.addDependency(parseOp)
        
        queue.addOperations([sleepOp, parseOp, completionOp], waitUntilFinished: true)
        
        print("👏")
    }
}

// ------------------------------------------------
// Stub operations

class SleepOperation: BaseOperation {
    var result = ""
    
    override func execute() {
        desc(with: "BEGIN 😇")
        Thread.sleep(forTimeInterval: 2)
        desc(with: "😇😴")
        result = "Finished"
        
        finish()
        test()
       
        SleepOperation.foo()

    }
    
    static func foo() {
        
    }
    
    private func test() {
        
    }
}

class ParseOperation: BaseOperation {
    
    override func execute() {
        desc(with: "BEGIN 😍")
        desc(with: "😍😴")
        finish()
    }
}

// ------------------------------------------------

extension NSObject {
    
    func desc(with text: String) {
        print(description + text)
    }
}

