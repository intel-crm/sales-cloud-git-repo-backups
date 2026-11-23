({
	doInit : function(component, event, helper) {
		//helper.fetchPicklistVal(component,event,helper);
		//alert(component.get("v.SelNewsLetterOpt"));
		
	},
    
    LoadValues: function(component, event, helper) {
        var ques = component.getEvent("dynamicQuestionEvt");
        component.set("v.newPFRq.Core_MDF_PagetoLink_Nm__c",component.get("v.SelPageToLinkOpt"));
        component.set("v.newPFRq.Core_MDF_KPI_Nm__c",component.get("v.SelKPIOpt"));
        component.set("v.newPFRq.Core_MDF_NewsletterType_Nm__c",component.get("v.SelNewsLetterOpt"));
        component.set("v.newPFRq.Core_MDF_BannerAds_Nm__c",component.get("v.SelBannerAdsOpt"));
        component.set("v.newPFRq.Core_MDF_LinkRequired_Nm__c",component.get("v.LinkReqVal"));        
        component.set("v.newPFRq.Core_MDF_ClicksOrCirculation_Nm__c",component.get("v.ClicksCircVal"));
        component.set("v.newPFRq.Core_MDF_ClicksOrImpression_Nm__c",component.get("v.ClicksImprVal"));
        component.set("v.newPFRq.Core_MDF_Other_Nm__c",component.get("v.otherVal"));
        component.set("v.newPFRq.Core_MDF_PlacetoRun_Nm__c",component.get("v.placetorunVal"));
        //alert('Selected value change');
        ques.setParams({
            valueOfDynamicQ:component.get("v.newPFRq")
        }).fire();  
    },
    
    ResetValues : function(component, event, helper) {
        //alert('Activity type change');
    	component.set("v.SelPageToLinkOpt",null);
        component.set("v.SelKPIOpt",null);
        component.set("v.SelNewsLetterOpt",null);
        component.set("v.SelBannerAdsOpt",null);
        component.set("v.LinkReqVal",null);
        component.set("v.ClicksCircVal",null);
        component.set("v.ClicksImprVal",null);
        component.set("v.otherVal",null);
        component.set("v.placetorunVal",null);
        //helper.fetchPicklistVal(component,event,helper);
    }
})