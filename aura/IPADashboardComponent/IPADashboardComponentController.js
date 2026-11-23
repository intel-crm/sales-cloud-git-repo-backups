({
    doInit : function(component, event, helper) {
        
      //  helper.fetchPartnerList(component, helper);
        var action=component.get('c.isBasicProfileBenefit');
         action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                    component.set("v.showLeadTab",false);
                }else{
                    component.set("v.showLeadTab",true);
                }
                component.set("v.showTabs", true);
              
            }
        });
        $A.enqueueAction(action);
        
        var benefitAction=component.get('c.isBasicProfileBenefit');
         benefitAction.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                
                var returnValue = response.getReturnValue();
                if(returnValue == true){
                   component.set("v.showOfferingTab",false);
                }else{
                   component.set("v.showOfferingTab",true);
                }
                component.set("v.showTabs", true);
              
            }
        });
        $A.enqueueAction(benefitAction);
        
        

  
        
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
    
    showLeads: function(component, event, helper) {
 		 window.open("https://crmdevint2-intelcloudcrm.cs93.force.com/partneradmin/s/");
	},
    showOfferings: function(component, event, helper) {
 		 window.open("https://crmdevint2-intelcloudcrm.cs93.force.com/imp/s/pmp-partner-offering/PMP_Partner_Offering__c/Default");
	},
   


	

 /*   onPartnerSelection : function(component, event, helper){
        component.set("v.showSpinner", true);
        
        
        
        var selectedOption = component.find("selectPartner").get("v.value");
        helper.updateOnePartnerId(component,helper,selectedOption);
        
    }	*/
                                       
})