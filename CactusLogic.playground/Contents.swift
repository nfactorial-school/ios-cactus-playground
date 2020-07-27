import Foundation

class CountdownTimer {
    var timer: Timer?
    var secondsLeft: Int
    
    let secondsLeftChangedHandler: (Int) -> Void
    
    init(durationInSeconds: Int, secondsLeftChangedHandler: @escaping (Int) -> Void) {
        secondsLeft = durationInSeconds
        self.secondsLeftChangedHandler = secondsLeftChangedHandler
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.secondsLeft -= 1
            self.secondsLeftChangedHandler(self.secondsLeft)
            
            if self.secondsLeft == 0 {
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

struct Session {
    let durationInSeconds: Int
    
    var coinsCount: Int {
        if durationInSeconds <= 30 * 60 {
            return 3
        } else if durationInSeconds <= 60 * 60 {
            return 6
        } else {
            return 9
        }
    }
}

class SessionsStorage {
    static let shared = SessionsStorage()
    
    var sessions = [Session]()
    
    func addSession(_ session: Session) {
        sessions.append(session)
    }
}

protocol SessionManagerDelegate {
    func sessionDidStart(session: Session)
    func sessionTimeLeftChanged(secondsLeft: Int)
    func sessionDidEnd(session: Session)
    func sessionDidCancel()
}

class SessionManager {
    let delegate: SessionManagerDelegate
    
    var sessionTimer: CountdownTimer?
    
    init(delegate: SessionManagerDelegate) {
        self.delegate = delegate
    }
    
    func startSession(session: Session) {
        sessionTimer = CountdownTimer(durationInSeconds: session.durationInSeconds) { secondsLeft in
            if secondsLeft == 0 {
                SessionsStorage.shared.addSession(session)
                Balance.shared.addCoins(session.coinsCount)
                self.delegate.sessionDidEnd(session: session)
            } else {
                self.delegate.sessionTimeLeftChanged(secondsLeft: secondsLeft)
            }
        }
        
        sessionTimer?.start()
        delegate.sessionDidStart(session: session)
    }
    
    func stopSession() {
        sessionTimer?.stop()
        delegate.sessionDidCancel()
    }
}

class Balance {
    static let shared = Balance()
    
    var coinsCount = 100
    
    func addCoins(_ coinsCountToAdd: Int) {
        self.coinsCount += coinsCountToAdd
    }
}


class SessionView: SessionManagerDelegate {
    var sessionManager: SessionManager?
    
    func userStartedSession(durationInSeconds: Int) {
        let session = Session(durationInSeconds: durationInSeconds)
        sessionManager?.startSession(session: session)
    }
    
    func userCancelledSession() {
        sessionManager?.stopSession()
    }
    
    func sessionDidStart(session: Session) {
        print("sessionStarted")
        showTimeLeft(secondsLeft: session.durationInSeconds)
    }
    
    func sessionTimeLeftChanged(secondsLeft: Int) {
        showTimeLeft(secondsLeft: secondsLeft)
    }
    
    func sessionDidEnd(session: Session) {
        print("sessionEnded")
    }
    
    func sessionDidCancel() {
        print("sessionCancelled")
    }
    
    func showTimeLeft(secondsLeft: Int) {
        print(secondsLeft)
    }
}

// SESSION
//let view = SessionView()
//view.sessionManager = SessionManager(delegate: view)
//view.userStartedSession(durationInSeconds: 10)

// CANCELLING SESSION
//let view = SessionView()
//view.sessionManager = SessionManager(delegate: view)
//view.userStartedSession(durationInSeconds: 10)
//
//DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
//    view.userCancelledSession()
//}

// COINS
//let view = SessionView()
//view.sessionManager = SessionManager(delegate: view)
//view.userStartedSession(durationInSeconds: 3)
//
//DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
//    print(Balance.shared.coinsCount)
//}

struct Break {
    let durationInSeconds: Int
}

protocol BreakManagerDelegate {
    func breakDidStart(aBreak: Break)
    func breakTimeLeftChanged(secondsLeft: Int)
    func breakDidEnd(aBreak: Break)
    func breakDidCancel()
}

class BreakManager {
    let delegate: BreakManagerDelegate
    
    var breakTimer: CountdownTimer?
    
    init(delegate: BreakManagerDelegate) {
        self.delegate = delegate
    }
    
    func startBreak(aBreak: Break) {
        breakTimer = CountdownTimer(durationInSeconds: aBreak.durationInSeconds) { secondsLeft in
            if secondsLeft == 0 {
                self.delegate.breakDidEnd(aBreak: aBreak)
            } else {
                self.delegate.breakTimeLeftChanged(secondsLeft: secondsLeft)
            }
        }
        
        breakTimer?.start()
        delegate.breakDidStart(aBreak: aBreak)
    }
    
    func cancelBreak() {
        breakTimer?.stop()
        delegate.breakDidCancel()
    }
}

class BreakView: BreakManagerDelegate {
    var breakManager: BreakManager?
    
    func userStartedBreak(durationInSeconds: Int) {
        let aBreak = Break(durationInSeconds: durationInSeconds)
        breakManager?.startBreak(aBreak: aBreak)
    }
    
    func breakDidStart(aBreak: Break) {
        print("break started")
        showTimeLeft(secondsLeft: aBreak.durationInSeconds)
    }
    
    func breakTimeLeftChanged(secondsLeft: Int) {
        showTimeLeft(secondsLeft: secondsLeft)
    }
    
    func breakDidEnd(aBreak: Break) {
        print("break ended")
    }
    
    func breakDidCancel() {
        print("break cancelled")
    }
    
    func showTimeLeft(secondsLeft: Int) {
        print(secondsLeft)
    }
}

// BREAK
//let breakView = BreakView()
//breakView.breakManager = BreakManager(delegate: breakView)
//breakView.userStartedBreak(durationInSeconds: 5)
