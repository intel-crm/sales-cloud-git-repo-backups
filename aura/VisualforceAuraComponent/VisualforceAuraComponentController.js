({
    
	doInit : function( component, event, helper ) {
        
        helper.sendMsgToVF( component );
		
	}, 
    
	passDataToVF : function( component, event, helper ) {
        
        helper.sendMsgToVF( component );
        
    }
    
})