import Foundation

class MSession
{
    static let sharedInstance:MSession = MSession()
    private(set) var settings:DSettings?
    
    private init()
    {
    }
    
    //MARK: private
    
    //MARK: public
    
    func loadSession()
    {
        DispatchQueue.global(qos:DispatchQoS.QoSClass.background).async
        {
        }
    }
}
