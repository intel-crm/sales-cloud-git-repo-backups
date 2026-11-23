({
    //this function is called from SalesAssitTabcontroller.js
    //this function gathers all the required information and formulates the URL parameters
	getUserSession : function(component, event, helper) {
        //set the source of the click
       	if (window.sessionStorage.getItem('sSource') == null)
        {
        	window.sessionStorage.setItem('sSource', 'assists_tab'); 
		}
        
        //This section initializes the values from URL Params.
 		var pageReference = component.get("v.pageReference");
        //Set Account ID value
        console.log("Assists Tab-->helper-->CimID: " + pageReference.state.c__CimId);       
        if (pageReference.state.c__CimId != null)
        {
			window.sessionStorage.setItem('sCimId',  pageReference.state.c__CimId);
        	console.log("Assists Tab-->Init-->scimId:" + window.sessionStorage.getItem('sCimId'));
        }
        
        //Set Account ID value
        console.log("Assists Tab-->Init-->AccountId: " + pageReference.state.c__AccountId);
       	if (pageReference.state.c__AccountId != null)
        {
			window.sessionStorage.setItem('sAccountId',  pageReference.state.c__AccountId);
        	console.log("Assists Tab-->Init-->sAccountId:" + window.sessionStorage.getItem('sAccountId'));
        }
        //Set Last Month value
        if (pageReference.state.c__lm != null)
        {
            window.sessionStorage.setItem('sLastMonth',  pageReference.state.c__lm);
            console.log("Assists Tab-->Init-->c__lm:" + window.sessionStorage.getItem('sLastMonth'));
        }
        else
        {
            window.sessionStorage.setItem('sLastMonth',  "1");            
            console.log("Assists Tab-->Init-->lm1:" + window.sessionStorage.getItem('sLastMonth'));
        }
        
        //Set Page Source value
        if (pageReference.state.c__src != null)
        {
            window.sessionStorage.setItem('sSource',  pageReference.state.c__src);
            console.log("Assists Tab-->Init-->c__src:" + window.sessionStorage.getItem('sSource'));
        }
        
        //Set Assist ID
        if (pageReference.state.c__aid != null)
        {
            window.sessionStorage.setItem('sAid',  pageReference.state.c__aid);
            console.log("Assists Tab-->Init-->c__aid:" + window.sessionStorage.getItem('sAid'));
        }
        //Set Index 
        if (pageReference.state.c__index != null)
        {
            window.sessionStorage.setItem('sIndex',  pageReference.state.c__index);
            console.log("Assists Tab-->Init-->c__index:" + window.sessionStorage.getItem('sIndex'));
        }
    
        
   //-----------------     
     	console.log("Assists Tab-->getUserSession");
       
        //retrieve the session data originally set in the SAShowTop3Assists Clicks on the items and links
        //CIM Id for the specific account details page where click occured
        var sData=window.sessionStorage.getItem('sCimId'); 
        component.set('v.cimId', sData);
        
        //Real Account Id associated with the CIM ID
        var sData=window.sessionStorage.getItem('sAccountId'); 
        component.set('v.accountId', sData);        

        //get last month value sent by account list view page
        var sData=window.sessionStorage.getItem('sLastMonth'); 
        component.set('v.lastMonth', sData);        
        
        // Identification of the click source
        sData=window.sessionStorage.getItem('sSource');
        component.set('v.source', sData);
       
        // Asset ID on which user clicked from SAShowTop3Assists Lightning component
        sData=window.sessionStorage.getItem('sAid'); 
        component.set('v.Aid', sData);
        
        // Index of the one of the threee Asset links on which user clicked from SAShowTop3Assists Lightning component
        sData=window.sessionStorage.getItem('sIndex'); 
        component.set('v.index', sData);
        //
        var req_id = (Math.random()+' ').substring(2,10)+(Math.random()+' ').substring(2,10);
        
        var accountId = component.get('v.accountId');
        
        //now call Apex function from SAServiceWrapper Class to get the user specific information
        var action = component.get("c.getUserSessionData");
        //set function param
        action.setParams({
                "accountId" : accountId
            });
        console.log('SalesAssistsTab-->getUserSession accountId: ' + accountId);
   
        console.log('accountId: ' + accountId);        
        action.setCallback(this, function(response) {
            var state = response.getState();
            //if the call is successful and data is received. 
            if (state === "SUCCESS") {
                
                component.set('v.data', response.getReturnValue());
                //Return value is an object of type SAUserSessionDefination class
                //Retrieve the OrgID Property and assign a local variable the value
                component.set('v.orgId', component.get('v.data.orgId'));
                //Retrieve the sessionId Property
                component.set('v.sessionId', component.get('v.data.sessionId'));
                //Retrieve the wwid Property
            	component.set('v.userWWID', component.get('v.data.wwid'));
                //Retrieve the email Property
            	component.set('v.userEmail', component.get('v.data.email')); 
                
                console.log("SalesAssistsTab-->getUserSessionId call orgId: " + component.get('v.orgId'));
                console.log("SalesAssistsTab-->getUserSessionId call sessionId: " + component.get('v.sessionId'));
                console.log("SalesAssistsTab-->getUserSessionId call userWWID: " + component.get('v.userWWID'));
                console.log("SalesAssistsTab-->getUserSessionId call userEmail: " + component.get('v.userEmail'));
        		console.log('SalesAssistsTab-->getUserSession source: ' + component.get('v.source'));
                
                //get custom label SAHostValue
                var SAHost = $A.get("$Label.c.Core_SA_HostValue");
                
               	//set the URL Parameters to be passed to the iFrame on SalesAssisTab Lightning component
                var pageSource = component.get('v.source');
                if (pageSource == 'unread_indicator')
                	//set the URL if user clicked on Unread Assists component title
                	//https://<hostname>/?cim_id=123456&source=unread_indicator&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
				else if (pageSource == 'top_assists_headline')
                	//set the URL  if user clicked on Top 3 assists component title
                	//https://<hostname>/?cim_id=123456&source=top_assists_headline&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
				else if (pageSource == 'top_assist')
                	//set the URL  if user clicked on one of the top assists
                	//https://<hostname>/ cim_id=123456&assist_id=1111&index=2&source=top_assists&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&assist_id=" + component.get('v.Aid') + "&index=" + component.get('v.index') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
				else if (pageSource == 'top_assist_bottom')
                	//set the URL  if user clicked on Top assits view all
                	//https://<hostname>/?cim_id=123456&source=top_assists_bottom&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
				else if (pageSource == 'accounts_page')
                	//set the URL  if user clicked on account_page list view
                	//https://<hostname>/?cim_id=123456&last_month=1&source=accounts_page&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&last_month=" + component.get('v.lastMonth') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
				else if (pageSource == 'assists_tab')
                	//set the URL  if user clicked on assists_tab
                	//https://<hostname>/?cim_id=123456&last_month=1&source=accounts_page&wwid=<wwid>&eMail=<eMail>&token=<token>
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&source=" + component.get('v.source') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
                else
                	//set the URL  if user clicked on assits tab
        			component.set('v.urlParams', encodeURI(SAHost + "req_id=" + req_id + "&cim_id=" + component.get('v.cimId') + "&source=" + component.get('v.source') + "&assist_id=" + component.get('v.Aid') + "&index=" + component.get('v.index') + "&wwid=" + component.get('v.userWWID') + "&eMail=" + component.get('v.userEmail') + "&token=" + component.get('v.sessionId')));
                console.log("SalesAssistsTab-->getUserSessionId call urlParams: " + component.get('v.urlParams'));
                component.set("v.pageRefresh", false);
            }
            else if(state === "INCOMPLETE") {
                // Call was incomplete log an error
                this.showToast('Error loading Salesassist application','error');
                console.log('SalesAssistsTab-->getUserSessionId call INCOMPLETE');
            }
                else if(state === "ERROR") {
               	// Call was errored out so log an error
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.log("SalesAssistsTab-->getUserSessionId Error message: " + 
                                    errors[0].message);
                        
                    } else {
                         console.log("SalesAssistsTab-->Unknown error");
                    }
                    this.showToast('Error loading Salesassist application','error');
                }else{
                    console.log('SalesAssistsTab-->');
                    this.showToast('Error loading Salesassist application','error');
                }
        });
        $A.enqueueAction(action);
    },
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    }
})