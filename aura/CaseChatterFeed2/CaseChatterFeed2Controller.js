/**
* Aura controller used to make new posts to Service Cloud from Sales Cloud
* Contains the logic for the Share button of the component
*/

({  
    /**
	* Called when the Share button is pressed. 
	* Handles the Apex call to CaseChatterFeed2.postToFeed().
	*/
    handleClick : function (component, event)
    {
        //Sets msg equal to the String value inside of the text box
        var msg = event.getSource().get("v.value");
        
        //If nothing is typed in the text box, do nothing
        if (!msg){return;}
        
        //removes automatic HTML formatting. 
        msg = msg.replace(/<\/?[^>]+(>|$)/g, "");
        
        //Sets vis equal to the visibility picklist and converts it to its API value
        var vis = component.find("sel").get("v.value")
        if (vis == "All with access"){vis = "AllUsers";}
        else{vis = "InternalUsers";}
        
        //Makes asynchronous Apex function call CaseChatterFeed2.getExternalID
        var action = component.get("c.getExternalID");
        action.setParams({ recordId : component.get("v.recordId")});
        
        //Sets callback for getExternalID
        action.setCallback(this, function(response)
                           {
                               var ExternalId = response.getReturnValue();
                               //Makes asynchronous Apex function call CaseChatterFeed2.postToFeed
                               var action2 = component.get("c.postToFeed");
                               action2.setParams({ recordId : ExternalId,
                                                  postText: msg,
                                                  vis: vis});
                               //Enqueues call to postToFeed
                               $A.enqueueAction(action2);
                               
                               //Reloads page
                               location.reload();
                           })
        //Enqueues call to getExternalID
        $A.enqueueAction(action);
        
    },
})