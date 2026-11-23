({
   init: function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: 'Claim Name', fieldName: 'Title', type: 'text'},
            { label: 'ClaimReferenceNo', fieldName: 'Core_MDF_Claim_Ref_Number__c', type: 'text'},
            { label: 'Account', fieldName: 'Core_MDF_AccountCompany__c', type: 'text'},
            { label: 'Program', fieldName: 'Core_MDF_Program__c', type: 'Formula'}
            
        ]);
        helper.getData(cmp);
    }
})