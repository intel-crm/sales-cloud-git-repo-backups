({
    cloneQuoteLine: function (component, event) {
        // Validate for required field
        // hints to ensure labels are preloaded
        // $Label.c.Pricing_Tender_CR_No_Changes_Error
        // $Label.c.Pricing_Tender_CR_No_Changes_Error
        // $Label.c.Pricing_Tender_RPMCR_No_Changes_Error
        // $Label.c.Pricing_Tender_CR_negativeApprovedQuatityvalueError
        // $Label.c.Pricing_Tender_CR_negativeApprovedPricevalueError
        // $Label.c.Pricing_Tender_CR_billingDateError
        // $Label.c.Pricing_Tender_CR_billingApprovedDateError
        // $Label.c.Pricing_Tender_CR_billingApprovedStrDateError
        // $Label.c.Pricing_Tender_CR_backDateReasonError
        // $Label.c.Pricing_Tender_CR_approvedEndDtBeforeApprovedStartDtError
        // $Label.c.Pricing_Tender_CR_approveEndDtInflightFutureError
        // $Label.c.Pricing_Tender_CR_effPricingStartDtOnChangeError
        // $Label.c.Pricing_Tender_CR_PricingApproveEndDtPastCheckError
        // $Label.c.Pricing_Tender_CR_negativeMeetCompPricevalueError
        // $Label.c.Pricing_Tender_CR_MeetCompPriceandEffectiveStartDatevalueError
        // $Label.c.Pricing_Tender_CR_Past_Date_Error
        // $Label.c.Pricing_Tender_CR_priceStrDateError
        // $Label.c.Pricing_Tender_CR_negativevalueError
        // $Label.c.Pricing_Tender_CR_negativeQtrvalueError

        component.find('mySpinner').set('v.class', 'slds-show');
        component.set('v.isSpinner', true);
        let allValid;
        const isRPMUser = component.get('v.isRPM');
        const isFIPMUser = component.get('v.isFIPM');
        const pastDeal = component.get('v.isPastDeal');
        const todayDateValue = component.get('v.currentDate');
        const isInflightFutureDeal = component.get('v.isInflightFutureDeal');
        const isApprovedStartDatePast = component.get('v.hasApprovedStartDateInPast');
        const quoteLine = component.get('v.quoteLine');
        if (isRPMUser === false && (isFIPMUser === false && quoteLine.Pricing_Program_Type_Nm__c !== $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
            allValid = component
                .find('reqChangeFieldOEM')
                .reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && !inputCmp.get('v.validity').valueMissing;
                }, true);
        }
        else {
            allValid = component
                .find('reqChangeField')
                .reduce(function (validSoFar, inputCmp) {
                    inputCmp.showHelpMessageIfInvalid();
                    return validSoFar && !inputCmp.get('v.validity').valueMissing;
                }, true);
        }

        if (!allValid) {
            component.find('mySpinner').set('v.class', 'slds-hide');
            component.set('v.isSpinner', false);
            return;
        }

        //  Clear our errors during Submission        
        const oldQuoteLine = component.get('v.oldQuoteLine');
        let addComment = component.get('v.isValidAddComment'); //NOSONAR
        let dealDesc = component.get('v.isValidDealDesc'); //NOSONAR
        let additionalTs = component.get('v.isValidAdditionalTc'); //NOSONAR
        let isApprovedStartDateChange = component.get('v.approvedStartDateChange'); //NOSONAR
        component.set('v.errors', []);
        let errorList = []; //NOSONAR

        //Validate the non Latin characters
        if ((addComment === 'true') || (dealDesc === 'true') || (additionalTs === 'true')) {
            allValid = false;
            component.find('mySpinner').set('v.class', 'slds-hide');
            component.set('v.isSpinner', false);
        }
        else {
            // Check if user change the date or quantity if there no change no need of request..
            if (quoteLine.Pricing_End_Date_dt__c === quoteLine.Pricing_Approved_End_Date_Dt__c &&
                quoteLine.Pricing_New_Quantity_qty__c == quoteLine.Pricing_Approved_Unit_Qty__c &&
                quoteLine.Pricing_Request_Discount_Unit_Price_qty__c == quoteLine.Pricing_ECAP_Price_Amt__c &&
                quoteLine.Pricing_Start_Date_dt__c === quoteLine.Pricing_Approved_Start_Date_Dt__c &&

                quoteLine.Pricing_Consumption_Platform__c === oldQuoteLine.Pricing_Consumption_Platform__c &&
                quoteLine.Pricing_Consumption_Sale_Geo__c === oldQuoteLine.Pricing_Consumption_Sale_Geo__c &&
                quoteLine.Pricing_Consumption_Region__c === oldQuoteLine.Pricing_Consumption_Region__c &&
                quoteLine.Pricing_Consumption_Country__c === oldQuoteLine.Pricing_Consumption_Country__c &&
                quoteLine.Pricing_Consumption_Segment__c === oldQuoteLine.Pricing_Consumption_Segment__c &&

                isRPMUser === false && (isFIPMUser === false && quoteLine.Pricing_Program_Type_Nm__c !== $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
                const noChangeError = $A.get('$Label.c.Pricing_Tender_CR_No_Changes_Error');
                errorList.push(noChangeError);
            }

            quoteLine.Pricing_Backdate_Reason_Txt__c = quoteLine.Pricing_Backdate_Reason_Txt__c != undefined ? quoteLine.Pricing_Backdate_Reason_Txt__c : '';
                
            // Check if user change the date or quantity if there no change no need of request..
            if (quoteLine.Pricing_Approved_Start_Date_Dt__c === oldQuoteLine.Pricing_Approved_Start_Date_Dt__c &&
                quoteLine.Pricing_Approved_End_Date_Dt__c === oldQuoteLine.Pricing_Approved_End_Date_Dt__c &&
                quoteLine.Pricing_ECAP_Price_Amt__c == oldQuoteLine.Pricing_ECAP_Price_Amt__c &&
                quoteLine.Pricing_Approved_Unit_Qty__c == oldQuoteLine.Pricing_Approved_Unit_Qty__c &&
                quoteLine.Pricing_Payable_Quantity__c == oldQuoteLine.Pricing_Payable_Quantity__c &&
                quoteLine.Pricing_Billing_Start_Date_Dt__c === oldQuoteLine.Pricing_Billing_Start_Date_Dt__c &&
                quoteLine.Pricing_Billing_End_Date_Dt__c === oldQuoteLine.Pricing_Billing_End_Date_Dt__c &&
                quoteLine.Pricing_Backdate_Reason_Txt__c === oldQuoteLine.Pricing_Backdate_Reason_Txt__c &&
                quoteLine.Pricing_Additional_T_C_s_Txt__c === oldQuoteLine.Pricing_Additional_T_C_s_Txt__c &&
                quoteLine.Pricing_Deal_Description__c === oldQuoteLine.Pricing_Deal_Description__c &&

                quoteLine.Pricing_Consumption_Platform__c === oldQuoteLine.Pricing_Consumption_Platform__c &&
                quoteLine.Pricing_Consumption_Sale_Geo__c === oldQuoteLine.Pricing_Consumption_Sale_Geo__c &&
                quoteLine.Pricing_Consumption_Region__c === oldQuoteLine.Pricing_Consumption_Region__c &&
                quoteLine.Pricing_Consumption_Country__c === oldQuoteLine.Pricing_Consumption_Country__c &&
                quoteLine.Pricing_Consumption_Segment__c === oldQuoteLine.Pricing_Consumption_Segment__c &&
                quoteLine.Pricing_Product_Nm__c === oldQuoteLine.Pricing_Product_Nm__c &&

                (isRPMUser === true && quoteLine.Pricing_Quote_Program_Nm__c === $A.get('$Label.c.Pricing_Tender_Quote_Program'))) {
                const norpmChangeError = $A.get('$Label.c.Pricing_Tender_RPMCR_No_Changes_Error');
                errorList.push(norpmChangeError);
            }

            if (quoteLine.Pricing_Approved_Start_Date_Dt__c === oldQuoteLine.Pricing_Approved_Start_Date_Dt__c &&
                quoteLine.Pricing_Approved_End_Date_Dt__c === oldQuoteLine.Pricing_Approved_End_Date_Dt__c &&
                quoteLine.Pricing_Approved_Unit_Qty__c == oldQuoteLine.Pricing_Approved_Unit_Qty__c &&
                quoteLine.Pricing_Additional_T_C_s_Txt__c === oldQuoteLine.Pricing_Additional_T_C_s_Txt__c &&
                quoteLine.Pricing_Additional_Comments_Txt__c === oldQuoteLine.Pricing_Additional_Comments_Txt__c &&

                (isFIPMUser === true && quoteLine.Pricing_Program_Type_Nm__c === $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
                const noFIrpmChangeError = $A.get('$Label.c.Pricing_Tender_FIRPMCR_No_Changes_Error');
                errorList.push(noFIrpmChangeError);
            }


            // added by Anusha M for the US836420
            if (isRPMUser === true || (isFIPMUser === true && quoteLine.Pricing_Program_Type_Nm__c === $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
                // check if Approved Quantity must be greater than zero
                if ((parseInt(quoteLine.Pricing_Approved_Unit_Qty__c, 10)) <= 0) {
                    const negativeApprovedQuatityvalueError = $A.get('$Label.c.Pricing_Tender_CR_negativeApprovedQuatityvalueError');
                    errorList.push(negativeApprovedQuatityvalueError);
                }
                //
                if ((Number(quoteLine.Pricing_Payable_Quantity__c) > Number(quoteLine.Pricing_Approved_Unit_Qty__c)) && quoteLine.Pricing_Status_Nm__c == $A.get('$Label.c.Pricing_Tender_QuoteLine_Status_Won')) {
                    errorList.push($A.get('$Label.c.Pricing_Tender_QuoteLine_Payable_Quantity_Error'));
                }
                //
                // check if Approved ECAP Price must be greater than zero
                if ((parseInt(quoteLine.Pricing_ECAP_Price_Amt__c, 10)) <= 0) {
                    const negativeApprovedPricevalueError = $A.get('$Label.c.Pricing_Tender_CR_negativeApprovedPricevalueError');
                    errorList.push(negativeApprovedPricevalueError);
                }
                // check if Billing End Date cannot be earlier than the Billing Start Date.
                if (quoteLine.Pricing_Billing_End_Date_Dt__c < quoteLine.Pricing_Billing_Start_Date_Dt__c) {

                    const billingDateError = $A.get('$Label.c.Pricing_Tender_CR_billingDateError');
                    errorList.push(billingDateError);
                }
                // check if Billing End Date cannot be later than the Approved Pricing End Date.
                if (quoteLine.Pricing_Billing_End_Date_Dt__c > quoteLine.Pricing_Approved_End_Date_Dt__c) {

                    const billingApprovedDateError = $A.get('$Label.c.Pricing_Tender_CR_billingApprovedDateError');
                    errorList.push(billingApprovedDateError);
                }
                // check if Billing Start Date cannot be later than the Approved Pricing Start Date.
                if (quoteLine.Pricing_Billing_Start_Date_Dt__c > quoteLine.Pricing_Approved_Start_Date_Dt__c) {

                    const billingApprovedDateError = $A.get('$Label.c.Pricing_Tender_CR_billingApprovedStrDateError');
                    errorList.push(billingApprovedDateError);
                }
                //check if Back Date Reason Cannot be editable when Approved start Date is in Past

                const backDateReasonSelected = component.get('v.quoteLine.Pricing_Backdate_Reason_Txt__c');
                if (isApprovedStartDateChange === 'true' && quoteLine.Pricing_Program_Type_Nm__c != 'Financial Incentive' && quoteLine.Pricing_Approved_Start_Date_Dt__c < todayDateValue && (backDateReasonSelected === '' || backDateReasonSelected === oldQuoteLine.Pricing_Backdate_Reason_Txt__c)) {
                    const backDateReasonError = $A.get('$Label.c.Pricing_Tender_CR_backDateReasonError');
                    errorList.push(backDateReasonError);
                }
                if (quoteLine.Pricing_Approved_End_Date_Dt__c < quoteLine.Pricing_Approved_Start_Date_Dt__c) {

                    const approved_EndDt_Before_Approved_StartDtError = $A.get('$Label.c.Pricing_Tender_CR_approvedEndDtBeforeApprovedStartDtError');
                    errorList.push(approved_EndDt_Before_Approved_StartDtError);
                }
                // check for Inflight anf Future Deal Approved end date cannot be earlier than approved start Date

                if (isInflightFutureDeal === 'true' &&
                    (quoteLine.Pricing_Approved_End_Date_Dt__c !== null
                        &&/*(isApprovedEndDateChange == true || isApprovedEndDateChange == true) &&*/
                        (quoteLine.Pricing_Approved_End_Date_Dt__c < quoteLine.Pricing_Approved_Start_Date_Dt__c) ||
                        (quoteLine.Pricing_Approved_End_Date_Dt__c < todayDateValue))) {

                    const approveEndDtInflightFutureError = $A.get('$Label.c.Pricing_Tender_CR_approveEndDtInflightFutureError');
                    errorList.push(approveEndDtInflightFutureError);
                }
                //check Effective Pricing Start Date must be between Approved Pricing Start Date and Approved Pricing End Date
                //and cannot be earlier than today and the Effective Pricing Start Date of the reference quote line.
                if ((isInflightFutureDeal === 'true' && oldQuoteLine.Pricing_Status_Nm__c === 'Won') && //CH
                    ((quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < quoteLine.Pricing_Approved_Start_Date_Dt__c)
                 /*|| new Date(quoteLine.Pricing_End_Date_dt__c) <= new Date() */ ||
                        /*quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < todayDateValue ||*/
                        (quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c < oldQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c) ||
                        (quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c > quoteLine.Pricing_Approved_End_Date_Dt__c))/* && pastDeal == false*/) {
                    const effPricingStartDtOnChangeError = $A.get('$Label.c.Pricing_Tender_CR_effPricingStartDtOnChangeError');
                    errorList.push(effPricingStartDtOnChangeError);
                }
                if (pastDeal === 'true' && (oldQuoteLine.Pricing_Approved_End_Date_Dt__c < todayDateValue &&
                    quoteLine.Pricing_Approved_End_Date_Dt__c < oldQuoteLine.Pricing_Approved_End_Date_Dt__c)) {
                    const Pricing_ApproveEndDtPast_CheckError = $A.get('$Label.c.Pricing_Tender_CR_PricingApproveEndDtPastCheckError');
                    errorList.push(Pricing_ApproveEndDtPast_CheckError);
                }
                //check if MeetComp price is greater than zero
                if ((parseInt(quoteLine.Pricing_Meet_Comp_Price_Amt__c, 10)) <= 0) {
                    const negativeMeetCompPricevalueError = $A.get('$Label.c.Pricing_Tender_CR_negativeMeetCompPricevalueError');
                    errorList.push(negativeMeetCompPricevalueError);
                }
                // check if My Deals Meet Comp Price and Effective Pricing Start Date
                // cannot be edited unless one of the following fields is changed from the reference quote lines values.
                if ((quoteLine.Pricing_Meet_Comp_Price_Amt__c !== oldQuoteLine.Pricing_Meet_Comp_Price_Amt__c ||
                    quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c !== oldQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c) &&
                    (quoteLine.Pricing_Approved_End_Date_Dt__c === oldQuoteLine.Pricing_Approved_End_Date_Dt__c
                        && quoteLine.Pricing_Approved_Unit_Qty__c === oldQuoteLine.Pricing_Approved_Unit_Qty__c
                        && quoteLine.Pricing_Payable_Quantity__c === oldQuoteLine.Pricing_Payable_Quantity__c
                        && quoteLine.Pricing_Approved_Start_Date_Dt__c === oldQuoteLine.Pricing_Approved_Start_Date_Dt__c
                        && quoteLine.Pricing_ECAP_Price_Amt__c === oldQuoteLine.Pricing_ECAP_Price_Amt__c)) {

                    const MeetCompPriceandEffectiveStartDatevalueError = $A.get('$Label.c.Pricing_Tender_CR_MeetCompPriceandEffectiveStartDatevalueError');
                    errorList.push(MeetCompPriceandEffectiveStartDatevalueError);
                }

                //Effective Pricing Start Date mandatory check
                if (quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c !== oldQuoteLine.Pricing_Revised_Pricing_Start_Date_dt__c && quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c == null) {
                    const effectiveDateMandatoryError = $A.get('$Label.c.Pricing_QLI_EffectiveDateRequired_ErrorMsg');
                    errorList.push(effectiveDateMandatoryError);
                }

                if (quoteLine.Pricing_Quote_Program_Nm__c == 'Tender' && quoteLine.Pricing_Consumption_Sale_Geo__c !== '' && (quoteLine.Pricing_Consumption_Country__c !== '' || quoteLine.Pricing_Consumption_Region__c !== '')) {
                    const consumptionError = $A.get('$Label.c.Pricing_Consumption_CountrySalesGeo_Error');
                    errorList.push(consumptionError);
                }

                // Add Product check is marked but product is not selected 
                let selectedProdName = component.get("v.selectedProduct");
                if (component.get("v.isFieldEnabled") && (selectedProdName.Name == 'Write In Product' || selectedProdName.Name == '' || quoteLine.Pricing_Product_Nm__c == oldQuoteLine.Pricing_Product_Nm__c)) {
                    const productError = 'Please Select Product';
                    errorList.push(productError);
                }

                //Billing Date Quarter validation
                const action = component.get('c.billingStartDateCheck');
                action.setParams({ quoteLine: quoteLine });
                action.setCallback(this, function (response) {
                    const state = response.getState();
                    if (state === 'SUCCESS') {
                        const hasError = response.getReturnValue();
                        if (hasError) {
                            const billingQuarterErrorCheck = $A.get('$Label.c.Pricing_Tender_QuoteLine_Billing_Quarter_Error');
                            errorList.push(billingQuarterErrorCheck);
                        }
                    }
                    component.set('v.errors', errorList);
                    if (errorList.length > 0) {
                        allValid = false;
                        component.set('v.hide', '');
                        component.find('scrollHelper').focus();
                        component.set('v.hide', 'slds-hide');
                    }
                    if (!allValid) {
                        component.find('mySpinner').set('v.class', 'slds-hide');
                        component.set('v.isSpinner', false);
                        return;
                    }
                    else {
                        //If there are no Client side validations proceed to Create Change Request record
                        this.createChangeRequest(component, event);
                    }
                });

                //$A.enqueueAction(action);
                $A.enqueueAction(action);
            }
            else {
                // Check if Shipment End Date is not Today or before today.
                if (quoteLine.Pricing_End_Date_dt__c <= todayDateValue) {
                    const pastDateError = $A.get('$Label.c.Pricing_Tender_CR_Past_Date_Error');
                    errorList.push(pastDateError);
                }

                if (isApprovedStartDatePast === false && quoteLine.Pricing_Start_Date_dt__c < todayDateValue) {
                    const pastDateError = $A.get('$Label.c.Pricing_Tender_CR_StartDate_Past_Error');
                    errorList.push(pastDateError);
                }
                if (quoteLine.Pricing_Start_Date_dt__c > quoteLine.Pricing_End_Date_dt__c) {
                    const startDatebeforeEndDateError = $A.get('$Label.c.Pricing_Tender_CR_StartDatePrior_Error');
                    errorList.push(startDatebeforeEndDateError);
                }
                // check if Shipment End Date cannot be earlier than the Pricing Start Date.
                if (quoteLine.Pricing_End_Date_dt__c < quoteLine.SBQQ__Quote__r.Pricing_ShipmentStDate_Dt__c) {
                    const priceDateError = $A.get('$Label.c.Pricing_Tender_CR_priceStrDateError');
                    errorList.push(priceDateError);
                }
                if ((parseInt(quoteLine.Pricing_Request_Discount_Unit_Price_qty__c, 10)) <= 0) {
                    const negativeDiscvalueError = $A.get('$Label.c.Pricing_Tender_CR_negativevalueError');
                    errorList.push(negativeDiscvalueError);
                }
                if ((parseInt(quoteLine.Pricing_New_Quantity_qty__c, 10)) <= 0) {
                    const negativevalueError = $A.get('$Label.c.Pricing_Tender_CR_negativeQtrvalueError');
                    errorList.push(negativevalueError);
                }

                if (quoteLine.Pricing_Quote_Program_Nm__c == 'Tender' && quoteLine.Pricing_Consumption_Sale_Geo__c !== '' && (quoteLine.Pricing_Consumption_Country__c !== '' || quoteLine.Pricing_Consumption_Region__c !== '')) {
                    const consumptionError = $A.get('$Label.c.Pricing_Consumption_CountrySalesGeo_Error');
                    errorList.push(consumptionError);
                }

                //Validate all the FSE from Quote Team
                const validateFSEAction = component.get('c.validateQuoteTeamFSE');
                validateFSEAction.setParams({ quoteLine: quoteLine });
                validateFSEAction.setCallback(this, function (response) {
                    const state = response.getState();
                    if (state === 'SUCCESS') {
                        const hasError = response.getReturnValue();
                        if (!hasError) {
                            const validateFSECheck = $A.get('$Label.c.Pricing_Tender_Quote_Sales_Rep_Error_Message');
                            errorList.push(validateFSECheck);
                        }
                    }
                    component.set('v.errors', errorList);
                    if (errorList.length > 0) {
                        allValid = false;
                    }
                    if (!allValid) {
                        component.find('mySpinner').set('v.class', 'slds-hide');
                        component.set('v.isSpinner', false);
                        return;
                    }
                    else {
                        //If there are no Client side validations proceed to Create Change Request record
                        this.createChangeRequest(component, event);
                    }
                });

                $A.enqueueAction(validateFSEAction);

            }
            // consumption param 
            let platformOptions = Array.from(component.get('v.platformOptions'));
            let salesGeoOptions = Array.from(component.get('v.salesGeoOptions'));
            let segmentOptions = Array.from(component.get('v.segmentOptions'));
            let platformOldValues = (oldQuoteLine.Pricing_Consumption_Platform__c != null) && (oldQuoteLine.Pricing_Consumption_Platform__c != undefined) && (oldQuoteLine.Pricing_Consumption_Platform__c != "") ? oldQuoteLine.Pricing_Consumption_Platform__c.split(", ") : [];
            let salesGeoOldValues = (oldQuoteLine.Pricing_Consumption_Sale_Geo__c != null) && (oldQuoteLine.Pricing_Consumption_Sale_Geo__c != undefined) && (oldQuoteLine.Pricing_Consumption_Sale_Geo__c != "") ? oldQuoteLine.Pricing_Consumption_Sale_Geo__c.split(", ") : [];
            let countryOldValues = (oldQuoteLine.Pricing_Consumption_Country__c != null) && (oldQuoteLine.Pricing_Consumption_Country__c != undefined) && (oldQuoteLine.Pricing_Consumption_Country__c != "") ? oldQuoteLine.Pricing_Consumption_Country__c.split(", ") : [];
            let regionOldValues = (oldQuoteLine.Pricing_Consumption_Region__c != null) && (oldQuoteLine.Pricing_Consumption_Region__c != undefined) && (oldQuoteLine.Pricing_Consumption_Region__c != "") ? oldQuoteLine.Pricing_Consumption_Region__c.split(", ") : [];
            let segmentOldValues = (oldQuoteLine.Pricing_Consumption_Segment__c != null) && (oldQuoteLine.Pricing_Consumption_Segment__c != undefined) && (oldQuoteLine.Pricing_Consumption_Segment__c != "") ? oldQuoteLine.Pricing_Consumption_Segment__c.split(", ") : [];
            let errors = ['Can not delete the existing '];

            if (oldQuoteLine.Pricing_Status_Nm__c === 'Won') {
                if (!regionOldValues.every(oldValue => quoteLine.Pricing_Consumption_Region__c.split(', ').includes(oldValue))) {
                    errors.push('Consumption Region');
                }

                if (!segmentOldValues.filter(item => segmentOptions.includes(item)).every(oldValue => quoteLine.Pricing_Consumption_Segment__c.split(', ').includes(oldValue))) {
                    errors.push('Consumption Segment');
                }

                if (!countryOldValues.every(oldValue => quoteLine.Pricing_Consumption_Country__c.split(', ').includes(oldValue))) {
                    errors.push('Consumption Country');
                }

                if (!salesGeoOldValues.filter(item => salesGeoOptions.includes(item)).every(oldValue => quoteLine.Pricing_Consumption_Sale_Geo__c.split(', ').includes(oldValue))) {
                    errors.push('Consumption Sales Geo');
                }

                if (!platformOldValues.filter(item => platformOptions.includes(item)).every(oldValue => quoteLine.Pricing_Consumption_Platform__c.split(', ').includes(oldValue))) {
                    errors.push('Consumption Platform');
                }

                if (errors.length > 1) {
                    errorList.push(errors.join(', '));
                }
            }
        }
    },
    userHasRPMPermissionSet: function (component, event) {
        const action = component.get('c.userHasRPMPermissionSet');
        action.setCallback(this, function (response) {
            const state = response.getState();
            const result = response.getReturnValue();
            if (state === 'SUCCESS' && result !== null) {
                component.set('v.isRPM', true);
                component.set('v.backDateReason', result);
            }
        });
        $A.enqueueAction(action);
    },
    userHasFIPMPermissionSet: function (component, event) {
        const action = component.get('c.userHasFIPMPermissionSet');
        action.setCallback(this, function (response) {
            const state = response.getState();
            const result = response.getReturnValue();
            if (state === 'SUCCESS' && result !== null) {
                component.set('v.isFIPM', true);
                component.set('v.backDateReason', result);
            }
        });
        $A.enqueueAction(action);
    },
    createChangeRequest: function (component, event) {
        // Trigger Clone Action        
        const cloneAction = component.get('c.doClone');
        const quoteLineObject = component.get('v.quoteLine');
        quoteLineObject.Id = component.get('v.recordId');
        let errorList = []; // NOSONAR
        cloneAction.setParams({
            quoteLine: quoteLineObject,
            action: component.get('v.action'),
        });

        cloneAction.setCallback(this, function (response) {
            const state = response.getState();
            if (component.isValid()) {
                if (state === 'SUCCESS') {
                    // Notify parent to close and refresh
                    component.set('v.refreshParentComponent', true);
                    // Show success message
                    const toastEvent = $A.get('e.force:showToast');
                    const result = response.getReturnValue();
                    if (result !== null && result.isSuccess === true) {
                        toastEvent.setParams({
                            title: 'Success',
                            message:
                                result.messageResult +
                                quoteLineObject.Pricing_Quote_Line_Number__c,
                            type: 'success',
                            mode: 'dismissible',
                        });
                    }
                    else if (result !== null) {
                        if (result.messageResult === '') {
                            toastEvent.setParams({
                                title: 'Error',
                                message:
                                    'Error has occured while creating Change Request.',
                                type: 'Error',
                                mode: 'dismissible',
                            });
                        }
                        else {
                            toastEvent.setParams({
                                title: 'Error',
                                message:
                                    result.messageResult,
                                type: 'Error',
                                mode: 'dismissible',
                            });
                        }

                    } else {
                        //todo if result === null
                        component.set('v.isSpinner', false);
                        component.find('mySpinner').set('v.class', 'slds-hide');
                        const changeRequestError = $A.get('$Label.c.Pricing_Change_Request_Quote_Line_Error_Message');
                        errorList.push(changeRequestError);
                        component.set('v.errors', errorList);
                        if (errorList.length > 0) {
                            return;
                        }
                    }
                    toastEvent.fire();
                    component.find('mySpinner').set('v.class', 'slds-hide');
                    component.set('v.isSpinner', false);
                    component.find('requestChangeOverlay').notifyClose();
                } else {
                    component.set('v.isSpinner', false);
                    component.find('mySpinner').set('v.class', 'slds-hide');
                    const changeRequestError = $A.get('$Label.c.Pricing_Change_Request_Quote_Line_Error_Message');
                    errorList.push(changeRequestError);
                    component.set('v.errors', errorList);
                    if (errorList.length > 0) {
                        return;
                    }
                }
            }
        });
        $A.enqueueAction(cloneAction);
    },
    validateForNonLatinChars: function (component, event, helper, fieldLabel) {
        let field = component.find(fieldLabel); // NOSONAR
        let value = field.get('v.value');  // NOSONAR
        const regExp = $A.get('$Label.c.Pricing_Latin_Characters_Regular_Expr_Label');
        if ((!$A.util.isEmpty(value)) && (!value.match(regExp))) {
            if (fieldLabel === 'dealDes') {
                component.set('v.isValidDealDesc', 'true');
            } else if (fieldLabel === 'addTCs') {
                component.set('v.isValidAdditionalTc', 'true');
            } else if (fieldLabel === 'addCmp') {
                component.set('v.isValidAddComment', 'true');
            }
            field.setCustomValidity(
                $A.get("$Label.c.Pricing_Non_Latin_Char_Validation_Error")
            );
        }
        else {
            field.setCustomValidity('');
            if (fieldLabel === 'dealDes') {
                component.set('v.isValidDealDesc', 'false');
            } else if (fieldLabel === 'addTCs') {
                component.set('v.isValidAdditionalTc', 'false');
            } else if (fieldLabel === 'addCmp') {
                component.set('v.isValidAddComment', 'false');
            }
        }
        field.reportValidity();
    },
    searchProductsHelper: function (component, event, helper, selectedProductId) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        let searchKey = component.get('v.searchKey');
        let quoteLineType = component.get('v.quoteLineType');
        component.set('v.message', '');
        component.set('v.productList', []);
        // Calling Apex Method
        const action = component.get('c.searchProductsSOQL');
        action.setParams({
            searchKey: searchKey,
            quoteLineType: quoteLineType,
        });
        action.setCallback(this, function (response) {
            const state = response.getState();
            const result = response.getReturnValue();
            if (state === 'SUCCESS') {
                if (result.length > 0) {
                    // To check if selectedProductId attribute is prepopulated or not
                    if ($A.util.isEmpty(selectedProductId)) {
                        component.set('v.productList', result);
                    } else {
                        component.set('v.selectedProduct', result[0]);
                    }
                } else {
                    component.set('v.message', "No Records Found for '" + searchKey + "'");
                }
            } else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if ($A.util.isEmpty(selectedProductId))
                $A.util.addClass(component.find('productDiv'), 'slds-is-open');
            $A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    }
});