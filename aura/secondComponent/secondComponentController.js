({  
      
    doInit : function( component, event, helper ) {  
          
        var resultMsg = sessionStorage.getItem( 'pageTransfer' );
        if(resultMsg != null && resultMsg != undefined){
            component.set( "v.Text", JSON.parse( resultMsg ).sampleVar ); 
        }
         
          
    }  
      
})