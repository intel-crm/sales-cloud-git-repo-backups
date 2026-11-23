({
    doInit : function(component, event, helper) {
        component.set("v.myTeamMemcolumns", [
            { label: "Team Member", fieldName: "Name", type: "text"},
            { label: "Access Level", fieldName: "OpportunityAccessLevel", type: "text"},
            { label: "Member Role", fieldName: "TeamMemberRole", type: "text"},
            { label: "Team Member Region", fieldName: "Core_Team_Member_Geo__c", type: "text"}
        ]);
        component.set("v.myInactivePrdctcolumns", [
            { label: "Name", fieldName: "Name", type: "text"},
            { label: "Type", fieldName: "Core_Product_Type__c", type: "text"},
            { label: "Quantity", fieldName: "Quantity", type: "text"},
            { label: "Total Price", fieldName: "TotalPrice", type: "text"},
            { label: "Product Status", fieldName: "Core_Status__c", type: "text"}
        ]);
        component.set("v.myInacPartnercolumns", [
            { label: "Name", fieldName: "Name", type: "text"},
            { label: "Type", fieldName: "Core_Partner_Role__c", type: "text"},
            { label: "Quantity", fieldName: "Core_Partner_Type__c", type: "text"},
            { label: "Total Price", fieldName: "Core_Partner_Program__c", type: "text"},
            { label: "Product Status", fieldName: "Core_Partner__r.Core_Deactivated__c", type: "text"}
        ]);
        //helper.getData(cmp);
        helper.getExistingData(component, event, helper);
    },
    cloneOpp : function(component, event, helper) {
        helper.showSpinner(component);
        
        helper.cloneOppHelper(component, event, helper);
    }
})