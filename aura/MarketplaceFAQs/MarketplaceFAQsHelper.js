({
	helperMethod : function(component, event, helper) {
			var httpReq  = new XMLHttpRequest();
        	//Getting AEM faq url
        	var aemFaqUrl = $A.get("$Label.c.PMP_FAQ_URL");
            httpReq.open('GET', aemFaqUrl, true);
        
         //Fetching Values from custom labels
      	  var generalFaq=  $A.get("$Label.c.PMP_Marketplace_Overview_FAQs");
          var marketplace_Help=  $A.get("$Label.c.PMP_MarketPlace_Help");

          // Setting loggedInInfo to true for logged in user
          component.set('v.loggedInInfo',true);
          
        // Setting loggedInInfo to false for ananyomous user
        if($A.get("$SObjectType.CurrentUser.Email") === undefined){
          		component.set('v.loggedInInfo', false);  
        	}
        // Getting Logged in user info
        var loggedInUser = component.get("v.loggedInInfo");
		

           httpReq.onreadystatechange = function(component1) {
             
                if (this.readyState == 4 ) {

                    var parsedData = JSON.parse(this.responseText);

                    if(this.responseText != null){
                        var finalData = [];
                        for(var i in parsedData){

                            if(loggedInUser){
                                 if(parsedData[i].title.startsWith(marketplace_Help)){
                                    var string = parsedData[i].title;
                                    var trimmedString = string.split(marketplace_Help);
                                    parsedData[i].title = trimmedString[1];
                                    finalData.push(parsedData[i]);
                                
                            		}
                                 }
                             else if(parsedData[i].title.startsWith(generalFaq)){
                                	
                                 	var string = parsedData[i].title;
                                    var trimmedString = string.split(marketplace_Help);
                                    parsedData[i].title = trimmedString[1];
                                    finalData.push(parsedData[i]);

                            }

                         }
                        
                    }
                        component.set("v.data", finalData);  

                }
           };
    
            httpReq.send();
	}
})