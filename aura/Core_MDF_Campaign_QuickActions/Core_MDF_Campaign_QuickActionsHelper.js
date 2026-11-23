({
    fetchRecordInfo : function(component, event) {
        var action = component.get("c.loadCampaignRecord");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if (response.getState() == "SUCCESS") {
                component.set("v.recordTypeId", result.RecordTypeId);
                console.log("recordTypeId :::&&& "+result.RecordTypeId);
                component.set("v.recordTypeName", result.RecordType.Name);
                console.log("recordTypeName :::&&& "+result.RecordType.Name);
                component.set("v.recordTypeDeveloperName", result.RecordType.DeveloperName);
                console.log("recordTypeDeveloperName :::&&& "+result.RecordType.DeveloperName);
                component.set("v.campaignStatus", result.Status);
                console.log("campaignStatus :::&&& "+result.Status);
               // component.set("v.mode", "edit");
                component.set("v.recordInfoLoaded", true);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFieldSetInfo:function(component, event) {
        console.log("fetchFieldSetInfo called");
        var action = component.get("c.getRtFieldSetMappings");
        action.setParams({
            objectName : "Campaign",
            recordTypeDeveloperName : component.get("v.recordTypeDeveloperName")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            console.log("result "+JSON.stringify(result));
            if (response.getState() == "SUCCESS") {
                console.log("result "+JSON.stringify(result));
                component.set("v.fieldSetName", result);
                
            }
        });
        $A.enqueueAction(action);
    }
})