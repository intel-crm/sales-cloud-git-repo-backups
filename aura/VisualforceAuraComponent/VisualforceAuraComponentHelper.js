({
    
    sendMsgToVF : function( component ) {
        
        let strMessage = component.get( "v.strMsg" );
        console.log(
            'strMessage is',
            strMessage
        );    
        /*
        	Setting 100 milli seconds delay for 
            initial loading of the VF Page to get the message
        */
        window.setTimeout(
            $A.getCallback( function() {
                let objEvent = $A.get( "e.c:VisualforceEvent" );
                objEvent.setParams({
                	messageValue : strMessage        
                });
                objEvent.fire();
            }), 100
        );
    
	}
    
})