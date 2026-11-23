({
    doInit: function (component, event, helper) {
        let platformOptions = [];
        let salesGeoOptions = [];
        let segmentOptions = [];
        const CONSUMPTION_PLATFORM = 'Consumption Platform';
        const CONSUMPTION_SALESGEO = 'Consumption Sales Geo';
        const CONSUMPTION_SEGMENT = 'Consumption Segment';

        let todayDateValue;
        helper.userHasRPMPermissionSet(component);
        helper.userHasFIPMPermissionSet(component);
        //get the current Date in GMT Format
        let getCurrentDate = component.get('c.fetchDate'); // NOSONAR
        component.set('v.isValidAdditionalTc', 'false');
        component.set('v.isValidDealDesc', 'false');
        component.set('v.isValidAddComment', 'false');
        component.set('v.isLoad', 'false');
        getCurrentDate.setCallback(this, function (response) {
            let state = response.getState(); // NOSONAR
            if (state === 'SUCCESS') {
                todayDateValue = response.getReturnValue();
                component.set('v.currentDate', todayDateValue);
            }
        });
        $A.enqueueAction(getCurrentDate);
        let getQuoteLineById = component.get('c.getQuoteLine'); // NOSONAR
        getQuoteLineById.setParams({ quoteLineId: component.get('v.recordId') });
        getQuoteLineById.setCallback(this, function (response) {
            let state = response.getState();  // NOSONAR
            if (state === 'SUCCESS') {
                let isRPMUser = component.get('v.isRPM');  // NOSONAR
                let isFIPMUser = component.get('v.isFIPM');
                let isQuoteAccountRestriced;
                let quoteLineObject = response.getReturnValue();  // NOSONAR
                component.set('v.quoteId', quoteLineObject.SBQQ__Quote__c);
                const getConsumptionData = component.get('c.getConsumptionPicklistValues');
                getConsumptionData.setParams({ quoteId: component.get('v.quoteId') });
                getConsumptionData.setCallback(this, function (response) {
                    const state = response.getState();
                    const result = response.getReturnValue();
                    if (state === 'SUCCESS') {
                        if (result.length > 0) {
                            result.forEach(element => {
                                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_PLATFORM) {
                                    platformOptions.push(element.Name);
                                }
                                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_SALESGEO) {
                                    salesGeoOptions.push(element.Name);
                                }
                                if (element.Pricing_Consumption_Type_Nm__c === CONSUMPTION_SEGMENT) {
                                    segmentOptions.push(element.Name);
                                }
                            });
                            component.set('v.platformOptions', platformOptions);
                            component.set('v.salesGeoOptions', salesGeoOptions);
                            component.set('v.segmentOptions', segmentOptions);
                        }
                    }
                });
                $A.enqueueAction(getConsumptionData);              

                if (isRPMUser === false && (isFIPMUser === false && quoteLineObject.Pricing_Program_Type_Nm__c !== $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
                    quoteLineObject.Pricing_End_Date_dt__c = quoteLineObject.Pricing_Approved_End_Date_Dt__c;
                    quoteLineObject.Pricing_New_Quantity_qty__c = quoteLineObject.Pricing_Approved_Unit_Qty__c;
                    quoteLineObject.Pricing_Request_Discount_Unit_Price_qty__c = quoteLineObject.Pricing_ECAP_Price_Amt__c;
                    quoteLineObject.Pricing_Start_Date_dt__c = quoteLineObject.Pricing_Approved_Start_Date_Dt__c;
                }

                //Set isMeetCompMandatory = false for SSD and PMem quote type, since meet comp price is not mandatory for SSD and PMem 
                if (quoteLineObject.Pricing_Program_Type_Nm__c === $A.get('$Label.c.Pricing_Tender_PMem_Quote') || quoteLineObject.Pricing_Program_Type_Nm__c === $A.get('$Label.c.Pricing_Tender_SSD_Quote')) {
                    component.set('v.isMeetCompMandatory', false);
                }

                component.set('v.quoteLine', response.getReturnValue());

                if(quoteLineObject.Pricing_Status_Nm__c == $A.get('$Label.c.Pricing_Tender_QuoteLine_Status_Won')) {
                    const quoteAccountId = quoteLineObject.SBQQ__Quote__r.SBQQ__Account__c;
                    const quoteEndCustomerSalesGeography = quoteLineObject.SBQQ__Quote__r.Pricing_Region_Nm__c;
                    let checkAccount = component.get('c.restrictedAccountMethod');
                    checkAccount.setParams({ recordId: quoteAccountId, pricingRegion: quoteEndCustomerSalesGeography });
                    checkAccount.setCallback(this, function (response) {
                        let state = response.getState();
                        if (state === 'SUCCESS') {
                            isQuoteAccountRestriced = response.getReturnValue();
                            if(isQuoteAccountRestriced == true) {
                                if(quoteLineObject.Pricing_New_Change_Request_cb__c) {
                                    component.set('v.quoteLine.Pricing_Payable_Quantity__c', quoteLineObject.Pricing_Payable_Quantity__c);
                                }
                                else {
                                    component.set('v.quoteLine.Pricing_Payable_Quantity__c', 0);
                                }                            
                            }
                            else if(isQuoteAccountRestriced == false) {
                                component.set('v.payableQuantityDisabled', true);
                                component.set('v.quoteLine.Pricing_Payable_Quantity__c', quoteLineObject.Pricing_Approved_Unit_Qty__c);
                            }                        
                        }
                    });
                    $A.enqueueAction(checkAccount); 
                }
               
                let oldQuoteLine = JSON.parse(JSON.stringify(response.getReturnValue()));  //NOSONAR
                oldQuoteLine.Pricing_Backdate_Reason_Txt__c = oldQuoteLine.Pricing_Backdate_Reason_Txt__c != undefined ? oldQuoteLine.Pricing_Backdate_Reason_Txt__c : '';
                oldQuoteLine.Pricing_Consumption_Platform__c = oldQuoteLine.Pricing_Consumption_Platform__c != undefined ? oldQuoteLine.Pricing_Consumption_Platform__c : '';
                oldQuoteLine.Pricing_Consumption_Sale_Geo__c = oldQuoteLine.Pricing_Consumption_Sale_Geo__c != undefined ? oldQuoteLine.Pricing_Consumption_Sale_Geo__c : '';
                oldQuoteLine.Pricing_Consumption_Country__c = oldQuoteLine.Pricing_Consumption_Country__c != undefined ? oldQuoteLine.Pricing_Consumption_Country__c : '';
                oldQuoteLine.Pricing_Consumption_Region__c = oldQuoteLine.Pricing_Consumption_Region__c != undefined ? oldQuoteLine.Pricing_Consumption_Region__c : '';
                oldQuoteLine.Pricing_Consumption_Segment__c = oldQuoteLine.Pricing_Consumption_Segment__c != undefined ? oldQuoteLine.Pricing_Consumption_Segment__c : '';
                component.set('v.oldQuoteLine', oldQuoteLine);

                if (isRPMUser == true || (isFIPMUser == true && quoteLineObject.Pricing_Program_Type_Nm__c === $A.get('$Label.c.Pricing_Tender_FinancialIncentive_Quote'))) {
                    component.set('v.quoteLineType', quoteLineObject.Pricing_Program_Type_Nm__c);
                    component.set('v.oldProductId', quoteLineObject.Pricing_Product_Nm__c);
                    component.set('v.oldWIPName', quoteLineObject.Pricing_Other_Product_Nm__c);
                    if (quoteLineObject.Pricing_Deal_RFQ_Id__c != undefined) {
                        component.set('v.buttonLabel', 'Update Deal in My Deals');
                    } else { // if Deal Id emty
                        component.set('v.buttonLabel', 'Create and Approve Change Request');
                        if (quoteLineObject.SBQQ__ProductName__c == 'Write In Product') {
                            component.set('v.isWriteInProduct', 'true');
                            $A.util.toggleClass(component.find('productDiv'), 'slds-is-open');
                        }
                    }

                    component.set('v.backDateReasonValue', quoteLineObject.Pricing_Backdate_Reason_Txt__c);
                    let backDateReasonValue = component.get('v.backDateReasonValue');  // NOSONAR
                    component.set('v.quoteLine.Pricing_Backdate_Reason_Txt__c', backDateReasonValue);
                    if (quoteLineObject.Pricing_Approved_Start_Date_Dt__c < todayDateValue) {
                        component.set('v.disableBackDateReason', 'false');
                    } else {
                        component.set('v.disableBackDateReason', 'true');
                        component.set('v.backDateReasonValue', '');
                        // FIX : TWC1972-8059 : BackDate Reason value is getting stored in backend
                        component.set('v.isBakcDateReasonChanged', 'false');
                        component.set('v.quoteLine.Pricing_Backdate_Reason_Txt__c', '');
                    }
                    /*let maxDate = todayDateValue;
                    if (maxDate < quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c) {
                        maxDate = quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c
                    }*/
                    //changed the date logic to compare with approved end date 28/07
                    if (quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c > quoteLineObject.Pricing_Approved_End_Date_Dt__c) {
                        quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c = quoteLineObject.Pricing_Approved_End_Date_Dt__c;
                    } /*else {
                        quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c = maxDate;
                    }*/
                }
                component.set('v.isLoad', 'true');
                if (quoteLineObject.Pricing_Approved_End_Date_Dt__c < todayDateValue) {
                    component.set('v.showPrice', 'false');
                    component.set('v.isPastDeal', 'true');
                }
                if (quoteLineObject.Pricing_Approved_Start_Date_Dt__c <= todayDateValue) {
                    component.set('v.hasApprovedStartDateInPast', 'true');

                }
                if ((quoteLineObject.Pricing_Approved_Start_Date_Dt__c <= todayDateValue && quoteLineObject.Pricing_Approved_End_Date_Dt__c >= todayDateValue) || quoteLineObject.Pricing_Approved_Start_Date_Dt__c > todayDateValue) {
                    component.set('v.isInflightFutureDeal', 'true');
                    if (quoteLineObject.Pricing_Approved_Start_Date_Dt__c <= todayDateValue && (quoteLineObject.Pricing_Approved_End_Date_Dt__c) >= todayDateValue) {
                        component.set('v.isInflightDeal', 'true');
                    }
                }
                if (quoteLineObject.Pricing_Status_Nm__c == $A.get('$Label.c.Pricing_Tender_QuoteLine_Status_Approved')) {
                    component.set('v.isApprovedCR', 'true');
                }
                if (quoteLineObject.Pricing_Status_Nm__c == $A.get('$Label.c.Pricing_Tender_QuoteLine_Status_Won') && quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c == null) {
                    component.set('v.effectivePricingDate', quoteLineObject.Pricing_Approved_Start_Date_Dt__c);
                } else {
                    component.set('v.effectivePricingDate', quoteLineObject.Pricing_Revised_Pricing_Start_Date_dt__c);
                }
                let EffectiveDate = component.get('v.effectivePricingDate');  //NOSONAR
                component.set('v.quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c', EffectiveDate);
            }
        });
        $A.enqueueAction(getQuoteLineById);
    },
    handleSave: function (component, event, helper) {
        let softWarning = false;
        if (component.get("v.isFieldEnabled") && (component.get('v.selectedProductId') != undefined && component.get('v.selectedProductId') != null && component.get('v.selectedProductId') != '')) {
            component.set('v.quoteLine.Pricing_Product_Nm__c', component.get('v.selectedProductId'));
            component.set('v.quoteLine.SBQQ__Product__c', component.get('v.selectedProductId'));
            component.set('v.quoteLine.Pricing_Other_Product_Nm__c', '');
        }

        let ecapPrice = component.get("v.quoteLine.Pricing_ECAP_Price_Amt__c") == null || component.get("v.quoteLine.Pricing_ECAP_Price_Amt__c") == undefined || component.get("v.quoteLine.Pricing_ECAP_Price_Amt__c") == '' ? 0 : parseInt(component.get("v.quoteLine.Pricing_ECAP_Price_Amt__c"));
        let meetcompPrice = component.get("v.quoteLine.Pricing_Meet_Comp_Price_Amt__c") == null || component.get("v.quoteLine.Pricing_Meet_Comp_Price_Amt__c") == undefined || component.get("v.quoteLine.Pricing_Meet_Comp_Price_Amt__c") == '' ? 0 : parseInt(component.get("v.quoteLine.Pricing_Meet_Comp_Price_Amt__c"));
        if(component.get("v.quoteLine.Pricing_Program_Type_Nm__c") == $A.get("$Label.c.Pricing_Tender_CCG_Quote") && (ecapPrice < meetcompPrice) && component.get('v.isRPM') && component.get("v.isFieldEnabled") == true){
            component.set("v.continueSoftWarningLabel", 'Continue');
            component.set("v.qliSoftWarningApprovedECAP", true);
            softWarning = true;
        }

        if(component.get("v.quoteLine.Pricing_Program_Type_Nm__c") == $A.get("$Label.c.Pricing_Tender_CCG_Quote") && (ecapPrice < meetcompPrice) && component.get('v.isRPM') && component.get("v.quoteLine.Pricing_Deal_RFQ_Id__c") != undefined){
            component.set("v.continueSoftWarningLabel", 'Continue');
            component.set("v.qliSoftWarningApprovedECAP", true);
            softWarning = true;
        }
        
        if(softWarning){
            return;
        }
        
        helper.cloneQuoteLine(component);
    },
    // Added by Suraj
    handleContinueSoftWarning: function (component, event, helper){
        component.set("v.qliSoftWarningApprovedECAP", false);
        component.set("v.qliSoftWarning", false);
        if (component.get("v.isFieldEnabled") && (component.get('v.selectedProductId') != undefined && component.get('v.selectedProductId') != null && component.get('v.selectedProductId') != '')) {
            component.set('v.quoteLine.Pricing_Product_Nm__c', component.get('v.selectedProductId'));
            component.set('v.quoteLine.SBQQ__Product__c', component.get('v.selectedProductId'));
            component.set('v.quoteLine.Pricing_Other_Product_Nm__c', '');
        } 
        helper.cloneQuoteLine(component);
    },
    // Added by Suraj
    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.qliSoftWarning", false);
        component.set("v.qliSoftWarningApprovedECAP", false);
    },
    handleCancel: function (component, event, helper) {
        component.find('requestChangeOverlay').notifyClose();
        // call disconnected callback 
    },
    onAprovedQuantityChange: function (component, event, helper) {
        //let backDateValidation = event.getSource();
        if(component.get('v.payableQuantityDisabled'))
        {
            let approvedQuantityValue = event.getSource().get('v.value');
            component.set('v.quoteLine.Pricing_Payable_Quantity__c', approvedQuantityValue);
        }
    },
    onBackDateReasonChange: function (component, event, helper) {
        //let backDateValidation = event.getSource();
        component.set('v.isBakcDateReasonChanged', 'true');
        let backDateReasonValue = event.getSource().get('v.value');  //NOSONAR
        //component.set('v.backDateReasonSelectedValue',backDateReasonValue); 
        component.set('v.quoteLine.Pricing_Backdate_Reason_Txt__c', backDateReasonValue);
    },
    onApprovedStartChange: function (component, event, helper) {
        component.set('v.approvedStartDateChange', 'true');
        let quoteLine = component.get('v.quoteLine');  // NOSONAR
        let today = component.get('v.currentDate'); // NOSONAR
        if (quoteLine.Pricing_Approved_Start_Date_Dt__c < today) {
            component.set('v.disableBackDateReason', 'false');
        } else {
            component.set('v.disableBackDateReason', 'true');
            component.set('v.backDateReasonValue', '');
            // FIX : TWC1972-8059 : BackDate Reason value is getting stored in backend
            component.set('v.isBakcDateReasonChanged', 'false');
            component.set('v.quoteLine.Pricing_Backdate_Reason_Txt__c', '');
        }
    },
    onAdditionalCommentsChange: function (component, event, helper) {
        const fieldLabel = 'addCmp';
        helper.validateForNonLatinChars(component, event, helper, fieldLabel);
    },
    onAdditionalTcChange: function (component, event, helper) {
        const fieldLabel = 'addTCs';
        helper.validateForNonLatinChars(component, event, helper, fieldLabel);
    },
    onDealDescChange: function (component, event, helper) {
        const fieldLabel = 'dealDes';
        helper.validateForNonLatinChars(component, event, helper, fieldLabel);
    },
    onEffectiveDateChange: function (component, event, helper) {
        let EffectiveDate = event.getSource().get('v.value');  //NOSONAR
        component.set('v.quoteLine.Pricing_Revised_Pricing_Start_Date_dt__c', EffectiveDate);
    },
    handleConsumptionValueChange: function (component, event) {
        component.set('v.quoteLine.Pricing_Consumption_Platform__c', event.getParams().platformValue === 'undefined'
            ? '' : event.getParams().platformValue);
        component.set('v.quoteLine.Pricing_Consumption_Sale_Geo__c', event.getParams().salesGeoValue === 'undefined'
            ? '' : event.getParams().salesGeoValue);
        component.set('v.quoteLine.Pricing_Consumption_Country__c', event.getParams().countryValue === 'undefined'
            ? '' : event.getParams().countryValue);
        component.set('v.quoteLine.Pricing_Consumption_Region__c', event.getParams().regionValue === 'undefined'
            ? '' : event.getParams().regionValue);
        component.set('v.quoteLine.Pricing_Consumption_Segment__c', event.getParams().regionValue === 'undefined'
            ? '' : event.getParams().segmentValue);
    },
    onChangeWIPBox: function (component, event) {
        let isChecked = event.getSource().get("v.checked");
        component.set("v.isFieldEnabled", isChecked);
        if (isChecked) {
            component.set('v.buttonLabel', 'Create Deal');
        } else {
            var qlObject = component.get('v.quoteLine');
            if (qlObject.Pricing_Deal_RFQ_Id__c != undefined) {
                component.set('v.buttonLabel', 'Update Deal in My Deals');
            } else {
                component.set('v.buttonLabel', 'Create and Approve Change Request');
            }
            component.set('v.selectedProduct', '');
            component.set('v.searchKey', '');
            component.set('v.quoteLine.Pricing_Product_Nm__c', component.get('v.oldProductId'));
            component.set('v.quoteLine.SBQQ__Product__c', component.get('v.oldProductId'));
            component.set('v.quoteLine.Pricing_Other_Product_Nm__c', component.get('v.oldWIPName'));
        }

    },
    // When a keyword is entered in search box
    searchProducts: function (component, event, helper) {
        if (!$A.util.isEmpty(component.get('v.searchKey'))) {
            helper.searchProductsHelper(component, event, helper, '');
        } else {
            $A.util.removeClass(component.find('productDiv'), 'slds-is-open');
        }
    },
    // When an item is selected
    selectedProd: function (component, event, helper) {
        if (!$A.util.isEmpty(event.currentTarget.id)) {
            let productList = component.get('v.productList');
            let selectedProduct = '';
            let index = productList.findIndex(x => x.Id === event.currentTarget.id)
            if (index != -1) {
                selectedProduct = productList[index];
            }
            component.set('v.selectedProduct', selectedProduct);
            component.set('v.selectedProductId', selectedProduct.Id);
            $A.util.removeClass(component.find('productDiv'), 'slds-is-open');
        }
    },
    showProducts: function (component, event, helper) {
        if (!$A.util.isEmpty(component.get('v.productList')) && !$A.util.isEmpty(component.get('v.searchKey'))) {
            $A.util.addClass(component.find('productDiv'), 'slds-is-open');
        }
    },
    // To remove the selected item.
    removeItem: function (component, event, helper) {
        component.set('v.selectedProduct', '');
        component.set('v.selectedProductId', '');
        component.set('v.searchKey', '');
        setTimeout(function () {
            component.find('inputProduct').focus();
        }, 250);
    },
    // To close the dropdown if clicked outside the dropdown.
    onBlurEvent: function (component, event, helper) {
        $A.util.removeClass(component.find('productDiv'), 'slds-is-open');
    }
});