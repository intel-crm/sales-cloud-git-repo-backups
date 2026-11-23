({
    // Function Called when the Recordtype does not intialize the Child component 
    // and calls standard record creation page 
    showCreateRecordModal : function(component, recordTypeId, entityApiName) {
        
        var createRecordEvent = $A.get("e.force:createRecord");
        if(createRecordEvent){ //checking if the event is supported
            if(recordTypeId){//if recordTypeId is supplied, then set recordTypeId parameter
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    "recordTypeId": recordTypeId,
                });
            } else{//else create record under master recordType
                createRecordEvent.setParams({
                    "entityApiName": entityApiName,
                    
                });
            }
            createRecordEvent.fire();
        } else{
            alert('This event is not supported');
        }
    },
    
    closeModal: function(component, event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": $A.get("$Label.c.Core_MDF_PFRText")
        });
        homeEvent.fire();
    },
    
    createPaymentRunRecord : function(component) {
        var navEvt = $A.get("e.force:createRecord");    
        navEvt.setParams({
            entityApiName: $A.get("$Label.c.Core_MDF_Payment_Run"),
            recordTypeId: component.get("v.selrecordtype")
        });    
        navEvt.fire();
    },
    
    // This function called to get page url and checking for PFR
    getPageUrl: function(component) {
        var curPageURL = decodeURIComponent(window.location.href);
        var sPageURL = curPageURL.toLowerCase();
        var recId = component.get("v.recordId");
        var pfrURL = $A.get("$Label.c.Core_MDF_PFR_URL").toLowerCase();
		var campaignCommunityUrl = $A.get("$Label.c.Core_MDF_Community_CampaignURL").toLowerCase();
        var campaignUrl = $A.get("$Label.c.Core_MDF_CampaignNew_URL").toLowerCase();
        var claimCommunityUrl = $A.get("$Label.c.Core_MDF_Community_ClaimURL").toLowerCase();
        var claimUrl = $A.get("$Label.c.Core_MDF_Claim_URL").toLowerCase();
        var campaignText = $A.get("$Label.c.Core_MDF_CampaignText").toLowerCase();
        var paymentRunUrl = $A.get("$Label.c.Core_MDF_Payment_Run").toLowerCase();
        var adjustmentUrl = "core_mdf_adjustment_request__c";
        var pageRef = component.get("v.pageReference");
		var isPfrFlag = pageRef && pageRef.state && pageRef.state.c__isPfrPage;
       	if(sPageURL.includes(pfrURL) || component.get("v.checkSaveandNew") || isPfrFlag){
       	 
            component.set("v.isPfrUrl", true);
            //If user is trying to clicking on SaveAndNew button, then its is copying values from previous activity.
            if(component.get("v.checkSaveandNew")){
                
                component.set("v.isActivityCreationOnCampaign",true);
                //component.set("v.recordId",null);
                
            }
        }
        
        else if((sPageURL.includes(campaignText) && recId != null && recId != undefined) || component.get("v.checkSaveandNew")){
            component.set("v.isActivityCreationOnCampaign",true);
            console.log("PDCheck"+component.get("v.isActivityCreationOnCampaign"));
            component.set("v.isPfrUrl", true);
            component.set("v.isCampaignUrl", true);
        } else if(sPageURL.includes(campaignCommunityUrl) || sPageURL.includes(campaignUrl)){ //Changes for Create Campaign
            component.set("v.isCampaignPage", true);
            component.set("v.viewModal",true);
        }else if(sPageURL.includes(paymentRunUrl.toLowerCase())){
            component.set("v.isPaymentRunPage", true);
        }else if(sPageURL.includes(adjustmentUrl.toLowerCase())){
            component.set("v.isAdjustmentPage", true);
        }else{
            component.set("v.viewModal",false);
        }/* else if(sPageURL.includes(claimCommunityUrl) || sPageURL.includes(claimUrl)){ //Changes for Create claim
            component.set("v.isPfcUrl", true);
        }*/
        console.log('CAmpaign Page Attribute value => '+component.get("v.isCampaignPage"));
        if(sPageURL.includes(pfrURL)) {
            component.set("v.isPfrUrlNew",true);
        }        
    },
    // This method displays toast message
    showToast : function(component, toastTitle, toastMsg, toastDuration, toastKey, toastType, toastMode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : toastTitle,
            message: toastMsg,
            duration: toastDuration,
            key: toastKey,
            type: toastType,
            mode: toastMode
        });
        toastEvent.fire();
    },
    populateRecordTypeOnActivity:function(component,event,helper){
        console.log("Rectype1->"+component.get("v.campaignRecordTypeName"));
        console.log("Rectype2->"+component.get("v.isActivityCreationOnCampaign"));
       if(component.get("v.campaignRecordTypeName") && component.get("v.isActivityCreationOnCampaign") == true){
            var recordTypeList = []; 
             var recordTypeUpdateList = []; 
            recordTypeList = component.get("v.lstOfRecordType");
            for (var i = 0; i < recordTypeList.length; i++) {
                console.log("Rectype3->"+recordTypeList[i].value);
                if(component.get("v.campaignRecordTypeName") == recordTypeList[i].value ){
               		console.log(recordTypeList[i].class,recordTypeList[i].label,recordTypeList[i].value);
                     recordTypeUpdateList.push({
                                    class: "optionClass",
                                    label: recordTypeList[i].label,
                                    value: recordTypeList[i].value
                                });
                     component.set("v.selrecordtypeDeveloperName",recordTypeList[i].value);
                     component.set("v.selrecordtypeName",recordTypeList[i].label);
                    break;
                }
                
                
            }
            
            component.set("v.lstOfRecordType",recordTypeUpdateList);
           var selectRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeId;
             var selectedRecordTypeName = component.get("v.selrecordtypeDeveloperName");

            //finding selected recordTypeId from recordTypeName
            for(var keyRecordType in selectRecordTypeMap){
               // if(selectRecordTypeName == keyRecordType){
               if(selectedRecordTypeName == keyRecordType){
                    selectedRecordTypeId = selectRecordTypeMap[keyRecordType];//match found, set value in selectedRecordTypeId variable
                    break;
                }
            }
                   var isPfr = component.get("v.isPfrUrl");

                     if(Boolean(isPfr)){
               // helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_PFRText"));
            }/*else if(component.get("v.isCampaignPage")){ //Changes done for Create Campaign
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_CampaignText"));
            }else{
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_PFCText"));    
            }*/
           
           
              
            var mapOfRecordTypesStringString = component.get("v.mapOfRecordTypeDevName");
            var mapOfRecordTypesStringId = component.get("v.mapOfRecordType");                
                for(var key in mapOfRecordTypesStringString){
                    for(var newKey in mapOfRecordTypesStringId){
                        if(key == newKey && key == selectedRecordTypeName){
                            //component.set("v.selrecordtypeDeveloperName",key);
                         //   component.set("v.selrecordtypeName",mapOfRecordTypesStringString[key]);
                            console.log('Inside Select Rec type => '+component.get("v.selrecordtypeName"));
                           component.set("v.selrecordtype",mapOfRecordTypesStringId[newKey]);  
                            break;
                        }  
                    } 
                }
           
       }    
        
    },
    /*openCoEngineeringFlow : function(component, recordTypeId) {        
        $A.createComponent(
            "lightning:flow",
            {
                "aura:id": "flowData"
            },
            function(flowCmp, status, errorMessage) {                
                if (status === "SUCCESS") {                    
                    component.find('overlayLib').showCustomModal({
                        body: flowCmp,
                        showCloseButton: true,
                        cssClass: "slds-modal_small"
                    });                    
                    flowCmp.startFlow(
                        "Core_MDF_Co_GTM_Payment_Run_Screen_Flow",
                        [
                            {
                                name: "recordTypeId",
                                type: "String",
                                value: recordTypeId
                            }
                        ]
                    );                    
                } else {
                    console.log("Flow creation error: " + errorMessage);
                }
            }
        );
    },
    /**
     * Generic method to open any Screen Flow inside a modal popup.
     * Delegates rendering to the reusable c:core_MDF_ScreenFlowLauncher LWC.
     *
     * @param {Aura.Component} component      - The component instance
     * @param {String}         flowApiName    - API name of the flow to launch
     * @param {String}         navigateTo     - Object API name to navigate to after flow finishes / is closed
     * @param {Array}          inputVariables - Optional array of flow input variables [{ name, type, value }]
     * @param {String}         headerTitle    - Optional modal header text; if empty header is hidden
     */
    openScreenFlow : function(component, flowApiName, navigateTo, inputVariables, headerTitle) {
        component.set("v.activeFlowName", flowApiName);
        component.set("v.activeFlowHeader", headerTitle || "");
        component.set("v.activeFlowNavigateTo", navigateTo || "");
        component.set("v.activeFlowInputVariables", inputVariables || []);
        component.set("v.showScreenFlow", true);
    }    
})