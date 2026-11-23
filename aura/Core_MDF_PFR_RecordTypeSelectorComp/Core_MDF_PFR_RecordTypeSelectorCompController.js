({
    doInit: function(cmp, event, helper) {
        console.log('createActivityFromCampaign ---> ', cmp.get("v.recordId"))
        var pageReference = cmp.get("v.pageReference");
        if(pageReference != null){
           cmp.set("v.recordId", pageReference.state.c__recordId);
           cmp.set("v.isCampaignUrl", pageReference.state.c__isCampaignUrl);
           
           cmp.set("v.createActivityFromCampaign", true);
        }
    },
    onPageReferenceChanged: function(cmp, event, helper) {
         console.log('InsideonPageReferenceChanged');
        $A.get('e.force:refreshView').fire();
    },
    // Function Called on the load of the page to fetch the RecordType name 
    fetchListOfRecordTypes: function(component, event, helper) {
        var objName;
            var sObjectType = component.get("v.sobjecttype");

        console.log('recordId'+ component.get("v.recordId"));
        component.set("v.IPARecTypeName",$A.get("$Label.c.Core_MDF_IPA_RecordType"));
        //Changes for claim :Checking PFR/PFC
        
        helper.getPageUrl(component);
        // to get the object - rectype - fieldset mapping
        if(component.get("v.isCampaignPage")) {
            var action = component.get("c.getRtFieldSetMappings");
            action.setParams({
                "objectName" : "Campaign",
                "pickListObj" : "Core_MDF_Custom_Picklist__c",
                "executionContext" : "create"
            });
            action.setCallback(this, function(response){
                var result = response.getReturnValue();
                if(result != null && result != undefined) {
                    component.set("v.metadataList",result);
                }
            });
            $A.enqueueAction(action);
        }
        //to fetch record types in wrapper object
        var action = component.get("c.fetchRecordType");
        //pass the object name here for which you want
        var isPfr = component.get("v.isPfrUrl");        
        console.log('isPfr->'+isPfr);
        if(Boolean(isPfr)){
            console.log('inside PFR');
            objName = $A.get("$Label.c.Core_MDF_PFRText");
        }else if(component.get("v.isCampaignPage")){ 				//Changes for Create Campaign
            objName = $A.get("$Label.c.Core_MDF_CampaignText");
         }else{
            objName = $A.get("$Label.c.Core_MDF_PFCText");
         }
        action.setParams({
            "objectName" : objName
        });
        action.setCallback(this, function(response){

            //var wrapperRecordTypes = response.getReturnValue();
           
            component.set("v.recTypeWrapperList", response.getReturnValue());
            component.set("v.mapOfRecordTypeDevName", response.getReturnValue().recordTypeDevNameAndLabelName);//component.get("v.recTypeWrapperList.recordTypeDevNameAndLabelName"));
            component.set("v.mapOfRecordType", response.getReturnValue().recordTypeDevNameAndId);//component.get("v.recTypeWrapperList.recordTypeDevNameAndId"));
            
            
            
            
            var mapOfRecordTypesStringString = component.get("v.mapOfRecordTypeDevName");
            var mapOfRecordTypesStringId = component.get("v.mapOfRecordType");
            console.log('record type size-- '+Object.keys(mapOfRecordTypesStringString).length);
            console.log('mapOfRecordTypesStringString'+JSON.stringify(mapOfRecordTypesStringString));
            console.log('mapOfRecordTypesStringId'+JSON.stringify(mapOfRecordTypesStringId));
            console.log('mapOfRecordTypesStringString length'+Object.keys(mapOfRecordTypesStringString).length);
            //console.log('record type size-- '+Object.keys(mapOfRecordTypesStringString).length);
            if(Object.keys(mapOfRecordTypesStringString).length == 1 ) //mapOfRecordTypesStringString.length == 1
            {
                for(var key in mapOfRecordTypesStringString){
                    for(var newKey in mapOfRecordTypesStringId){
                        if(key == newKey){
                            component.set("v.selrecordtypeDeveloperName",key);
                            component.set("v.selrecordtypeName",mapOfRecordTypesStringString[key]);
                            component.set("v.selrecordtype",mapOfRecordTypesStringId[newKey]);  
                        }  
                    } 
                }
                // US751799 - Restricting IPA User to create IPA activity from New Button
              /* if(component.get("v.isPfrUrlNew") && $A.get("$Label.c.Core_MDF_IPA_RecordType") ==component.get("v.selrecordtypeDeveloperName")) {
                    helper.showToast(component, 'Error', $A.get("$Label.c.Core_MDF_IPANewBtnErrMsg"), '5000', 'info_alt', 'error', 'dismissible');
                    helper.closeModal();
                }*/
                var customUIRecTypes =$A.get("$Label.c.Core_MDF_Cmpgn_RecTypeCustomUI");
                var customUIRecTypesList = customUIRecTypes.split(",");
                if(component.get("v.isCampaignPage") && !customUIRecTypesList.includes(component.get("v.selrecordtypeDeveloperName"))){
                    helper.showCreateRecordModal(component, component.get("v.selrecordtype"), $A.get("$Label.c.Core_MDF_CampaignText"));
                }  
                var metadataRecs = component.get("v.metadataList");

                if(metadataRecs != null && metadataRecs != undefined ){
                    for(let i=0;i<metadataRecs.length;i++){
		    	//Metadata disposition - changed text field references to picklist fields
                        if(metadataRecs[i].Core_MDF_Record_Type_DeveloperName_nm__c == component.get("v.selrecordtypeDeveloperName")) {
                            component.set("v.fieldsetname", metadataRecs[i].Core_MDF_Field_Set_API_Name_nm__c);
                            break;
                        }
                    }
                }

            }
            else if(Object.keys(mapOfRecordTypesStringString).length == 0 ){//Object does not have any record types
                //Close Quick Action Modal here
                console.log('record type size-- inside else if block');
                //alert($A.get("$Label.c.Core_MDF_NoRecordTypeAccess"));
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        duration: 5000,
                        message: $A.get("$Label.c.Core_MDF_NoRecordTypeAccessError"),
                        type: "error"
                    });
                toastEvent.fire();
                //helper.closeModal();
                var homeEvent = $A.get("e.force:navigateToObjectHome");
                 homeEvent.setParams({
                   "scope": objName
                });
                homeEvent.fire();
                
            }
            else {
                    console.log("hasCampAccess->",component.get("v.hasNoCampRecordType"));
                    component.set("v.checkForMultiRecordTypeAccess",true);
                    var recordTypeList = [];
                    for(var keyMap in mapOfRecordTypesStringString){
                        for(var newKeyMap in mapOfRecordTypesStringId){
                            if(keyMap == newKeyMap){
                                recordTypeList.push({
                                    class: "optionClass",
                                    label: mapOfRecordTypesStringString[keyMap],
                                    value: keyMap
                                });
                            }
                        }
                    }
                    component.set("v.lstOfRecordType", recordTypeList);
                    console.log('Final Record Type List'+recordTypeList);
                } 
        });
        $A.enqueueAction(action);
        //this is true only when the activity is getting created from the Campaign page
        var isCampaign = component.get("v.isCampaignUrl");
        console.log('isCampaign->'+isCampaign);
		var result;
        //fetching all the campaign fields values
        var actionLoadCampaign = component.get("c.getCampaignFields");
		if(Boolean(isCampaign)){
            //calling the method which returns True when the user has Create permission on object level            
            var actionHasPermission = component.get("c.checkSObjectCreatePermission");
            //Passing the Object name as PartnerFundRequest to check the CRUD permission for this object
            actionHasPermission.setParams({
                "objectName" : "PartnerFundRequest"
            });
            actionHasPermission.setCallback(this, function(response) {
                //storing the return value got from the method called to check the CRUD in the below variable
                var createPermission = response.getReturnValue();
                //setting this return value in the below attribute which is used in the component file for throwing the error on the UI
                component.set("v.hasCreatePermission", createPermission);
            });
            $A.enqueueAction(actionHasPermission);
            actionLoadCampaign.setParams({
                recordId: component.get("v.recordId")
            });
            actionLoadCampaign.setCallback(this, function (response) {
                result = response.getReturnValue();
                console.log('industrytest: ',result);
                if(result != undefined && result != null ) {                    
                      component.set("v.campaignRecordTypeName", result.RecordType.DeveloperName);
                    component.set("v.campaignObject", result);
                   /* component.set("v.selrecordtype", result.RecordTypeId);
                    console.log('createActivity'+result.RecordTypeId);
                     component.set("v.selrecordtypeDeveloperName",result.RecordType.DeveloperName);
                      component.set("v.selrecordtypeName",result.RecordType.Name);
                     console.log('devNameact'+result.RecordType.DeveloperName);
                     console.log('nameact'+result.RecordType.Name);**/
                    /*component.set("v.pfrRec.Core_MDF_Start_Date__c", result.StartDate);
                    component.set("v.pfrRec.Core_MDF_End_Date__c", result.EndDate);*/
                    //checking if the campaign status is not in Draft and Revision Required status
                    if(result.Status != $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA") && result.Status != $A.get("$Label.c.Core_MDF_PFR_Revision_Required") && (((result.Core_MDF_Program__c ==$A.get("$Label.c.Core_MDF_Localized_IPA_Name"))&& result.Core_MDF_Proposal_Based_Ind__c == true)))
                    {	
                        component.set("v.restrictActivityCreation", true);
                      if((result.Core_MDF_Program__c ==$A.get("$Label.c.Core_MDF_Localized_IPA_Name")) && result.Core_MDF_Proposal_Based_Ind__c == true) 
                      {
                          component.set("v.checkIPAerror", true);
                      } 
                       
                    }
                    else if(result.Status === $A.get("$Label.c.Core_MDF_PFR_Status_Draft_IPA") && ((result.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_NonTranslateCCFRecordType") || result.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_NonTranslateDCFRecordType")))){
                        component.set("v.hasCreatePermission", false);
                    }
                    else if(result.Core_MDF_Opal_Budget_Type_Txt__c=='CCF 1.0' || result.Core_MDF_Opal_Budget_Type_Txt__c=='DCF 1.0'){
                        //component.set("v.isLegacyBudgetType",true);
                        //component.set("v.hasCreatePermission", false);
                        //component.set("v.checkLegacyError", true);
                        
                    }
                    
                    
                    
                    if(result.Core_MDF_Supports_legacy_program__c != "Yes" && (result.Core_MDF_Program__c ==$A.get("$Label.c.Core_MDF_CCF_RecordType") || result.Core_MDF_Program__c == $A.get("$Label.c.Core_MDF_DCF_Program_Name"))){
                        component.set("v.isActivityCreatedFromCamp",true);
                    }
                    helper.populateRecordTypeOnActivity(component,event,helper);
          
                }
            });
            
            $A.enqueueAction(actionLoadCampaign);
         }
     component.set("v.viewModal",true);
        //restrictActivityCreation
        
         /**var userperMap = component.get("v.userperMap");
         var permissionSetName;
         var permissionSets = [];
        
         permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_CCF_DCF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["externalper"] = permissionSets;
        
         permissionSetName = $A.get("$Label.c.Core_MDF_CCP_External_User_RMF");
        permissionSets = [];
        permissionSets = permissionSetName.split(",");
        userperMap["rmfexternalper"] = permissionSets;
        
        var action = component.get("c.userHasPermissionSet");
        action.setParams({
            permissionsets: userperMap
        });
        action.setCallback(this, function (response) {
            component.set('v.userperMap', '{}');
            component.set('v.userperMap', response.getReturnValue().userPermissions);
            var mapResults = component.get("v.userperMap");
            var state = response.getState();
            if (state === "SUCCESS") {
                for (var key in mapResults) {
                    component.set("v." + key, mapResults[key]);
                }
            }
            
            //restrict activity creation(RMF External)
            if(component.get("v.isActivityCreationOnCampaign") == true && component.get("v.rmfexternalper") == true && component.get("v.externalper") == false){
                var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: "Error",
                        message: $A.get("$Label.c.Core_MDF_RMFExternalError"),
                        type: "error"
                    });
                    toastEvent.fire();
                    component.find("navService").navigate({
                        "type": "standard__recordPage",
                        "attributes": {
                            "recordId": component.get("v.RecordTypeId"),
                            "objectApiName": "Campaign",
                            "actionName": "view"
                        }
                    });

				}
        });**/
    },
    
    // Function Called on the click of the Next button
    createRecord: function(component, event, helper, sObjectRecord) {
        // Changes for Claim
        var isPfr = component.get("v.isPfrUrl");
        var excludedRecordType;
        //console.log('is pfr--' +isPfr);
        var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
        //alert("selectedRecordTypeName-->"+selectedRecordTypeName);
        //var excludedRecordType = $A.get("$Label.c.Core_MDF_PFR_RecordtypeCustomUI"); // Call Custom Label to which stores record type name
        

        if(Boolean(isPfr)){
            excludedRecordType =$A.get("$Label.c.Core_MDF_PFR_RecordTypeUI");
        }else if(component.get("v.isCampaignPage")){
            excludedRecordType =$A.get("$Label.c.Core_MDF_Cmpgn_RecTypeCustomUI");
        }else{
             excludedRecordType=$A.get("$Label.c.Core_MDF_PFC_RecordtypeCustomUI");
        }
        
        var excludedRecordTypes = excludedRecordType.split(",");
        var exclude = excludedRecordTypes.includes(selectedRecordTypeName);
        // US751799 - Restricting IPA User to create IPA activity from New Button
       /* if(component.get("v.isPfrUrlNew") && $A.get("$Label.c.Core_MDF_IPA_RecordType") ==selectedRecordTypeName) {
            helper.showToast(component, 'Error', ''+$A.get("$Label.c.Core_MDF_IPANewBtnErrMsg"), '5000', 'info_alt', 'error', 'dismissible');
        } else*/ if(selectedRecordTypeName != "" && !exclude){
            
            var selectRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeId;
            
            //finding selected recordTypeId from recordTypeName
            for(var keyRecordType in selectRecordTypeMap){
               // if(selectRecordTypeName == keyRecordType){
               if(selectedRecordTypeName == keyRecordType){
                    selectedRecordTypeId = selectRecordTypeMap[keyRecordType];//match found, set value in selectedRecordTypeId variable
                    break;
                }
            }
            //Calling CreateRecord modal here without providing recordTypeId
            if(Boolean(isPfr)){
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_PFRText"));
            }else if(component.get("v.isCampaignPage")){ //Changes done for Create Campaign
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_CampaignText"));
            }else{
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_PFCText"));    
            }
        } else if(selectedRecordTypeName != "" && exclude){
            var selectedRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeMapstringstring = component.get("v.mapOfRecordTypeDevName");
            //finding selected recordTypeId from recordTypeName
            for(var key in selectedRecordTypeMap){
                for(var keynew in selectedRecordTypeMapstringstring){
                    if(key == keynew && key == selectedRecordTypeName){
                        component.set("v.selrecordtypeDeveloperName",selectedRecordTypeName);
                        component.set("v.selrecordtype", selectedRecordTypeMap[key]);
                        component.set("v.selrecordtypeName",selectedRecordTypeMapstringstring[keynew]);
                    }
                    
                }
            }  
            var metadataRecs = component.get("v.metadataList");
            if(metadataRecs != null && metadataRecs != undefined ){
                for(let i=0;i<metadataRecs.length;i++){
                    //Metadata disposition - changed text field references to picklist fields
                    if(metadataRecs[i].Core_MDF_Record_Type_DeveloperName_nm__c == component.get("v.selrecordtypeDeveloperName")) {
                        component.set("v.fieldsetname", metadataRecs[i].Core_MDF_Field_Set_API_Name_nm__c);
                        break;
                    }
                }
            }  
        } 
            else{
                alert('You did not select any record type');
            }
        
    },
    
    // Function Called on Cancel or "X"
    closeModal: function(component, event, helper) {
        //Chnages for Claim
        var isPfr = component.get("v.isPfrUrl");
        var objName;
        //Navigate to batch stage record, if popup close from batch stage record
        if(!$A.util.isUndefinedOrNull(component.get("v.batchRecordId"))){
            var homeEvent = $A.get("e.force:navigateToSObject");
            homeEvent.setParams({
                "recordId": component.get("v.batchRecordId")
            });
            homeEvent.fire();
        }else{
            if(Boolean(isPfr)){
                objName =  $A.get("$Label.c.Core_MDF_PFRText");
            }else if(component.get("v.isCampaignPage")){
                objName = $A.get("$Label.c.Core_MDF_CampaignText");
            }else{
                objName = $A.get("$Label.c.Core_MDF_PFCText");
            }
            var homeEvent = $A.get("e.force:navigateToObjectHome");
            homeEvent.setParams({
                "scope": objName
            });
            homeEvent.fire();
        }        
    }
    /*closeModalFormCampaign: function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var homeEvent = $A.get("e.force:navigateToSObject");
        homeEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        homeEvent.fire();
        $A.get("e.force:refreshView").fire();
    }*/
});