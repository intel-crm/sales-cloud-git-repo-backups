({
	doInit: function(cmp)  {
          try{	
               console.log('url from site---',window.location.href);
              	 var localizedUrlLabel = $A.get("$Label.c.Core_Localized_URL");
              	 var sameWindowLabel = $A.get("$Label.c.Core_Same_Window");
              	 var newWindowLabel = $A.get("$Label.c.Core_New_Window");
              	 var livePreviewLabel = $A.get("$Label.c.Core_LivePreview");
              	 var target = cmp.get("v.target"); 
                 var sessionVal = cmp.get("c.getCurrentSession"); 
             	 // Callback which will fetch the response from Apex and set the value to Componen
                 sessionVal.setCallback(this, function(returnedParam) {
                 	var sessionTypeVal = returnedParam.getReturnValue();
                    
                   // Code section for Community User
                  if(sessionTypeVal != livePreviewLabel){
                        if(target == newWindowLabel) {
                           window.open(''+localizedUrlLabel+'');// opening in a new tab for community user
                            window.history.back();
                        }
                        
                        else if(target == sameWindowLabel){
                            	window.open(''+localizedUrlLabel+'','_self');
                            	window.history.back();
                        }
                        else{
                           window.open(''+localizedUrlLabel+'');// opening in a new tab for community user
                        window.history.back(); 
                        }
                    }
       
              	});    
            
            	$A.enqueueAction(sessionVal); 
        }
        
        catch(error){
           
        }
        		
	}
     

});