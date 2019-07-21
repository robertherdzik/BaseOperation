//
//  BaseOperation.swift
//  BaseOperation
//
//  Created by Robert Herdzik on 21/07/2019.
//  Copyright © 2019 Robert Herdzik. All rights reserved.
//

import Foundation

open class BaseOperation: Operation {
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    override open var isExecuting: Bool {
        return state == .Executing
    }
    
    override open var isFinished: Bool {
        return state == .Finished
    }
    
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
    
    private var hasFinishedAlready = false
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
            
            stateLock.withCriticalScope { () -> Void in
                guard _state != .Finished else { return }
                
                assert(_state.canTransitionToState(target: newState), "Performing invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    override open func start() {
        state = .Executing
        execute()
    }
    
    public func execute() {
        print("\(type(of: self)) must override `execute()`.")
        
        finish()
    }
    
    final public func finish() {
        if !hasFinishedAlready {
            hasFinishedAlready = true
            
            state = .Finished
        }
    }
    
    @objc
    class func keyPathsForValuesAffectingIsExecuting() -> Set<NSObject> {
        return ["state" as NSObject]
    }
    
    @objc
    class func keyPathsForValuesAffectingIsFinished() -> Set<NSObject> {
        return ["state" as NSObject]
    }
}

private func <(lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: BaseOperation.State, rhs: BaseOperation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

private extension NSLock {
    func withCriticalScope<T>( block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
