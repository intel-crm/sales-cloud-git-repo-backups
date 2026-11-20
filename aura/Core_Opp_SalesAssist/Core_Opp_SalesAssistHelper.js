({
	getURL : function(component, event, helper) {
        component.set("v.isModalOpen",true);
        
		var SAHost = $A.get("$Label.c.Core_SA_Opp_HostValue");
        debugger;
        var req_id = (Math.random()+' ').substring(2,10)+(Math.random()+' ').substring(2,10);
       
        var action = component.get("c.getUserSessionData");
        action.setParams({
              OppId : component.get("v.recordId")
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //if the call is successful and data is received. 
            if (state === "SUCCESS") {
                debugger;
                component.set("v.data", response.getReturnValue());
                component.set("v.orgId", component.get("v.data.orgId"));
                component.set("v.sessionId", component.get("v.data.sessionId"));
            	component.set("v.userWWID", component.get("v.data.wwid"));
            	component.set("v.userEmail", component.get("v.data.email"));
                component.set("v.cimId", component.get("v.data.cimId"));
                component.set("v.prodList", component.get("v.data.prodJSON"));
                var a = JSON.stringify(component.get("v.prodList"));
                //alert(a); 
                //URL reqid, source, wwid, email, allowfullscreen, webkitallowfullscreen,'mozallowfullscreen','opp_id','token','products'
				//component.set("v.urlParams", encodeURI(SAHost + "req_id=" + req_id + "&source=" + component.get("v.source") + "&wwid=" + component.get('v.userWWID')+ "&eMail=" + component.get('v.userEmail')+ "&allowfullscreen=true"+"&webkitallowfullscreen=true"+"&mozallowfullscreen=true" +"&opp_id="+component.get("v.recordId")+ "&opp_name=" + component.get("v.data.opp_name")+ "&cim_id=" + component.get("v.data.cimId")+ "&token=" + component.get("v.sessionId")+ "&products=" + a));
                component.set("v.urlParams", encodeURI(SAHost + "req_id=" + req_id + "&source=" + component.get("v.source") + "&wwid=" + component.get('v.userWWID')+ "&eMail=" + component.get('v.userEmail')+ "&allowfullscreen=true"+"&webkitallowfullscreen=true"+"&mozallowfullscreen=true" +"&opp_id="+component.get("v.recordId")+ "&cim_id=" + component.get("v.data.cimId")+ "&token=" + component.get("v.sessionId")+ "&products=" + a));
            	console.log(component.get("v.urlParams"));
                //alert(component.get("v.urlParams"));
            }
            else if(state === "INCOMPLETE") {
                // Call was incomplete log an error
                this.showToast('Error loading Salesassist application','error');
                console.log('SalesAssistsTab-->getUserSessionId call INCOMPLETE');
            }
			else if(state === "ERROR") {
            }
            window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isLoaded", true);
                }), 1500
            );
        });
        $A.enqueueAction(action);
        
	},
    showSpinner: function (component, event, helper){
    	window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.isLoaded", true);
                }), 1500
            );
	},
    getEOLData: function(component, event, helper) {
        var action = component.get("c.getEOLData");
        action.setParams({
            OppId : component.get("v.recordId")
            });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //if the call is successful and data is received. 
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                //component.set("v.spinner",false);
                component.set("v.data", response.getReturnValue());
                component.set("v.EOLCount",component.get("v.data.EOLCount"));
                var s = component.get("v.EOLCount")+" EOL products detected!";
                component.set("v.butnmsg",s);
                if(component.get("v.data.showPopUp")){
                    component.set("v.source", "opportunities_view");
                    helper.getURL(component, event, helper);
                }
            }
            else{
                //component.set("v.spinner",false);
                
            }
            
        });
        $A.enqueueAction(action);
	},
})