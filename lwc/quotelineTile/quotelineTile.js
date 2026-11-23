import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAvailableUserActions from '@salesforce/apex/Pricing_QuoteLineController.getAvailableUserActions';
import isPricingManager from '@salesforce/apex/Pricing_QuoteLineController.isPricingManager';
import deleteRecord from '@salesforce/apex/Pricing_QuoteLineController.deleteRecord';
import doClone from '@salesforce/apex/Pricing_QuoteLineCloneController.doClone';
import getProductName from '@salesforce/apex/Pricing_QuoteLineController.getProductName';

import Pricing_Send_Request_MD_Button_Label from '@salesforce/label/c.Pricing_Send_Request_MD_Button_Label';
import Pricing_GetAI_Button_Label from '@salesforce/label/c.Pricing_GetAI_Button_Label';
import Pricing_Tender_Write_In_Product from '@salesforce/label/c.Pricing_Tender_Write_In_Product';
import Pricing_PriceRecommendation_Page_Link from '@salesforce/label/c.Pricing_PriceRecommendation_Page_Link';
import Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField';
import Pricing_Tender_Cancel_Action from '@salesforce/label/c.Pricing_Tender_Cancel_Action';
import Pricing_Update_Deal_MD_button_label from '@salesforce/label/c.Pricing_Update_Deal_MD_button_label';
import Pricing_Tender_QuoteLine_Action_Request_Change from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_Request_Change';
import Pricing_Tender_QuoteLine_Action_Submit_For_Approval from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_Submit_For_Approval';
import Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM';
import Pricing_OverlapDeal_Error_Message from '@salesforce/label/c.Pricing_OverlapDeal_Error_Message';
import Pricing_Tender_CR_Existing_Request_Error from '@salesforce/label/c.Pricing_Tender_CR_Existing_Request_Error';
import Pricing_Tender_QuoteLine_Action_Won from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_Won';
import Pricing_Tender_QuoteLine_Action_Lost from '@salesforce/label/c.Pricing_Tender_QuoteLine_Action_Lost';
import Pricing_Tender_CR_Reference_Status_Change_Message from '@salesforce/label/c.Pricing_Tender_CR_Reference_Status_Change_Message';
import Pricing_Tender_SSD_Quote from '@salesforce/label/c.Pricing_Tender_SSD_Quote';
import Pricing_Tender_PMem_Quote from '@salesforce/label/c.Pricing_Tender_PMem_Quote';
import Pricing_Tender_CCG_Quote from '@salesforce/label/c.Pricing_Tender_CCG_Quote';
import Pricing_Tender_NIC_Quote from '@salesforce/label/c.Pricing_Tender_NIC_Quote';

import Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview';
import Pricing_Tender_QuoteLine_Status_FieldReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_FieldReview';
import Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview';
import Pricing_Tender_QuoteLine_Status_PricingReview from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_PricingReview';
import Pricing_Tender_QuoteLine_Status_Cancelled from '@salesforce/label/c.Pricing_Tender_QuoteLine_Status_Cancelled';

import pricingPubSub from 'c/pricingPubSub';

import { NavigationMixin } from 'lightning/navigation';

const TILE_WRAPPER_SELECTED_CLASS = "tile-wrapper selected";
const TILE_WRAPPER_UNSELECTED_CLASS = "tile-wrapper";
export default class QuotelineTile extends NavigationMixin(LightningElement) {
    @api quoteline;
    @api selectedquotelineId;
    @api metaData;

    @track isLoading = false;
    @track menu = [];
    @track pricingManager;
    //icon
    @track iconName;
    @track alternativeText;
    @track variant;
    @track acronym = '';
    @track errorMessage;
    @track integrationStatus;
    @track inputText;

    @track productName;
    @track isSSDQuoteLineEdit;
    @track isSSDQuoteLine;

    @track showRPMRecommendation;
    @track showApprovalErrorScreen = false;
    @track fieldSet = [];

    // Setting labels ,
    labels = ['Processor Number : ', 'Quantity : ', 'Requested Unit Price : ','Pricing End Date : ', 'Approved Quantity : ', 'Approved ECAP Price : ', 'Approved Pricing End Date : ', 'Deal ID : '];


    get tileClass() {
        return this.selectedquotelineId ? TILE_WRAPPER_SELECTED_CLASS : TILE_WRAPPER_UNSELECTED_CLASS;
    }

    // selectQuoteline() {
    //     this.selectedquotelineId = !this.selectedquotelineId;
    //     console.log('###this.selectedquotelineId: ' + this.quoteline.Id);
    //     const quotelineselect = new CustomEvent("quotelineselect", {
    //         detail: {
    //             quotelineId: this.quoteline.Id
    //         }
    //     });
    //     this.dispatchEvent(quotelineselect);
    // }

    selectQuoteLineId() {
        /*Firing the showReadOnlyQLEvent event to be handled in the quotelineSearchResults.*/
        pricingPubSub.fireLinkEvent('showReadOnlyQLEvent', this.quoteline.Id, false);
    }

    connectedCallback() {

        let quoteLineType = this.quoteline.Pricing_Program_Type_Nm__c;
        var performanceMet = false;
        console.log('quoteline:', JSON.stringify(this.quoteline));

        getAvailableUserActions({ quoteLineId: this.quoteline.Id })
            .then(result => {
                console.log('result' + JSON.stringify(result));
                result.forEach(item => {
                    let i = { label: item, value: item };
                    this.menu.push(i);
                });
                console.log('this.menu:', JSON.stringify(this.menu));
            })
            .catch(error => {
                console.error(error);
            });

        if (quoteLineType === Pricing_Tender_SSD_Quote || quoteLineType === Pricing_Tender_PMem_Quote || quoteLineType === Pricing_Tender_NIC_Quote || quoteLineType === Pricing_Tender_CCG_Quote) {

            this.isSSDQuoteLine = true;
        }


        this.setAcronym();
        var fieldSetVal = [];

        this.metaData.forEach(item => {
            if (item.Quote_Line_Type__c == this.quoteline.Pricing_Program_Type_Nm__c) {
                fieldSetVal = item.Fields__c.split(',');
            }
        });

        
        console.log("WRite In : " + this.quoteline.Pricing_Other_Product_Nm__c)

        // if (this.quoteline.Pricing_Other_Product_Nm__c != null || this.quoteline.Pricing_Other_Product_Nm__c != "" || this.quoteline.Pricing_Other_Product_Nm__c != 'undefined' || this.quoteline.Pricing_Other_Product_Nm__c != undefined) 
        // {
        //     console.log('Inside WRIP');
        //     this.fieldSet.push({ label: this.labels[0], value: this.quoteline['Pricing_Other_Product_Nm__c'] });
        //     for (let i = 1; i < fieldSetVal.length; i++) {
        //         this.fieldSet.push({ label: this.labels[i], value: this.quoteline[fieldSetVal[i]] });
        //     }
        // } else {
        //     for (let i = 0; i < fieldSetVal.length; i++) {
        //         this.fieldSet.push({ label: this.labels[i], value: this.quoteline[fieldSetVal[i]] });
        //     }
        // }

        for (let i = 0; i < fieldSetVal.length; i++) {
            this.fieldSet.push({ label: this.labels[i], value: this.quoteline[fieldSetVal[i]] });
        }

        // if (this.quoteline.hasOwnProperty('Performance_Metrics__r')) {
        //     this.fieldSet.push({ label: 'No. of Performance Metrics : ', value: this.quoteline.Performance_Metrics__r.length });
        // }

        console.log('this.fieldSet:', JSON.stringify(this.fieldSet));
    }

    @wire(isPricingManager)
    getPricingManager({ error, data }) {
        if (data) {
            this.pricingManager = data;
            console.log('this.pricingManager:', this.pricingManager);
            this.processRecord(this.pricingManager);

        } else if (error) {
            console.error('Error:', error);
        }
    }

    handleMenuItem(event) {

        let menuValue = event.detail.value;
        let quoteLineId = this.quoteline.Id;

        console.log('menuValue:', menuValue, 'quoteLineId', quoteLineId);

        if (menuValue == 'Clone') {
            doClone({ quoteLine: this.quoteline, action: '' })
                .then(result => {
                    console.log('Clone result' + JSON.stringify(result));

                    if (result.isSuccess) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Success',
                            message: 'Record Cloned Successfully ' + result.quoteLineId,
                            variant: 'success'
                        }));

                        this.refreshevent();
                    } else {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: result.messageResult + '',
                            variant: 'error'
                        }));
                    }
                })
                .catch(error => {
                    console.error(error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: error + '',
                        variant: 'error'
                    }));
                });

        } else if (menuValue == "Edit") {

            console.log('Edit:');
            if (this.pricingManager) {
                this.showRPMRecommendation = true;
                getProductName({ quoteLineId: quoteLineId })
                    .then(result => {
                        this.productName = result;
                    }).catch(error => {
                        console.log('error:', error);
                    });

            } else if (this.isSSDQuoteLine) {
                this.isSSDQuoteLineEdit = true;
            } else {
                this.editRecord(quoteLineId);
            }
        } else if (menuValue == "Delete") {

            deleteRecord({ quoteLineId: this.quoteline.Id })
                .then(result => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted Successfully',
                        variant: 'success'
                    }));

                    this.refreshevent();
                })
                .catch(error => {
                    console.error(error);
                    console.error(error);
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: error + '',
                        variant: 'error'
                    }));
                });
        }
        else if (menuValue == Pricing_Send_Request_MD_Button_Label) {
            console.log('Pricing_Send_Request_MD_Button_Label:', Pricing_Send_Request_MD_Button_Label);
            insertOutbound({ parentId: this.quoteline.Id, action: "Create" })
                .then(result => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: '"Quote Line information has been sent to My Deals to Create the deal.',
                        variant: 'success',
                        mode: 'dismissible'
                    }));

                }).catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error',
                        mode: 'sticky'
                    }));
                });

        } else if (menuValue == Pricing_Update_Deal_MD_button_label) {

            insertOutbound({ parentId: this.quoteline.Id, action: "Update" })
                .then(result => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'Quote Line information has been sent to My Deals to Update the deal.',
                        variant: 'success',
                        mode: 'dismissible'
                    }));

                }).catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error',
                        mode: 'sticky'
                    }));
                });

        } else if (menuValue == Pricing_Tender_Cancel_Action) {
            this.actionStr = menuValue;
            this.requestChange(quoteLineId, menuValue);

        } else if (menuValue == Pricing_Tender_QuoteLine_Action_Request_Change) {
            this.actionStr = menuValue;
            this.requestChange(quoteLineId, menuValue);

        } else if (menuValue == Pricing_Tender_QuoteLine_Action_Submit_For_Approval) {
            console.log('Pricing_Tender_QuoteLine_Action_Submit_For_Approval:', Pricing_Tender_QuoteLine_Action_Submit_For_Approval);
            this.handleSubmitForApproval();
        } else if (menuValue == Pricing_Tender_QuoteLine_Action_RevisionRequiredbyOEM) {
            this.revisionCheck = true;
            this.revisionComments = "";
            this.isModalOpen = true;
            this.showRevisionFields = true;
        } else if (menuValue == Pricing_Tender_QuoteLine_Action_RevisionRequiredbyField) {
            this.revisionCheck = true;
            this.revisionComments = "";
            this.isModalOpen = true;
            this.showRevisionFields = true;

        } else if (menuValue === "Approve" || menuValue === "Reject") {

            this.isDisabled = false;
            //added to open the Pop-up for WON/Lost action
            getQuoteLine({ quoteLineId: quoteLineId })
                .then(result => {

                    this.quoteLine = result;
                    isModalOpen = true;
                    this.LineId = quoteLineId;

                }).catch(error => {
                    console.log('error:', error);
                });

        } else if (menuValue === "Won" || menuValue === "Lost") {
            //component.set("v.isModalOpen", true);
            this.actionStr = menuValue;
            this.requestChange(quoteLineId, menuValue);
        } else if (menuValue === Pricing_GetAI_Button_Label) {
            getQuoteLine({ quoteLineId: quoteLineId })
                .then(result => {
                    console.log('getQupteLine:', result);
                    var quoteLn = result;
                    if (quoteLn.SBQQ__ProductName__c == Pricing_Tender_Write_In_Product) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'AI model cannot be run if Write In Product is used.',
                            variant: 'success',
                            mode: 'sticky'
                        }));
                    } else if (quoteLn.Pricing_Other_Competitor_Product_Nm__c != null) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'Error',
                            message: 'AI model cannot be run if Write In Competitor Product is used.',
                            variant: 'success',
                            mode: 'sticky'
                        }));
                    } else {
                        this[NavigationMixin.Navigate]({
                            type: 'standard__navItemPage',
                            attributes: {
                                apiName: Pricing_PriceRecommendation_Page_Link
                            },
                            state: {
                                c__qline: quoteLineId
                            },
                        });
                    }

                }).catch(error => {
                    console.log('error:', error);
                });
        }
    }

    requestChange(quoteLineId, menuValue) {
        let message = "";
        if (menuValue == Pricing_Tender_QuoteLine_Action_Request_Change) {
            message = Pricing_Tender_CR_Existing_Request_Error;
        } else if (menuValue == Pricing_Tender_Cancel_Action || menuValue == Pricing_Tender_QuoteLine_Action_Won || menuValue == Pricing_Tender_QuoteLine_Action_Lost) {
            message = Pricing_Tender_CR_Reference_Status_Change_Message;
        }
        isNotUnifiedQuoteLine({ quoteLineId: quoteLineId })
            .then(data => {
                console.log('data:', JSON.stringify(data));

                let result = data.split(";"); //index[0] = PendingCRExist OR customerBlocked, index[1] = Header, index[2] = unified msg OR QL number
                if (result !== undefined && result !== null) {
                    if (result[0] === 'PendingCRExist') {
                        message = message.replace(this.quoteline.Pricing_Quote_Line_Number__c, result[2]);
                        this.dispatchEvent(new ShowToastEvent({
                            title: '',
                            header: result[1],
                            message: message,
                            variant: 'warning'
                        }));

                    } else if (result[0] === 'customerBlocked' && menuValue == Pricing_Tender_QuoteLine_Action_Won && result[2] !== 'Success') {

                        this.dispatchEvent(new ShowToastEvent({
                            title: '',
                            header: result[1],
                            message: result[2],
                            variant: 'warning'
                        }));

                    } else {
                        if (menuValue == Pricing_Tender_QuoteLine_Action_Request_Change) {
                            this.openChangeRequest(quoteLineId);
                        } else if (menuValue == Pricing_Tender_Cancel_Action) {
                            this.cancelQuoteLine(quoteLineId);
                        } else if (menuValue == Pricing_Tender_QuoteLine_Action_Won || menuValue == Pricing_Tender_QuoteLine_Action_Lost) {
                            // console.log('inside won modal open==>'); // Will open WON modal
                            // isModalOpen = true
                        }
                    }
                }

            }).catch(error => {
                console.log('error:', error);
            });
    }

    openChangeRequest(quoteLineId) {
        console.log('openChangeRequest:', quoteLineId);

        /*
        let modalBody;
        const requestChange = $A.get(
            "$Label.c.Pricing_Tender_QuoteLine_Action_Request_Change"
        );
        $A.createComponent(
            "c:Pricing_QuoteLineRequestChange",
            {
                recordId: quoteLineId,
                action: requestChange,
                refreshParentComponent: component.getReference(
                    "v.refreshParentComponent"
                )
            },
            function (content, status) {
                if (status === "SUCCESS") {
                    modalBody = content;
                    component.find("overlayLib").showCustomModal({
                        body: modalBody,
                        header: requestChange,
                        showCloseButton: true,
                        closeCallback: function () {
                            const refreshParent = component.get("v.refreshParentComponent")
                            if (refreshParent) {
                                $A.get("e.force:refreshView").fire();
                            }
                        }
                    });
                }
            }
        );
        */
    }

    cancelQuoteLine(quoteLineId) {
        console.log('cancelQuoteLine:', quoteLineId);

        /*
        component.set("v.quoteLineToBeDeleted", quoteLineId);
        $A.createComponent("c:Pricing_Modal_Confirmation", {
            quoteLineToBeDeleted: component.getReference("v.quoteLineToBeDeleted"),
            confirmationValue: component.getReference("v.confirmationValue")
        }, function (
            content,
            status
        ) {
            if (status === "SUCCESS") {
                const modalFooter = content;
                component
                .find("overlayLib")
                .showCustomModal({
                    header: "Confirmation",
                    body: "Are you sure you want to cancel this quote line?",
                    footer: modalFooter,
                    showCloseButton: false,
                    cssClass: "slds-text-align_center",
                    closeCallback: function (ovl) {
                        const confirmationValue = component.get("v.confirmationValue");
                        const quoteLineTobecancelled = component.get("v.quoteLineToBeDeleted");
                        if (confirmationValue == "OK") {
                            const action = component.get("c.cancelRecord");
                            action.setParams({
                                quoteLineId: quoteLineTobecancelled
                            });
                            action.setCallback(this, function (response) {
                                const state = response.getState();
                                const customExMessage = response.getReturnValue();
                                console.log('CustomExMessage-->',customExMessage);
                                if (state === "SUCCESS") {
                                    if(customExMessage !== null){
                                        const toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: "Error",
                                            message: customExMessage,
                                            type: "Error",
                                            mode: "dismissible"
                                        });
                                        toastEvent.fire();
                                        $A.get("e.force:refreshView").fire(); 
                                    }else{
                                        const toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: "Success",
                                            message: $A.get(
                                                "$Label.c.Pricing_Tender_Cancel_Quote_Line_Message"
                                            ),
                                            duration: " 3000",
                                            key: "info_alt",
                                            type: "success",
                                            mode: "dismissible"
                                        });
                                        toastEvent.fire();
                                        $A.get("e.force:refreshView").fire(); 
                                    }  
                                } else {
                                    console.log(
                                        $A.get("$Label.c.Pricing_Tender_QuoteLine_CancelErrorMessage")
                                    );
                                }
                            });
                            $A.enqueueAction(action);
                        } else if (confirmationValue == "Cancel") {
                            //closes the modal or popover from the component
                            component.find("overlayLib").notifyClose();
                        }
                        console.log("Overlay is closing");
                    }
                })
                .then(function (overlay) {
                    console.log("Overlay is made");
                });
            }
        });

        */
    }

    handleSubmitForApproval() {
        this.showApprovalErrorScreen = true;

        // Pricing_Publish_Quote need to create LWC
    }

    get changeRequest() {
        console.log('changeRequest:', this.quoteline.Pricing_New_Change_Request_cb__c);
        return this.quoteline.Pricing_New_Change_Request_cb__c;
    }

    setAcronym() {
        let inputText = this.quoteline.Pricing_Status_Nm__c;
        if (inputText != undefined && inputText !== "") {
            if (inputText == Pricing_Tender_QuoteLine_Status_PendingIntelFieldReview) {
                this.acronym = Pricing_Tender_QuoteLine_Status_FieldReview;
            } else if (inputText == Pricing_Tender_QuoteLine_Status_PendingFurtherIntelReview) {
                this.acronym = Pricing_Tender_QuoteLine_Status_PricingReview;
            } else if (inputText == Pricing_Tender_QuoteLine_Status_Cancelled) {
                this.acronym = Pricing_Tender_QuoteLine_Status_Cancelled;
            } else {
                this.acronym = inputText;
            }
        }

    }

    processRecord(rpmUser) {
        if (rpmUser) {
            let integrationStatus = this.quoteline.Pricing_Integration_Status_Nm__c; // NOSONAR
            let errorMessage = this.quoteline.Pricing_Error_Messages__c; // NOSONAR
            if (integrationStatus == "Complete") {
                this.iconName = "utility:success";
                this.alternativeText = integrationStatus;
                this.variant = "Success";
            } else if (integrationStatus == "Pending" || integrationStatus == "InProcess") {
                this.iconName = "utility:warning";
                this.alternativeText = integrationStatus;
                this.variant = "Warning";
            } else if (integrationStatus == "Error") {
                this.iconName = "utility:error";
                this.alternativeText = errorMessage;
                this.variant = "Error";
            }
        }
    }

    get iconName(){
        return this.iconName;
    }

    get showAcronym() {
        console.log('showAcronym:', this.acronym != '' ? true : false);
        return this.acronym != '' ? true : false;
    }

    get showIcons() {
        console.log('showIcons:', this.quoteline.Pricing_Integration_Status_Nm__c != '' && this.pricingManager ? true : false);
        return this.quoteline.Pricing_Integration_Status_Nm__c != '' && this.pricingManager ? true : false;
    }

    editRecord(quoteLineId) {
        console.log('editRecord:');
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: quoteLineId,
                actionName: 'edit',
            },
        });
    }

    setModalAttribute() {

    }

    closeModalRPMRecommendation() {
        this.showRPMRecommendation = false;
    }


    refreshevent() {
        const custEvent = new CustomEvent("refreshevent");
        this.dispatchEvent(custEvent);
    }

    closeModelSSDQuoteLineEdit() {
        console.log('event dispatched:');
        this.isSSDQuoteLineEdit = false;
        this.refreshevent();
    }

}