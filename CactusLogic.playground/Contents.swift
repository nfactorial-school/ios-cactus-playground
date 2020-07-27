import Foundation

class Session {
    let durationInSeconds: Int
    
    init(durationInSeconds: Int) {
        self.durationInSeconds = durationInSeconds
    }
}

protocol SessionManagerDelegate {
    func showSessionStarted()
    func showTimeLeft(secondsLeft: Int)
    func showSessionEnded()
}

class SessionManager {
    var sessionDelegate: SessionManagerDelegate
    var timer: Timer?
    let sessionStorage = SessionsStorage()
    
    init(sessionDelegate: SessionManagerDelegate) {
        self.sessionDelegate = sessionDelegate
    }
    
    func startSession(session: Session) {
        sessionDelegate.showSessionStarted()
        sessionDelegate.showTimeLeft(secondsLeft: session.durationInSeconds)

        var secondsLeft = session.durationInSeconds
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            secondsLeft -= 1
            self.sessionDelegate.showTimeLeft(secondsLeft: secondsLeft)
            
            if secondsLeft == 0 {
                SessionsStorage.shared.add(session: session)
                self.sessionDelegate.showSessionEnded()
                
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
}

class SessionsStorage {
    static let shared = SessionsStorage()
    
    var sessions = [Session]()
    
    func add(session: Session) {
        sessions.append(session)
    }
}

class SessionView: SessionManagerDelegate {
    var sessionManager: SessionManager?
    
    func userDidStartSession(durationInSeconds: Int) {
        sessionManager?.startSession(session: Session(durationInSeconds: durationInSeconds))
    }
    
    func showSessionStarted() {
        print("sessionStarted")
    }
    
    func showTimeLeft(secondsLeft: Int) {
        print("\(secondsLeft)")
    }
    
    func showSessionEnded() {
        print("sessionEnded")
    }
}

let sessionView = SessionView()
sessionView.sessionManager = SessionManager(sessionDelegate: sessionView)

sessionView.userDidStartSession(durationInSeconds: 3)

DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4)) {
    print("sessions count: \(SessionsStorage.shared.sessions.count)")
}
