({
    doInit: function (component, event, helper) {
        const picklistValues = component.get('c.getPickListValues');
        picklistValues.setParams({
            objectType: 'Pricing_Performance_Metric__c',
            selectedField: 'Pricing_Performance_Metric_Nm__c',
        });
        picklistValues.setCallback(this, function (response) {
            const pklist = response.getReturnValue();
            component.set('v.picklistValues', pklist);
        });
        $A.enqueueAction(picklistValues);

        const pfAccess = component.get('c.performetricsObjectAccess');
        pfAccess.setCallback(this, function (response) {
            var value = response.getReturnValue();
            component.set('v.hasCreateAccessPf', value.isCreateablePf);
            component.set('v.hasUpdateAccessPf', value.isUpdateablePf);
            component.set('v.hasDeleteAccessPf', value.isDeletablePf);
        });
        $A.enqueueAction(pfAccess);

        const svdAccess = component.get('c.getSVDQuoteLineActiveStatus');
        svdAccess.setCallback(this, function (response) {
            var value = response.getReturnValue();
            component.set('v.isSVDActive', value);
        });
        $A.enqueueAction(svdAccess);

        const action = component.get("c.getQuoteLines");
        const rid = component.get("v.recordId");
        action.setParams({ recordId: rid });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS" && component.isValid()) {
                const quoteLine = response.getReturnValue();
                let quoteLineType;
                if (quoteLine.length > 0) {
                    let qliIdToApprovedEndDateMap = component.get("v.qliIdToApprovedEndDateMap");
                    let qliIdToQliTypeMap = component.get("v.qliIdToQliTypeMap");
                    for (var i = 0; i < quoteLine.length; i++) {
                        quoteLineType = quoteLine[i].Pricing_Program_Type_Nm__c;
                        component.set("v.quoteLineType", quoteLineType);
                        qliIdToQliTypeMap[quoteLine[i].Id] = quoteLine[i].Pricing_Program_Type_Nm__c;
                        qliIdToApprovedEndDateMap[quoteLine[i].Id] = quoteLine[i].Pricing_Approved_End_Date_Dt__c;
                        // Setting Acronym Status 
                        if (quoteLine[i].Pricing_Status_Nm__c != undefined && quoteLine[i].Pricing_Status_Nm__c !== "") {
                            if (quoteLine[i].Pricing_Status_Nm__c == $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview")) {
                                quoteLine[i].acronym = $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_FieldReview");
                            } else if (quoteLine[i].Pricing_Status_Nm__c == $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview")) {
                                quoteLine[i].acronym = $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_PricingReview");
                            } else if (quoteLine[i].Pricing_Status_Nm__c == $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_Cancelled")) {
                                quoteLine[i].acronym = $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_Cancelled");
                            } else {
                                quoteLine[i].acronym = quoteLine[i].Pricing_Status_Nm__c;
                            }
                        }
                    }
                    component.set("v.qliIdToApprovedEndDateMap", qliIdToApprovedEndDateMap);
                    component.set("v.qliIdToQliTypeMap", qliIdToQliTypeMap);
                    component.set("v.quoteLines", quoteLine);

                } else {
                    console.error("Unable to read data from Quote.");
                }
            } else {
                console.error("Error in loading "); // error
            }

            const checkHasCreateAccess = component.get("c.isCreateable");
            checkHasCreateAccess.setCallback(this, function (response) {
                component.set("v.hasCreateAccess", response.getReturnValue());
                const checkIsOEMField = component.get("c.isOEMField");
                checkIsOEMField.setCallback(this, function (response) {
                    component.set("v.isOEMField", response.getReturnValue());
                    component.find("quoteLineSpinner").set("v.class", "slds-hide");
                });
                $A.enqueueAction(checkIsOEMField);
            });
            $A.enqueueAction(checkHasCreateAccess);
            component.set("v.revisionComments", "");

            const isRPMUser = component.get("c.isPricingManager");
            isRPMUser.setCallback(this, function (response) {
                component.set("v.isPricingManager", response.getReturnValue());
            });
            $A.enqueueAction(isRPMUser);

            const hasPricingManagerAccess = component.get("c.hasPricingManagerAccess");
            hasPricingManagerAccess.setCallback(this, function (response) {
                component.set("v.hasPricingManagerAccess", response.getReturnValue());
            });
            $A.enqueueAction(hasPricingManagerAccess);

            const hasFinancialIncentivePricingManagerPS = component.get("c.hasFinancialIncentivePricingManagerPS");
            hasFinancialIncentivePricingManagerPS.setCallback(this, function (response) {
                component.set("v.hasFinancialIncentiveManagerAccess", response.getReturnValue());
            });
            $A.enqueueAction(hasFinancialIncentivePricingManagerPS);

            const hasPartnerUserAccess = component.get("c.isPartnerUser");
            hasPartnerUserAccess.setCallback(this, function (response) {
                component.set("v.hasPartnerUserAccess", response.getReturnValue());
            });
            $A.enqueueAction(hasPartnerUserAccess);

            const isFSEorSDM = component.get("c.isFSEorSDM");
            isFSEorSDM.setCallback(this, function (response) {
                component.set("v.isFSEorSDM", response.getReturnValue());
            });
            $A.enqueueAction(isFSEorSDM);

            const isBulkApproveRejectAction = component.get("c.isBulkApproveRejectAction");
            isBulkApproveRejectAction.setCallback(this, function (response) {
                component.set("v.isBulkApproveRejectAction", response.getReturnValue());
            });
            $A.enqueueAction(isBulkApproveRejectAction);

            const isBulkDealCreations = component.get("c.isBulkDealCreations");
            isBulkDealCreations.setCallback(this, function (response) {
                component.set("v.isBulkDealCreations", response.getReturnValue());
            });
            $A.enqueueAction(isBulkDealCreations);

            const isBulkUpdateDealProcess = component.get("c.isBulkUpdateDealProcess");
            isBulkUpdateDealProcess.setCallback(this, function (response) {
                component.set("v.isBulkUpdateDealProcess", response.getReturnValue());
            });
            $A.enqueueAction(isBulkUpdateDealProcess);

            //hide new quote line to RPM user for Draft Quotes
            const quote = component.get("c.getQuote");
            quote.setParams({ recordId: rid });
            quote.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS" && component.isValid()) {
                    const quoterecord = response.getReturnValue();
                    if (quoterecord[0].SBQQ__Status__c == 'Draft') {
                        component.set("v.isDraftQuote", true);
                    }
                    component.set("v.isHoldQuote", quoterecord[0].Pricing_On_Hold_Cb__c);
                    quoterecord[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_Small_Volume_Quote") ? component.set("v.isSmallVolumeQuote", true) : component.set("v.isSmallVolumeQuote", false);
                    quoterecord[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote") ? component.set("v.isFinancialIncentiveQuote", true) : component.set("v.isFinancialIncentiveQuote", false);
                }
            });
            $A.enqueueAction(quote);
        });
        component.find("quoteLineSpinner").set("v.class", "slds-show");
        $A.enqueueAction(action);
        component.set("v.revisionCheck", false);
        component.set("v.showRevisionFields", false);
        component.set("v.hideRejectionComments", true);
        component.set("v.hideLostComments", true);
        helper.getRejectionReasonsValue(component, event);
        helper.getLostReasonValue(component, event);
    },
    refreshcomp: function (component, event, helper) {
        $A.get("e.force:refreshView").fire();
    },
    quotelineAction: function (component, event, helper) {
        const menuValue = event.detail.menuItem.get("v.value");
        const quoteLineId = event.getSource().get("v.class");
        component.set("v.quoteLineId", quoteLineId);
        component.set("v.approvalAction", menuValue);
        component.set("v.comments", "");
        component.set("v.actionStr", menuValue);
        component.set("v.selectedLostReasonsPickListValue", "");
        component.set("v.selectedRejectionReasonsPickListValue", "");

        let quotelinedata = component.get("v.quoteLines");
        let quoteLineById = quotelinedata.filter(element => element.Id == component.get("v.quoteLineId"));

        if (menuValue == "Clone") {
            // Filter the "Clone" option if it is a Small Volume Quote
            if (component.get("v.isSVDActive") && component.get("v.isSmallVolumeQuote")) {
                helper.showToastMessage(component, event, helper, "error", "Cloning an SVD quoteline is no longer allowed.", "Error", "sticky");
            } else {
                component.set("v.menuItemDisable", true);
                helper.clone(component, event, helper, quoteLineId);
            }
        } else if (menuValue == "Edit") {
            if (component.get("v.isPricingManager") && component.get("v.qliIdToQliTypeMap")[quoteLineId] != $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote")) {
                component.set("v.showRPMRecommendation", true);
                const getProduct = component.get("c.getProductName");
                getProduct.setParams({ quoteLineId: component.get("v.quoteLineId") });
                getProduct.setCallback(this, function (response) {
                    const state = response.getState();
                    if (state === "SUCCESS" && component.isValid()) {
                        component.set("v.productName", response.getReturnValue());
                    }
                });
                $A.enqueueAction(getProduct);
            } else if (component.get("v.qliIdToQliTypeMap")[quoteLineId] === $A.get("$Label.c.Pricing_Tender_SSD_Quote") || component.get("v.qliIdToQliTypeMap")[quoteLineId] === $A.get("$Label.c.Pricing_Tender_PMem_Quote") || component.get("v.qliIdToQliTypeMap")[quoteLineId] === $A.get("$Label.c.Pricing_Tender_NIC_Quote") || component.get("v.qliIdToQliTypeMap")[quoteLineId] === $A.get("$Label.c.Pricing_Tender_CCG_Quote") || component.get("v.qliIdToQliTypeMap")[quoteLineId] === $A.get("$Label.c.Pricing_Tender_DataCenter_GPU")) {
                component.set("v.isSSDQuoteLineEdit", true);
            } else {
                helper.editRecord(component, event, helper, quoteLineId)
            }
        } else if (menuValue == "Delete") {
            helper.deleteRecord(component, event, helper, quoteLineId);
        } else if (menuValue == $A.get("$Label.c.Pricing_Send_Request_MD_Button_Label")) {
            if(component.get("v.hasPricingManagerAccess") && (quoteLineById[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CCG_Quote")) && (((quoteLineById[0].hasOwnProperty('Pricing_ECAP_Price_Amt__c')) && (quoteLineById[0].Pricing_ECAP_Price_Amt__c)) < ((quoteLineById[0].hasOwnProperty('Pricing_Meet_Comp_Price_Amt__c')) && (quoteLineById[0].Pricing_Meet_Comp_Price_Amt__c)))){
                component.set("v.continueSoftWarningLabel", 'Continue');
                component.set("v.qliSoftWarningApprovedECAP", true);
                component.set('v.quoteLineId', quoteLineId);
            }
            if (component.get("v.hasPricingManagerAccess") && (quoteLineById[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CCG_Quote")) && (quoteLineById[0].Pricing_SIPP_Cb__c == false)  && (quoteLineById[0].hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (quoteLineById[0].Pricing_Market_Segment_values_Nm__c == "Corp") && (quoteLineById[0].Pricing_Change_Request_cb__c == false) && (quoteLineById[0].Pricing_Form_Factor_Nm__c == "Notebook")) {
                component.set("v.continueSoftWarningLabel", 'Continue');
                component.set("v.qliSoftWarning", true);
                component.set('v.quoteLineId', quoteLineId);
            }
            if (component.get("v.qliSoftWarning") == false && component.get("v.qliSoftWarningApprovedECAP") == false) {
                helper.sendRequest(component, event, helper, quoteLineId, "Create");
            }

        } else if (menuValue == $A.get("$Label.c.Pricing_Update_Deal_MD_button_label")) {
            if (component.get("v.hasPricingManagerAccess") && (quoteLineById[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CCG_Quote")) && (((quoteLineById[0].hasOwnProperty('Pricing_ECAP_Price_Amt__c')) && (quoteLineById[0].Pricing_ECAP_Price_Amt__c)) < ((quoteLineById[0].hasOwnProperty('Pricing_Meet_Comp_Price_Amt__c')) && (quoteLineById[0].Pricing_Meet_Comp_Price_Amt__c)))) {
                component.set("v.continueSoftWarningLabel", 'Continue');
                component.set("v.qliSoftWarningApprovedECAP", true);
                component.set('v.quoteLineId', quoteLineId);
            }
            if ((quoteLineById[0].Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CCG_Quote")) && (quoteLineById[0].Pricing_SIPP_Cb__c == false)  && (quoteLineById[0].hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (quoteLineById[0].Pricing_Market_Segment_values_Nm__c == "Corp") && (quoteLineById[0].Pricing_Change_Request_cb__c == false) && (quoteLineById[0].Pricing_Form_Factor_Nm__c == "Notebook")) {
                component.set("v.continueSoftWarningLabel", 'Continue');
                component.set("v.qliSoftWarning", true);
                component.set('v.quoteLineId', quoteLineId);
            }
            if (component.get("v.qliSoftWarning") == false && component.get("v.qliSoftWarningApprovedECAP") == false) {
                helper.sendRequest(component, event, helper, quoteLineId, "Update");
            }

        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_Cancel_Action")) {
            component.set("v.actionStr", menuValue);
            helper.requestChange(component, event, helper, quoteLineId);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change")) {
            component.set("v.actionStr", menuValue);
            helper.requestChange(component, event, helper, quoteLineId);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Submit_For_Approval")) {
            helper.handleSubmitForApproval(component, event, helper);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM")) {
            component.set("v.revisionCheck", true);
            component.set("v.revisionComments", "");
            component.set("v.isModalOpen", true);
            component.set("v.showRevisionFields", true);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField")) {
            component.set("v.revisionCheck", true);
            component.set("v.revisionComments", "");
            component.set("v.isModalOpen", true);
            component.set("v.showRevisionFields", true);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Rollback")) {
            helper.handleRollback(component, event, helper);
        } else if (menuValue === "Approve" || menuValue === "Reject") {

            if (menuValue === "Reject") {
                if (component.get("v.quoteLines[0].Pricing_Quote_Program_Nm__c") == $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote")) {
                    component.set("v.selectedRejectionReasonsPickListValue", "Duplicate Request");
                }
                else {
                    component.set("v.selectedRejectionReasonsPickListValue", "Use Standard MCP/Framework Pricing");
                }
            }
            const getQuoteLineById = component.get("c.getQuoteLine");
            component.set("v.errors", "");
            component.set("v.isDisabled", false);
            getQuoteLineById.setParams({ quoteLineId: quoteLineId });
            getQuoteLineById.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS" && component.isValid()) {
                    component.set("v.quoteLine", response.getReturnValue());
                    const quoteLineRecord = component.get("v.quoteLine");
                    component.set("v.LineId", quoteLineId);
                    if (quoteLineRecord.Pricing_Program_Type_Nm__c === $A.get("$Label.c.Pricing_Tender_CCG_Quote") || quoteLineRecord.Pricing_Program_Type_Nm__c === $A.get("$Label.c.Pricing_Tender_Standard_QuoteLine")) {
                        component.set("v.isSdmFastTrack", true);
                    } if ((menuValue == "Approve") && component.get("v.isFSEorSDM") && (quoteLineRecord.Pricing_SIPP_Cb__c == false) && (quoteLineRecord.Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CCG_Quote")) && (quoteLineById[0].hasOwnProperty('Pricing_Market_Segment_values_Nm__c')) && (quoteLineRecord.Pricing_Market_Segment_values_Nm__c == "Corp") && (quoteLineById[0].Pricing_Change_Request_cb__c == false) && (quoteLineById[0].Pricing_Form_Factor_Nm__c == "Notebook")) {
                        component.set("v.continueSoftWarningLabel", 'Continue');//Continue and Approve
                        component.set("v.qliSoftWarning", true);
                    } else {
                        component.set("v.isModalOpen", true);
                    }

                } else {
                    console.error("Not able to get QuoteLine data");
                }
            });
            $A.enqueueAction(getQuoteLineById);
            //added to open the Pop-up for WON/Lost action
        } else if (menuValue === "Won" || menuValue === "Lost") {
            //component.set("v.isModalOpen", true);
            component.set("v.actionStr", menuValue);
            helper.requestChange(component, event, helper, quoteLineId);
        } else if (menuValue === $A.get("$Label.c.Pricing_GetAI_Button_Label")) {
            const getQuoteLineById = component.get("c.getQuoteLine");
            getQuoteLineById.setParams({ quoteLineId: quoteLineId });
            getQuoteLineById.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS" && component.isValid()) {
                    component.set("v.quoteLine", response.getReturnValue());
                    const quoteLn = component.get("v.quoteLine");
                    if (quoteLn.SBQQ__ProductName__c == $A.get("$Label.c.Pricing_Tender_Write_In_Product")) {
                        helper.showToastMessage(component, event, helper, "error", "AI model cannot be run if Write In Product is used.", "Error", "sticky");
                    } else {
                        var navService = component.find("navService");   // NOSONAR
                        var pageReference = {                           // NOSONAR
                            "type": "standard__navItemPage",
                            "attributes": {
                                "apiName": $A.get("$Label.c.Pricing_PriceRecommendation_Page_Link")
                            },
                            "state": {
                                "c__qline": quoteLineId
                            }
                        };
                        navService.navigate(pageReference);
                    }
                } else {
                    console.error("Not able to get QuoteLine data");
                }
            });
            $A.enqueueAction(getQuoteLineById);
        } else if (menuValue === $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_Pricecomp")) {
            var navService = component.find("navService");
            var pageReference = {
                "type": "standard__navItemPage",
                "attributes": {
                    "apiName": 'Price_Comparision',
                },
                "state": {
                    "c__qline": quoteLineId
                }
            };
            navService.navigate(pageReference);
        } else if (menuValue === $A.get("$Label.c.Pricing_Tender_Sync_Status")) {
            const getSyncStatus = component.get("c.handleSyncStatus");
            getSyncStatus.setParams({ quoteLineId: quoteLineId });
            getSyncStatus.setCallback(this, function (response) {
                const state = response.getState();
                if (state === "SUCCESS") {
                    helper.showToastMessage(component, event, helper, "success", "Syncing Status with My Deals", "Success", "dismissible");
                } else {
                    helper.showToastMessage(component, event, helper, "error", "Not able to Sync Status", "Error", "dismissible");
                }
            });
            $A.enqueueAction(getSyncStatus);
        } else if (menuValue === $A.get("$Label.c.Pricing_Edit_Consumption_Parameters")) {
            component.set("v.showConsumptionParametersEdit", true);
        } else if (menuValue == $A.get("$Label.c.Pricing_Tender_QuoteLine_RollBack")) {
            helper.sendRequest(component, event, helper, quoteLineId, "Rollback");
        }
    },
    onMenuOpen: function (component, event) {
        component.set("v.menuItemDisable", false);
        const button = event.getSource();
        button.set("v.isLoading", true);
        const quoteLineId = event.getSource().get("v.class");
        component.set("v.toastLineId", quoteLineId);
        const action = component.get("c.getAvailableUserActions");
        action.setParams({ quoteLineId: quoteLineId });
        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                let values = response.getReturnValue() || []; //handles null or undefined values
                if (values.length > 0) {
                    component.set("v.menuOptions", values);
                    component.set("v.menuItemDisable", false);
                } else {
                    component.set("v.menuOptions", 'No Action Available');
                    component.set("v.menuItemDisable", true);
                }
                button.set("v.isLoading", false);
            } else {
                button.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.revisionRequiredByOEM", false);
        component.set("v.revisionRequiredByFIELD", false);
        component.set("v.isModalOpen", false);
        component.set("v.revisionCheck", false);
        component.set("v.showApprovalErrorScreen", false);
        component.set("v.isSSDQuoteLineEdit", false);
        component.set("v.showRPMRecommendation", false);
        component.set("v.selectedRejectionReasonsPickListValue", "");
        component.set("v.isSdmFastTrack", false);
        component.set("v.showConsumptionParametersEdit", false);
        component.set("v.quoteLineType", component.get("v.quoteLineType"));
        component.set("v.qliSoftWarning", false);
        component.set("v.qliSoftWarningApprovedECAP", false);

    },
    closeSubmitModel: function (component, event, helper) {
        component.set("v.showApprovalErrorScreen", false);
        $A.get("e.force:refreshView").fire();
    },
    submitDetails: function (component, event, helper) {
        if (component.get('v.approvalAction') == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM")) {
            helper.handleRevisionByOEM(component, event, helper);
        } else if (component.get('v.approvalAction') == $A.get("$Label.c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField")) {
            helper.handleRevisionByFIELD(component, event, helper);
        } else if (component.get('v.approvalAction') == $A.get("$Label.c.Pricing_Tender_Cancel_Action")) {
            let quoteLineId = component.get('v.quoteLineId');
            const inputCmp = component.find("inputCmp")
            if ((component.get('v.comments') == "" || component.get('v.comments') == undefined) &&
                component.get('v.quoteLineType') == $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote")) {
                const msg = 'Cancellation Comments cannot be blank for Financial Incentive';
                inputCmp.setCustomValidity(msg);
                inputCmp.reportValidity();
            } else {
                helper.cancelQuoteLine(component, event, helper, quoteLineId);
            }
        }
        else {
            let isValid = true;
            let errorMessage = "";
            let i = 1;

            const inputCmp = component.find("inputCmp");
            const value = inputCmp.get("v.value");
            const currentAction = component.get("v.approvalAction");
            const quoteLn = component.get("v.quoteLine");
            const commentRegex = $A.get('$Label.c.Pricing_Latin_Characters_Regular_Expr_Label');
            if (currentAction == "Approve" && quoteLn.Pricing_Status_Nm__c == $A.get("$Label.c.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview")) {

                if ((quoteLn.Pricing_Program_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_SSD_Quote") && quoteLn.Pricing_Program_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_PMem_Quote") && quoteLn.Pricing_Program_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote")) && quoteLn.Pricing_Meet_Comp_Price_Amt__c == null) {
                    isValid = false;
                    errorMessage += $A.get("$Label.c.Pricing_My_Deals_Meet_Comp_Price_ApprovalError");
                    i = i + 1;
                }

                if (quoteLn.Pricing_Approved_Start_Date_Dt__c == null) {
                    isValid = false;
                    if (errorMessage != null && errorMessage != "") {
                        errorMessage += ", " + $A.get("$Label.c.Pricing_Approved_Pricing_Start_Date_ApprovalError");
                        i = i + 1;
                    } else {
                        errorMessage += $A.get("$Label.c.Pricing_Approved_Pricing_Start_Date_ApprovalError");
                    }
                }
                if (quoteLn.Pricing_Approved_End_Date_Dt__c == null) {
                    isValid = false;
                    if (errorMessage != null && errorMessage != "") {
                        errorMessage += ", " + $A.get("$Label.c.Pricing_Approved_Pricing_End_Date_ApprovalError");
                        i = i + 1;
                    } else {
                        errorMessage += $A.get("$Label.c.Pricing_Approved_Pricing_End_Date_ApprovalError");
                    }
                }
                if (quoteLn.Pricing_Approved_Unit_Qty__c == null) {
                    isValid = false;
                    if (errorMessage != null && errorMessage != "") {
                        errorMessage += ", " + $A.get("$Label.c.Pricing_Approved_Quantity_ApprovalError");
                        i = i + 1;
                    } else {
                        errorMessage += $A.get("$Label.c.Pricing_Approved_Quantity_ApprovalError");
                    }

                }
                if (quoteLn.Pricing_ECAP_Price_Amt__c == null && quoteLn.Pricing_Program_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote")) {
                    isValid = false;
                    if (errorMessage != null && errorMessage != "") {
                        errorMessage += ", " + $A.get("$Label.c.Pricing_Approved_ECAP_Price_ApprovalError");
                        i = i + 1;
                    } else {
                        errorMessage += $A.get("$Label.c.Pricing_Approved_ECAP_Price_ApprovalError");
                    }
                }
                if (i <= 2 && errorMessage != "" && errorMessage != null) {
                    errorMessage += " is " + $A.get("$Label.c.Pricing_Tender_QuoteLine_Approved_Field_Error") + " \n";
                } else if (i > 2) {
                    errorMessage += " are " + $A.get("$Label.c.Pricing_Tender_QuoteLine_Approved_Field_Error") + " \n";
                }

                if (quoteLn.Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_FinancialIncentive_Quote") && quoteLn.Pricing_FI_Net_RPU_Amt__c <= 0) {
                    isValid = false;
                    errorMessage += " \n" + $A.get("$Label.c.Pricing_FI_Net_RPU_Error");
                }

                //To check if Write in Product Workload field is mandatory for Approving QLI for Application as CoSP
                if (quoteLn.Pricing_Server_Deal_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_CoSP_Application_Value") && quoteLn.Pricing_Product_Nm__r.Name == $A.get("$Label.c.Pricing_Tender_Write_In_Product") && quoteLn.Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_Standard_QuoteLine") && quoteLn.Pricing_Workload_Nm__c == null && quoteLn.Pricing_New_Change_Request_cb__c != true) {
                    isValid = false;
                    errorMessage += " \n" + $A.get("$Label.c.Pricing_Mandatory_Workload_Selection");
                }

                //To check if Write in Product Workload field is Not Required for Approving QLI for Application as Non CoSP
                if (quoteLn.Pricing_Server_Deal_Type_Nm__c != $A.get("$Label.c.Pricing_Tender_CoSP_Application_Value") && quoteLn.Pricing_Product_Nm__r.Name == $A.get("$Label.c.Pricing_Tender_Write_In_Product") && quoteLn.Pricing_Program_Type_Nm__c == $A.get("$Label.c.Pricing_Tender_Standard_QuoteLine") && quoteLn.Pricing_Workload_Nm__c != null && quoteLn.Pricing_New_Change_Request_cb__c != true) {
                    isValid = false;
                    errorMessage += " \n" + $A.get("$Label.c.Pricing_Non_Mandatory_Workload_Selection");
                }
            }

            if ((!$A.util.isEmpty(value)) && (!value.match(commentRegex))) {
                isValid = false;
                inputCmp.setCustomValidity($A.get("$Label.c.Pricing_Non_Latin_Char_Validation_Error"));
                inputCmp.reportValidity();
            }
            else if (currentAction == "Reject" && component.get('v.selectedRejectionReasonsPickListValue') == $A.get("$Label.c.Pricing_rejection_reason_other_value") && value === "") {

                const msg = $A.get("$Label.c.Pricing_Tender_Rejection_Error");
                inputCmp.setCustomValidity(msg);
                inputCmp.reportValidity();
            }

            else if (currentAction == "Lost" && component.get('v.selectedLostReasonsPickListValue') == $A.get("$Label.c.Pricing_Lost_reason_other_value") && value === "") {
                inputCmp.setCustomValidity($A.get("$Label.c.Pricing_Tender_Lost_Error"));
                inputCmp.reportValidity();
            }
            else if (currentAction == "Approve" && !isValid) {
                component.set("v.isModalOpen", true);
                component.set("v.errors", errorMessage);
                component.set("v.isDisabled", true);
            }
            else {
                component.set("v.isDisabled", false);
                helper.callRecordApproval(component, event, helper, "Approve_Reject");
            }
        }
    },
    handleToastEvent: function (component, event, helper) {
        const toastMessage = event.getParam("message").toUpperCase();
        let recordName = "";
        if (event.getParams("arguments").messageTemplateData != undefined && event.getParams("arguments").messageTemplateData.length > 0) {
            recordName = event.getParams("arguments").messageTemplateData[0].toUpperCase();
        }
        if ((recordName.includes("QUOTE LINE") && (toastMessage.includes("WAS SAVED") || toastMessage.includes("WAS CREATED")))
            || (toastMessage.includes("ANOTHER USER ALSO MADE CHANGES TO THIS RECORD"))) {
            $A.enqueueAction(component.get("c.doInit"));
            event.stopPropagation();
        }
    },

    closeAndEditQL: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        component.set("v.showRPMRecommendation", true);
        const getProduct = component.get("c.getProductName");
        getProduct.setParams({ quoteLineId: component.get("v.quoteLineId") });
        getProduct.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS" && component.isValid()) {
                component.set("v.productName", response.getReturnValue());
            }
        });
        $A.enqueueAction(getProduct);
    },

    revisionChatterPost: function (component, event, helper) {
        component.set("v.showRevisionFields", !(component.get("v.showRevisionFields")));
    },

    setModalAttribute: function (component, event) {
        component.set("v.isSSDQuoteLineEdit", event.getParam('value'));
        component.set("v.showRPMRecommendation", event.getParam('modalOpenValue'));
    },
    refreshAccordion: function (component, event) {
        component.set("v.isAccordionRefresh", event.getParam('isRefreshAccordion'));
        if (component.get('v.isAccordionRefresh')) {
            $A.enqueueAction(component.get("c.doInit"));
        }
    },
    RPMRefreshAccordion: function (component, event) {
        component.set("v.isAccordionRefreshRPM", event.getParam('isRefreshAccordionRPM'));
        if (component.get('v.isAccordionRefreshRPM')) {
            $A.enqueueAction(component.get("c.doInit"));
        }
    },
    refreshConsumption: function (component, event) {
        component.find("quoteLineSpinner").set("v.class", "slds-show");
        component.set("v.isConsumptionRefresh", event.getParam('refreshConsumptionValue'));
        if (component.get('v.isConsumptionRefresh')) {
            component.set("v.showConsumptionParametersEdit", false);
            $A.enqueueAction(component.get("c.closeModel"));
            $A.get("e.force:refreshView").fire();
            component.set("v.isConsumptionRefresh", false);
        }
        component.find("quoteLineSpinner").set("v.class", "slds-hide");
    },
    //handle Rejection Reasons Value Picklist Selection
    handleRejectionReasonsChange: function (component, event, helper) {
        var RejectionReasons = component.find("RejectionReasonsPickList").get("v.value");
        RejectionReasons == $A.get("$Label.c.Pricing_rejection_reason_other_value") ? component.set("v.hideRejectionComments", false) : component.set("v.hideRejectionComments", true);
    },
    //handle Lost Reasons Value Picklist Selection
    handleLostReasonsChange: function (component, event, helper) {
        var LostReasons = component.find("LostReasonsPickList").get("v.value");
        LostReasons == $A.get("$Label.c.Pricing_Lost_reason_other_value") ? component.set("v.hideLostComments", false) : component.set("v.hideLostComments", true);
    },
    closeAndEditQLIncentive: function (component, event, helper) {
        component.set("v.isModalOpen", false);
        helper.editRecord(component, event, helper, component.get("v.quoteLineId"));
    },
    handleContinueSoftWarning: function (component, event, helper) {
        component.set("v.qliSoftWarning", false);
        component.set("v.qliSoftWarningApprovedECAP", false);
        if (component.get("v.isFSEorSDM")) {
            component.set("v.isModalOpen", true);
        }
        if (component.get("v.hasPricingManagerAccess")) {
            helper.sendRequest(component, event, helper, component.get("v.quoteLineId"), "Create");
        }
    },

});