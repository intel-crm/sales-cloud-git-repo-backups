({
    // Function Called on the load of the  page to fetch the RecordType name 
    fetchListOfRecordTypes: function(component, event, helper) {
        var objName;
        //Changes for claim :Checking PFR/PFC
        helper.getPageUrl(component);
        //to fetch record types in wrapper object
        var action = component.get("c.fetchRecordType");
        //pass the object name here for which you want
        var isPfr = component.get("v.isPfrUrl");
        //console.log('is pfr--' +isPfr);
        if(Boolean(isPfr)){
            //console.log('inside PFR');
            objName = $A.get("$Label.c.Core_MDF_PFRText");;
        }else{
            //console.log('inside PFC');
            objName = $A.get("$Label.c.Core_MDF_PFCText");; 
        }
        action.setParams({
            "objectName" : objName
        });
        action.setCallback(this, function(response){
            //console.log('response--' ,response.getReturnValue());
            //var wrapperRecordTypes = response.getReturnValue();
            component.set("v.recTypeWrapperList", response.getReturnValue());
            component.set("v.mapOfRecordTypeDevName", response.getReturnValue().recordTypeDevNameAndLabelName);//component.get("v.recTypeWrapperList.recordTypeDevNameAndLabelName"));
            component.set("v.mapOfRecordType", response.getReturnValue().recordTypeDevNameAndId);//component.get("v.recTypeWrapperList.recordTypeDevNameAndId"));
            
            
            var mapOfRecordTypesStringString = component.get("v.mapOfRecordTypeDevName");
            var mapOfRecordTypesStringId = component.get("v.mapOfRecordType");
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
            }
            else if(Object.keys(mapOfRecordTypesStringString).length == 0){//Object does not have any record types
                //Close Quick Action Modal here
                alert($A.get("$Label.c.Core_MDF_NoRecordTypeAccess"));
                helper.closeModal();
            }
                else {
                    var recordTypeList = [];
                    for(var key in mapOfRecordTypesStringString){
                        for(var newKey in mapOfRecordTypesStringId){
                            if(key == newKey){
                                recordTypeList.push({
                                    class: "optionClass",
                                    label: mapOfRecordTypesStringString[key],
                                    value: key
                                });
                            }
                        }
                    }
                    component.set("v.lstOfRecordType", recordTypeList); 
                } 
        });
        $A.enqueueAction(action);
    },
    
    // Function Called on the click of the Next button
    createRecord: function(component, event, helper, sObjectRecord) {
        // Changes for Claim
        var isPfr = component.get("v.isPfrUrl");
        //console.log('is pfr--' +isPfr);
        var selectedRecordTypeName = component.find("recordTypePickList").get("v.value");
        //alert("selectedRecordTypeName-->"+selectedRecordTypeName);
        //var excludedRecordType = $A.get("$Label.c.Core_MDF_PFR_RecordtypeCustomUI"); // Call Custom Label to which stores record type name
        if(Boolean(isPfr)){
            var excludedRecordType =$A.get("$Label.c.Core_MDF_PFR_RecordTypeUI");
        }else{
            var excludedRecordType=$A.get("$Label.c.Core_MDF_PFC_RecordtypeCustomUI");
        }
        var excludedRecordTypes = excludedRecordType.split(",");
        var exclude = excludedRecordTypes.includes(selectedRecordTypeName);
        if(selectedRecordTypeName != "" && !exclude){
            
            var selectedRecordTypeMap = component.get("v.mapOfRecordType");
            var selectedRecordTypeId;
            
            //finding selected recordTypeId from recordTypeName
            for(var key in selectedRecordTypeMap){
                if(selectedRecordTypeName == key){
                    selectedRecordTypeId = selectedRecordTypeMap[key];//match found, set value in selectedRecordTypeId variable
                    break;
                }
            }
            //Calling CreateRecord modal here without providing recordTypeId
            if(Boolean(isPfr)){
                helper.showCreateRecordModal(component, selectedRecordTypeId, $A.get("$Label.c.Core_MDF_PFRText"));
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
})