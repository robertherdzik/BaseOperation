/*
 Code inspierd by Apple sample from 2015
 */

import Foundation

class BaseOperation: Operation {
    
    fileprivate enum State: Int, Comparable {
        case Initialized
        
        /// The `Operation` is executing.
        case Executing

        /// The `Operation` has finished executing.
        case Finished
        
        func canTransitionToState(target: State) -> Bool {
            switch (self, target) {
            case (.Initialized, .Finished):
                return true
            case (.Initialized, .Executing):
                return true
            case (.Executing, .Finished):
                return true
            default:
                return false
            }
        }
    }

    /// A lock to guard reads and writes to the `_state` property
    private let stateLock = NSLock()
    
    /// Private storage for the `state` property that will be KVO observed.
    private var _state = State.Initialized
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            /*
             It's important to note that the KVO notifications are NOT called from inside
             the lock. If they were, the app would deadlock, because in the middle of
             calling the `didChangeValueForKey()` method, the observers try to access
             properties like "isReady" or "isFinished". Since those methods also
             acquire the lock, then we'd be stuck waiting on our own lock. It's the
             classic definition of deadlock.
             */
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope { Void -> Void in
                guard _state != .Finished else {
                    return
                }
                
                assert(_state.canTransitionToState(target: newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    private class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    private class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    final override var isAsynchronous: Bool {
        return true
    }
    
    final override var isExecuting: Bool {
        return state == .Executing
    }
    
    final override var isFinished: Bool {
        return state == .Finished
    }

    func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    // TODO [🌶]: check whether istead of `start` in async operation we can use main
//   override func start() {
//        super.start()
//
//        state = .Executing
//        execute()
//    }
    
    final override func main() {
        super.main()
        
        state = .Executing
        execute()
    }
    
    private var hasFinishedAlready = false
    final func finish() {
        if !hasFinishedAlready {
            hasFinishedAlready = true
        
            state = .Finished
        }
    }

}

// Simple operator functions to simplify the assertions used above.
private func <(lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

extension NSLock {
    func withCriticalScope<T>( block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
