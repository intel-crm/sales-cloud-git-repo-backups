({
	doInit : function(component, event, helper) {
       // alert('I am in do int');
        component.set('v.showSpinner',true);
		helper.isCommunity(component, event);        
		helper.fetchRecordInfo(component, event);
        
	},
    fetchFieldSetInfo : function(component, event, helper) {
        //alert('I am in fetchFieldSetInfo');
        if(component.get("v.recordInfoLoaded")) {
            //alert('I am in if of fetchFieldSetInfo 1');
            var recTypeDevName = $A.get('$Label.c.Core_MDF_IPA_Campaign_Record_Type_Dev_Name');
            recTypeDevName += $A.get('$Label.c.Core_MDF_Cmpgn_RecTypeCustomUI');
            if(recTypeDevName.includes(component.get("v.recordTypeDeveloperName"))) {
                //alert('I am in if of fetchFieldSetInfo 2');
                helper.checkForEditAccess(component, event);
                helper.fetchFieldSetInfo(component, event);
                component.set('v.showSpinner',false);
            } else if(!recTypeDevName.includes(component.get("v.recordTypeDeveloperName"))) {
                //alert('I am in elseif of fetchFieldSetInfo 1');
                component.set('v.fieldSetLoaded',false);
                component.set('v.nonCustomizedUI',true);
                setTimeout(function () {
                    component.set('v.showSpinner',false);
                }, 1000); 
            }
        }
	},
    
    customSave: function(component, event, helper) {
        try {
        	var res = component.find("edit").get("e.recordSave").fire();
        } catch (e) {
            console.log('err '+e);
        }
    },
   
    handleSaveSuccess : function(component, event,helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get("v.recordId"),
            slideDevName: "detail"
        },true);
        navEvt.fire();
        $A.get("e.force:closeQuickAction").fire();
        setTimeout(function () {
            window.location.reload();
        }, 2000);
    },
    
   closeModal: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": $A.get("$Label.c.Core_MDF_CampaignText")
        });
        homeEvent.fire();
    },
    
    prevPage: function(component, event, helper) {
        window.history.back();
        setTimeout(function () {
            window.location.reload();
        }, 100);
    },

    closeModalAndDisplayErrorMsg: function (component, event) {
        let closeModalEvent = component.getEvent("closeModalAndLogErrorMessageEvent");
        closeModalEvent.setParams({ errorLog: event.getParam('errorLog')});
        closeModalEvent.fire();
    },
    
    showStickyToastMessage: function(component, event) {
        var errorMessage = event.getParam("errorMessage");
         var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": errorMessage,
                "type" : "error",
                "mode" : "dismissable",
                "duration": 10000,
            });
            toastEvent.fire();
    }

})