({
    doInit : function(component,event,helper){
        //alert('controller');
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url', typeAttributes: {label: { fieldName: 'Title' }, target: '_blank'}, wrapText: true},
            {label: 'Status', fieldName: 'Core_MDF_Fund_Request_Status__c', type: 'text'},
            {label: 'Amount', fieldName: 'RequestedAmount', type: 'currency', typeAttributes: { currencyCode: 'USD' }, cellAttributes: { alignment: 'left' }}
        ]);
        helper.doinitHelper(component,event,helper);
    },
    fetch : function(component, event, helper) {
        
    }
})