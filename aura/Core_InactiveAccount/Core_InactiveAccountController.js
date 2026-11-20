({
	doInit : function(component, event, helper) {
		helper.getData(component, event, helper);
	},
    handleRecordUpdated: function(component, event, helper) {
        var changeType = event.getParams().changeType;
        var changedFields = event.getParams().changedFields;
        console.log('changeFields'+JSON.stringify(changedFields));
        if (changeType === "CHANGED" && changedFields && (changedFields.hasOwnProperty('Core_First_Customer_Ship_Date__c') || changedFields.hasOwnProperty('StageName'))) {
            // if First Customer ship date is changed then check quarter again
            helper.get6QPSData(component);
        }
    }
})