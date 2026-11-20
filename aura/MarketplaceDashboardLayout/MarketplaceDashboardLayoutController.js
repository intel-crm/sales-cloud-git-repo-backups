({
    doInit : function(component, event, helper) {
        
        //  helper.fetchPartnerList(component, helper);
        //Created as part of US528777/US613062 
        var action=component.get('c.isMarketingSpecialistAndOfferingEditor');
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    component.set("v.showLeadTab",false);
                }else{
                    component.set("v.showLeadTab",true);
                }
                component.set("v.showTabs", true);
                console.log('returnValueforMS',returnValue);
                
                
            }
        });
        $A.enqueueAction(action);
        
        
        //Created  as part of US528775
        var benefitActionforOE=component.get('c.isBasicProfileBenefitForOE');
        benefitActionforOE.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    
                    component.set("v.showPartnerKeyMetricsTab",false);
                    
                    //component.set("v.showOfferingTab",false); 
                    // IPA2.0 + US TWC4497-1631
                }
                
                component.set("v.showTabs", true);
                
                
                
            }
        });
        $A.enqueueAction(benefitActionforOE);
        
        var benefitAction=component.get('c.isBasicProfileBenefit');
         
        benefitAction.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                console.log('dashboard');
                
                var returnValue = response.getReturnValue();
                // IPA2.0 + US TWC4497-1631
                // if(returnValue == true){
                      
                //      component.set("v.showOfferingTab",false); 
                // }else{
                    
                //     component.set("v.showOfferingTab",true);
                // }
                // console.log('returnValueOff',returnValue);
                component.set("v.showTabs", true);
                
        
           }
        });
        $A.enqueueAction(benefitAction);
        // Created as part of US602030
        var MPAdmin=component.get('c.isMPAdmin');
        MPAdmin.setCallback(this, function(response) {
           if (response.getState() == "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    component.set("v.showPartnerTab",true);
                }else{
                    component.set("v.showPartnerTab",false);
                }
                component.set("v.showTabs", true);
                console.log('returnValue1',returnValue);
            }
        });
        $A.enqueueAction(MPAdmin);
         
       var action1=component.get('c.isEmployee');
        action1.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log('returnValue'+returnValue);
                if(returnValue == true){
                    component.set("v.showLeadTab",true);
                }
                else
                   {
                    component.set("v.showLeadTab",false);
                }
                    
               
                    
                component.set("v.showTabs", true);
                
                
            }
        });
        $A.enqueueAction(action1);
        
    
      var benefitActionforOE=component.get('c.isLeadTabforAdminsAndLDR');
        benefitActionforOE.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    
                  
                    
                    component.set("v.showLeadTab",true); 
                    
                 
                }
                
                
                component.set("v.showTabs", true);
                
                
                
            }
        });
        $A.enqueueAction(benefitActionforOE);
        
        
        
        window.addEventListener('resize', $A.getCallback(function() {
            if(component.isValid()) {
                var currentScreenSize = window.innerWidth < 768 ? 'mobile' : 'desktop';
                var prevScreenSize = component.get('v.appState.Settings.currentScreenSize');
                if (currentScreenSize != prevScreenSize) {
                    helper.dispatch(component, 'changeSetting', {
                        currentScreenSize: currentScreenSize
                    });
                }
                
                var bpList = [{bp: 'small', maxWidth:768},{bp: 'medium', maxWidth:1024},{bp: 'large', maxWidth:1280},	{bp: 'x-large', maxWidth:10000}	];
                var currentSldsBreakpoint = bpList.find(function(bp){	return (window.innerWidth < bp.maxWidth);	}).bp;
                
                var prevSldsBreakPoint = component.get('v.appState.Settings.currentSldsBreakPoint');
                if (currentSldsBreakpoint != prevSldsBreakPoint) {
                    helper.dispatch(component, 'changeSetting', {
                        currentSldsBreakPoint: currentSldsBreakpoint
                    });
                }
            }
        }));
        
    },
    
    /*   onPartnerSelection : function(component, event, helper){
        component.set("v.showSpinner", true);
        
        
        
        var selectedOption = component.find("selectPartner").get("v.value");
        helper.updateOnePartnerId(component,helper,selectedOption);
        
    }	*/
    
})