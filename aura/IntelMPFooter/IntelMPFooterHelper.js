({
    setUserLangLocale: function(component, event, helper) {    
        var analyticsUserLangLocale = 'us-en';
              
        switch ($A.get("$Locale.langLocale"))
        {
            case "zh_CN":
                analyticsUserLangLocale = "cn-zh";
                break;
            case "zh_TW":
                analyticsUserLangLocale = "tw-zh";
                break;
            case "ja":
                analyticsUserLangLocale = "jp-ja";
                break;
            case "fr":
                analyticsUserLangLocale = "fr-fr";
                break;
            case "de":
                analyticsUserLangLocale = "de-de";
                break;
            case "ko":
                analyticsUserLangLocale = "kr-ko";
                break;
            case "es":
                analyticsUserLangLocale = "es-es";
                break;
            case "it":
                analyticsUserLangLocale = "it-it";
                break;
            case "pt_BR":
                analyticsUserLangLocale = "br-pt";
                break;
            case "ru":
                analyticsUserLangLocale = "ru-ru";
                break;
        }      

        //******************************************************************************
        try{
            if(window.location.href != null){
                try{
                    var urlStr = window.location.href;
                    var isProdEnv = urlStr.match(/marketplace.intel.com/); // /\/\/marketplace.intel.com\//             
                                       
                    if(isProdEnv != null){
                    	window.digitalData.environment = 'prod';
                    }else{
                    	window.digitalData.environment = 'dev'; 
                    }
                                        
                    var action = component.get("c.fetchUser");
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var storeResponse = response.getReturnValue();

                            if(storeResponse != null && storeResponse.Contact !== undefined
                              && storeResponse.Contact.Core_eRPM_Person_Id__c !== undefined
                              && storeResponse.Contact.Core_eRPM_Person_Id__c != null){
                                window.digitalData.erpmId =  storeResponse.Contact.Core_eRPM_Person_Id__c;                             
                            }
                        }
                        window.digitalData.localCode = analyticsUserLangLocale;
                        loadAnalyticsScript(analyticsUserLangLocale);  // Used for calling the function in the head script
                    });
                    $A.enqueueAction(action);
                   
                }catch(e){
                    console.log(e);
                }
                
            }            
        }catch(e){
        	console.log(e);  
        }
    }
})