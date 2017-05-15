import UIKit

class VHome:VView
{
    private weak var controller:CHome!
    private weak var viewBar:VHomeBar!
    
    override init(controller:CController)
    {
        super.init(controller:controller)
        self.controller = controller as? CHome
        
        let viewBar:VHomeBar = VHomeBar(controller:self.controller)
        self.viewBar = viewBar
        
        addSubview(viewBar)
    }
    
    required init?(coder:NSCoder)
    {
        return nil
    }
}
