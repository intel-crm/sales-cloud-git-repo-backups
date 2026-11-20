({
    getPerformanceMetrics: function (component, recordId) {
        const action = component.get('c.getPerformanceMetrics');//get data from controller
        action.setParams({
            recordId: recordId,
        });
        action.setCallback(this, function (a) {
            component.set('v.records', a.getReturnValue());//set data in the page variable
            if (a.getReturnValue().length > 0) {
                component.set('v.saveButtonShow', true);
            }
            else {
                component.set('v.saveButtonShow', false);
            }
            component.set('v.isDisabled', false);
        });
        $A.enqueueAction(action);
    },
    validateRequired: function (component, event) {

        // hints to ensure labels are preloaded
        // $Label.c.Pricing_Tender_PerformanceMetricsUsed_Error
        // $Label.c.Pricing_Tender_PerformanceMetrics_Other_Error
        // $Label.c.Pricing_Tender_PerformanceMetrics_SKU_Error
        // $Label.c.Pricing_Tender_PerformanceMetrics_INTELSKU_Error
        // $Label.c.Pricing_Tender_PerformanceMetrics_COMPSKU_Error
        // $Label.c.Pricing_Tender_PerformanceMetrics_Weighting_Error

        let isValid = true;
        let errorMessage = '';
        const existingRecords = component.get('v.records');
        for (let indexVar = 0; indexVar < existingRecords.length; indexVar++) {
            if (existingRecords[indexVar].Pricing_Performance_Metric_Nm__c === '') {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetricsUsed_Error') + ' ' + (indexVar + 1) + '.' + ' \n';
            }
            if (existingRecords[indexVar].Pricing_Performance_Metric_Nm__c === 'Other' &&
                (existingRecords[indexVar].Pricing_Other_Nm__c === '' ||
                    existingRecords[indexVar].Pricing_Other_Nm__c === undefined)) {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetrics_Other_Error') + ' \n';
            }
            if (existingRecords[indexVar].Pricing_Weighting_Pct__c !== '' &&
                (existingRecords[indexVar].Pricing_Weighting_Pct__c < 1 ||
                    existingRecords[indexVar].Pricing_Weighting_Pct__c > 100)) {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetrics_Weighting_Error') + ' ' + (indexVar + 1) + '.' + ' \n';
            }
            if ((existingRecords[indexVar].Pricing_Intel_SKU_Performance_Nbr__c === '' ||
                existingRecords[indexVar].Pricing_Intel_SKU_Performance_Nbr__c === undefined) ||
                (existingRecords[indexVar].Pricing_Comp_SKU_Performance_Nbr__c === '' ||
                    existingRecords[indexVar].Pricing_Comp_SKU_Performance_Nbr__c === undefined)) {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetrics_SKU_Error') + '.' + ' \n';
            }
            if (existingRecords[indexVar].Pricing_Intel_SKU_Performance_Nbr__c < 1 &&
                existingRecords[indexVar].Pricing_Intel_SKU_Performance_Nbr__c !== '') {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetrics_INTELSKU_Error') + ' ' + (indexVar + 1) + '.' + ' \n';
            }
            if (existingRecords[indexVar].Pricing_Comp_SKU_Performance_Nbr__c < 1 &&
                existingRecords[indexVar].Pricing_Comp_SKU_Performance_Nbr__c !== '') {
                isValid = false;
                errorMessage += $A.get('$Label.c.Pricing_Tender_PerformanceMetrics_COMPSKU_Error') + ' ' + (indexVar + 1) + '.' + ' \n';
            }
            if (existingRecords[indexVar].Pricing_Performance_Metric_Nm__c === 'Other' &&
                existingRecords[indexVar].Pricing_Other_Nm__c !== '' && existingRecords[indexVar].Pricing_Other_Nm__c !== null && existingRecords[indexVar].Pricing_Other_Nm__c !== undefined) {
                const commentRegex = $A.get('$Label.c.Pricing_Latin_Characters_Regular_Expr_Label');
                let value = existingRecords[indexVar].Pricing_Other_Nm__c;  // NOSONAR
                if (!value.match(commentRegex)) {
                    isValid = false;
                    errorMessage += $A.get('$Label.c.Pricing_Non_Latin_Char_Validation_Error') + ' \n';
                }
            }
        }
        if (!isValid) {
            component.set('v.isDisabled', false);
            const toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                title: 'Error',
                message: errorMessage,
                duration: ' 10000',
                key: 'info_alt',
                type: 'error',
                mode: 'sticky',
            });
            toastEvent.fire();
        }
        return isValid;
    },
    deletePerformanceMetrics: function (component, Id) {
        const action = component.get('c.deletePerformanceMetrics');
        action.setParams({
            recordId: Id,
        });
        $A.enqueueAction(action);
    },
});