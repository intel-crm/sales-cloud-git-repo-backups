({
    doInit: function(component, event, helper){
       
        
      
    /*    if(component.get('v.isCategoryPage')){
            component.set('v.recordId', component.get('v.searchParams.cat'));
            component.set('v.objectApiName', 'PMP_Category__c');
            // component.set('v.isSeoReady', true);
            console.log('Inside cat : ', component.get('v.searchParams.cat'));
        }else if(component.get('v.isSpecialtyPage')){
            component.set('v.recordId', component.get('v.searchParams.specialty'));
            component.set('v.objectApiName', 'PMP_Partner_Specialty__c');
            // component.set('v.isSeoReady', true);
            console.log('Inside spec : ', component.get('v.searchParams.specialty'));
        }else if(component.get('v.isPartnerPage')){
            component.set('v.recordId', component.get('v.searchParams.PartnerProgram'));
            component.set('v.objectApiName', 'PMP_Partner_Program__c');
            // component.set('v.isSeoReady', true);
        }*/
       
    
    },
    
	handleLinkClick : function(component, event, helper) {
        if (component.get('v.linkIsVideo')) {
            event.preventDefault();
            event.stopPropagation();
            component.set('v.showVideo', true);
        } else if (component.get('v.descriptionLinkTarget') == '_blank') {
            var url = component.get('v.descriptionLink');
            // some error in _blank 
            window.open(url, '_blank');
            event.preventDefault();
            event.stopPropagation();
        } 
    },
})