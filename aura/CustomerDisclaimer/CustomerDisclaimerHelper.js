({
    handleOnAgreeHelper : function(component) {
        var resToSiteUrlMap = component.get("v.resToSiteUrlMap");
        var rIdForDisplay = component.get("v.resourceIdForDisplay");     
        var rIdForStore = component.get("v.resourceIdForStore");
        var resourceIdForStore=rIdForStore.pop();
        var tncToRes = component.get("v.finalMapToStore");
        tncToRes[resourceIdForStore]=resToSiteUrlMap[resourceIdForStore];
        component.set("v.finalMapToStore",tncToRes);
        if(rIdForDisplay.length>0){
            this.loadNDAPerRes(component);
        } 
        else{
            var action = component.get("c.agreementSave");        
            action.setParams({
                "tncToUrlMapToStore" : tncToRes
            });
            action.setCallback(this, function(response) {
                var state = response.getState(); 
                if (state === "SUCCESS") { 
                    var outputMap=response.getReturnValue();
                    if(outputMap!=null){
                      for (var value in outputMap){
                        var r = outputMap[value];
                        if(r==true){
                            var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/"
                            });
                             urlEvent.fire();
                            this.pageReload("/Partnercenter/s/");
                            
                        }
                        else{
                            var logoutRedirect = $A.get("$Label.c.PartnerCenterLogout");
                            window.open(logoutRedirect,"_self");                
                        }
                        
                    }                        
                    }
                    else{
                        var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                            this.pageReload('/errorpage');
                    }
                    
                }
                else {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            //in case of error set the error message in the error div.
                           var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                           this.pageReload('/errorpage');
                        }
                    } 
                    
                }
            });
        }
        $A.enqueueAction(action);
    },

    getResourceName : function(component) {
        // call apex method to fetch list view dynamically
        var action = component.get("c.getResourceName");
        var url = window.location.href;
        url = url.substring( 0, url.indexOf("customerdisclaimer"));
        action.setParams({
                "siteUrl" : url
            });
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === "SUCCESS") {
                var error;
                var disclaimerDetails=response.getReturnValue();
                if(disclaimerDetails==null){error = 'Error in getResource'}
                else{
                this.loadNDABody(component,disclaimerDetails);
                this.loadNDAPerRes(component);
                error = component.get("v.accessErrorMsg");
                }
                
                if(error != '' ){
                    var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                    this.pageReload('/errorpage');
                }
            }             
            else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //in case of error set the error message in the error div.
                        component.set("v.accessErrorMsg", errors[0].message); 
                        //component.set("v.isLoading",'false');
                         var urlEvent = $A.get("e.force:navigateToURL");
                            urlEvent.setParams({
                                "url": "/errorpage"
                            });
                             urlEvent.fire();
                    }
                } 
                
            }
        });
        $A.enqueueAction(action); 
    },
    
    loadNDAPerRes: function(component) {
        var r = component.get("v.resourceIdForDisplay");
        var resourceName=r.pop();
        var resToContentMap = component.get("v.resToContentMap");
        var acceptanceText = $A.get("$Label.c.CustomerDisclaimerAgreeTxt");
        if(resToContentMap[resourceName] != ''){
        component.set("v.html", resToContentMap[resourceName]);
        component.set("v.acceptanceText",acceptanceText);    
        component.set("v.accepted",false);
        component.set("v.hideButton", true);
        
        }
        else{
            component.set("v.accessErrorMsg", "Error Occurred");
        }

    },
    
    loadNDABody: function(component,disclaimerDetails) {
        var resourceIdForDisplay = [];
        var resourceIdForStore = [];
        for(var i = 0; i < disclaimerDetails.length; i++){
            resourceIdForDisplay.push(disclaimerDetails[i].tncId);
            resourceIdForStore.push(disclaimerDetails[i].tncId);
            component.set("v.resourceIdForDisplay", resourceIdForDisplay);
            component.set("v.resourceIdForStore",resourceIdForStore);
            var resToSiteUrlMap = component.get("v.resToSiteUrlMap");
            resToSiteUrlMap[disclaimerDetails[i].tncId]=disclaimerDetails[i].communityUrl;
            component.set("v.resToSiteUrlMap",resToSiteUrlMap);            
            var resToContentMap = component.get("v.resToContentMap");
            if(disclaimerDetails[i].docBody == ''){
            component.set("v.accessErrorMsg", "Error Occurred");}
            else{component.set("v.accessErrorMsg", "");}
            resToContentMap[disclaimerDetails[i].tncId]=disclaimerDetails[i].docBody;
            component.set("v.resToContentMap",resToContentMap);
        }
    },
    pageReload: function (url) {
        setTimeout(() => {
            if(window.location.href.includes(url)) {
                window.location.reload(true);
            }
        }, $A.get("$Label.c.Core_MDF_CommunityPageReload_Timer"))
    },
    
})