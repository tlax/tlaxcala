import Foundation

extension DSettings
{
    //MARK: public
    
    func addTtl()
    {
        ttl += 1
        DManager.sharedInstance?.save()
    }
}
