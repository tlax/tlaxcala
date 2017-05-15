import Foundation

class MSession
{
    static let sharedInstance:MSession = MSession()
    private(set) var settings:DSettings?
    
    private init()
    {
    }
    
    //MARK: private
    
    private func firebasePath() -> String?
    {
        guard
            
            let userId:String = settings?.firebaseId
        
        else
        {
            return nil
        }
        
        let path:String = "\(FDb.user)/\(userId)"
        
        return path
    }
    
    private func asyncLoadSession()
    {
        DManager.sharedInstance?.fetchData(
            entityName:DSettings.entityName,
            limit:1)
        { (data) in
            
            guard
            
                let settings:DSettings = data?.first as? DSettings
            
            else
            {
                self.createSession()
                
                return
            }
            
            settings.addTtl()
            self.settings = settings
            self.sessionLoaded()
        }
    }
    
    private func createSession()
    {
        DManager.sharedInstance?.createData(
            entityName:DSettings.entityName)
        { (data) in
            
            guard
            
                let settings:DSettings = data as? DSettings
            
            else
            {
                return
            }
            
            self.settings = settings
            self.createUser()
        }
    }
    
    private func createUser()
    {
        DManager.sharedInstance?.createData(
            entityName:DUser.entityName)
        { (data) in
            
            guard
            
                let user:DUser = data as? DUser
            
            else
            {
                return
            }
            
            user.defaultValues()
            self.settings?.user = user
            self.createEnergy()
        }
    }
    
    private func createEnergy()
    {
        DManager.sharedInstance?.createData(
            entityName:DEnergy.entityName)
        { (data) in
            
            guard
                
                let energy:DEnergy = data as? DEnergy
                
            else
            {
                return
            }
            
            energy.defaultValues()
            self.settings?.energy = energy
            self.createStats()
        }
    }
    
    private func createStats()
    {
        DManager.sharedInstance?.createData(
            entityName:DStats.entityName)
        { (data) in
            
            guard
            
                let stats:DStats = data as? DStats
            
            else
            {
                return
            }
            
            self.settings?.stats = stats
            self.sessionLoaded()
        }
    }
    
    private func sessionLoaded()
    {
        DispatchQueue.global(qos:DispatchQoS.QoSClass.background).async
        {
            DManager.sharedInstance?.save()
            
            if let _:String = self.settings?.firebaseId
            {
                self.loadFirebaseUser()
            }
            else
            {
                self.createFirebaseUser()
            }
        }
    }
    
    private func loadFirebaseUser()
    {
        guard
            
            let path:String = firebasePath()
        
        else
        {
            return
        }
        
        FMain.sharedInstance.db.listenOnce(
            path:path,
            nodeType:FDbUserItem.self)
        { (node:FDbProtocol?) in
            
            guard
            
                let user:FDbUserItem = node as? FDbUserItem
            
            else
            {
                return
            }
            
            self.firebaseLoaded(user:user)
        }
    }
    
    private func createFirebaseUser()
    {
        let user:FDbUserItem = FDbUserItem()
        
        guard
            
            let userJson:Any = user.json()
        else
        {
            return
        }
        
        let userId:String = FMain.sharedInstance.db.createChild(
            path:FDb.user,
            json:userJson)
        settings?.firebaseId = userId
        
        firebaseLoaded(user:user)
    }
    
    private func firebaseLoaded(user:FDbUserItem)
    {
        handler = user.handler
        level = user.level
        score = user.score
        active = user.active
        DManager.sharedInstance?.save()
        
        NotificationCenter.default.post(
            name:Notification.sessionLoaded,
            object:nil)
    }
    
    private func tryLevelUp()
    {
        let scoreForLevelUp:Int = level * kScoreLevelRatio
        
        if score > scoreForLevelUp
        {
            let maxLevel:Int = Int(DUser.kMaxStats)
            level += 1
            
            if level > maxLevel
            {
                level = maxLevel
            }
            
            guard
                
                let userPath:String = firebasePath()
                
            else
            {
                return
            }
            
            let path:String = "\(userPath)/\(FDbUserItem.level)"
            FMain.sharedInstance.db.updateChild(
                path:path,
                json:level)
            
            let message:String = NSLocalizedString("MSession_levelUp", comment:"")
            VToast.messageBlue(message:message)
        }
    }
    
    //MARK: public
    
    func loadSession()
    {
        DispatchQueue.global(qos:DispatchQoS.QoSClass.background).async
        {
            self.asyncLoadSession()
        }
    }
}
