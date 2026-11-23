({
    doInit: function(cmp) {
        const quotelines = cmp.get('v.quoteLines');
        cmp.set('v.noOfQuotelines', (quotelines.length-1));
        for(let i=0; i<quotelines.length; i++){
            if(quotelines[i].Id === cmp.get('v.recordId')){
                cmp.set('v.navigatorCount', i);
                break;
            }
        }
    },
    
    closeModel: function(component, event, helper) { 
        component.set('v.isOpen', false);
        $A.get('e.force:refreshView').fire();
    },
    
    inputValueChange: function(component, event, helper) {
        let singleSystemPrice = parseInt(component.find('singleSystemPrice').get('v.value'));
        let noOfSystems = parseInt(component.find('noOfSystem').get('v.value'));
        let noOfCPUsPerSystem = parseInt(component.find('noOfCpuPerSystem').get('v.value'));
        let customerStdUnitPrice = parseInt(component.find('customerStdUnitPrice').get('v.value'));
        let requestedDiscountUnitPrice = parseInt(component.find('reqDiscountUnitPrice').get('v.value'));
        let additionalDiscount = parseInt(component.find('additionalDiscount').get('v.value'));
        
        let totalBidWithoutDiscount = singleSystemPrice * noOfSystems;
        let quantity = noOfCPUsPerSystem * noOfSystems;
        let totalIntelDiscount = (customerStdUnitPrice - requestedDiscountUnitPrice) * quantity;
        let netIntelBidPrice = totalBidWithoutDiscount - totalIntelDiscount - additionalDiscount;
        let intelDiscountPercentage = ((customerStdUnitPrice - requestedDiscountUnitPrice)/customerStdUnitPrice)*100;
        let customerDiscountPercentage = (additionalDiscount/(totalBidWithoutDiscount - (customerStdUnitPrice * quantity)))*100;
        let intelBidDiscountPercentage = ((totalBidWithoutDiscount - netIntelBidPrice) / totalBidWithoutDiscount)*100;
        
        component.find('totalIntelDiscount').set('v.value', totalIntelDiscount);
        component.find('netIntelBidPrice').set('v.value', netIntelBidPrice);
        component.find('intelDiscount').set('v.value', intelDiscountPercentage);
        component.find('totalBidWithoutDiscount').set('v.value', totalBidWithoutDiscount);
        component.find('customerDiscount').set('v.value', customerDiscountPercentage);
        component.find('intelBidDiscount').set('v.value', intelBidDiscountPercentage);
        
        component.set('v.isUpdated', true);
        /*let recordMap = component.get('v.recordFormMap');
        let recordId = component.get('v.recordId');
        recordMap[''+recordId] = component.find('recordEditForm');
        component.set('v.recordFormMap', recordMap);*/
    },
    
    handleSubmit: function(component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        /*let recordMap = component.get('v.recordFormMap');
        for(let key in recordMap){            
            setTimeout(function(){
                recordMap[key].submit();
            }, 500);
        }*/
        component.find('recordEditForm').submit();
        setTimeout(function(){
            //component.set('v.isOpen', false);
            component.set('v.loaded', !component.get('v.loaded'));
            //$A.get('e.force:refreshView').fire();
        }, 1000);
        component.set('v.isUpdated', false);
    },
    
    handlePrevQuoteline: function(component, event, helper) {
        component.set('v.navigationButton','previous');
        let isUpdated = component.get('v.isUpdated');
        if(isUpdated === false){
        	helper.navigate(component, parseInt(component.get('v.navigatorCount'))-1);
        }else{
            component.set('v.showConfirmDialog', true);
        }
    },
    
    handleNextQuoteline: function(component, event, helper) { 
        component.set('v.navigationButton','next');
        let isUpdated = component.get('v.isUpdated');
        if(isUpdated === false){
            helper.navigate(component, parseInt(component.get('v.navigatorCount'))+1);
        }else{
            component.set('v.showConfirmDialog', true);
        }
    },
    
    handleConfirmDialogNo: function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    
    handleConfirmDialogYes: function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
        component.set('v.isUpdated', false);
        if(component.get('v.navigationButton').localeCompare('next') === 0){
            this.handleNextQuoteline(component, event, helper);
        }else if(component.get('v.navigationButton').localeCompare('previous') === 0){
            this.handlePrevQuoteline(component, event, helper);            
        }
    },
})