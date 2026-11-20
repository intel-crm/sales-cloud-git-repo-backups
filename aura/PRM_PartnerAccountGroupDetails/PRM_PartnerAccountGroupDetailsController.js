({ // eslint-disable-line
    init: function (component,event,helper) {
        var columns = [
            {
                type: 'url',
                fieldName: 'AccountUrl',
                label: 'Account/Contact Name',
                typeAttributes: {
                    label: { fieldName: 'Name' }
                },
                initialWidth: 300
            },
            {
                type: 'text',
                fieldName: 'BillingAddress',
                label: 'Account Country',
                
            },
            {
                type: 'boolean',
                fieldName: 'Core_Intel_Partner_Alliance_PartnerGroup__c',
                label: 'IPA Account',
                
            },
            {
                type: 'text',
                fieldName: 'Core_PAG_Grouping_Method__c',
                label: 'Grouping Method'
            },
            
            
            {
                type: 'text',
                fieldName: 'PartnerRole',
                label: 'Partner Role'
            },
            
            {
                type: 'text',
                fieldName: 'Email',
                label: 'Email'
            },
            {
                type: 'text',
                fieldName: 'ContactRelationship',
                label: 'ContactRelationship'
            }
            
        ];
        
        component.set('v.gridColumns', columns);
        
        var gridAction = component.get("c.GetPAGDetails");
        gridAction.setParams({
            recordId: component.get("v.recordId")
            
        });
        gridAction.setCallback(this, function(data) 
                               {
                                   
                                   var pagtreeDetails= data.getReturnValue();
                                   var state = data.getState();
                                   var error=data.getError();
                                   var pag_acct = pagtreeDetails.PAGAccounts[0];
                                   var intel_accts = pagtreeDetails.IntelAccounts;
                                   
                                   
                                   if (state === "SUCCESS" ) {
                                       var expandedRows=[];
                                       for (var i=0; i<intel_accts.length; i++ ) {
                                           expandedRows.push(intel_accts[i].Id);
                                          // intel_accts[i].BillingAddress='Intel Account';
											intel_accts[i].BillingAddress=intel_accts[i].Address;
                                           intel_accts[i].Core_Intel_Partner_Alliance_PartnerGroup__c=intel_accts[i].IPAAccount;
                                           intel_accts[i].AccountUrl='https://'+ window.location.hostname +'/lightning/r/Account/'+intel_accts[i].Id+'/view'
                                           intel_accts[i]._children = intel_accts[i]['cntDetails'];
                                           delete intel_accts[i].cntDetails; 
                                           for (var j=0; j< intel_accts[i]._children.length; j++ ) {
                                               intel_accts[i]._children[j].AccountUrl='https://'+ window.location.hostname +'/lightning/r/Contact/'+intel_accts[i]._children[j].Id+'/view'
                                               expandedRows.push(intel_accts[i]._children[j].Id);
                                           }
                                           
                                       }
                                       
                                       pagtreeDetails.PAGAccounts[0]._children=intel_accts;
										//pagtreeDetails.PAGAccounts[0].AccountType='One Partner ID';
                                       pagtreeDetails.PAGAccounts[0].BillingAddress=pagtreeDetails.PAGAccounts[0].Address;
                                       pagtreeDetails.PAGAccounts[0].AccountUrl='https://'+ window.location.hostname +'/lightning/r/Account/'+pagtreeDetails.PAGAccounts[0].Id+'/view'
                                       delete pagtreeDetails.IntelAccounts;
                                       
                                       component.set('v.gridData', pagtreeDetails.PAGAccounts);
                                       
                                       component.set('v.gridExpandedRows', expandedRows);
                                   }
                                   
                               });
        $A.enqueueAction(gridAction);
        
    }
}); // eslint-disable-line