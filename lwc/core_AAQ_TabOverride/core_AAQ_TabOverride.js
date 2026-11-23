import { track, wire, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getOnLoadValue from '@salesforce/apex/Core_AAQ_TabOverride_Controller.onLoadLWC';
import Core_AAQImage from "@salesforce/resourceUrl/Core_AAQImage";
import getLabel from '@salesforce/apex/core_S2S_CaseExternalFeedController.getLabel';
import { EnclosingUtilityId, getInfo,open,getAllUtilityInfo ,updatePanel,updateUtility } from 'lightning/platformUtilityBarApi';
import chatUrlLabel from '@salesforce/label/c.sales_CRM_ChatUrl';
import chatUrlMDFLabel from '@salesforce/label/c.core_MDF_ChatUrl';
import chatUrlIPALabel from '@salesforce/label/c.core_IPA_ChatUrl';
//import chatUrlIQRLabel from '@salesforce/label/c.core_IQR_ChatUrl';//IQR AAQ
import chatHeader from '@salesforce/label/c.sales_CRM_ChatHeader';
import chatBanner from '@salesforce/label/c.chatBanner';
import chatTooltipSalesCRM from '@salesforce/label/c.chatTooltipSalesCRM';
import chatTooltipAE from '@salesforce/label/c.chatTooltipAE';
import chatTooltipIPS from '@salesforce/label/c.chatTooltipIPS';
import chatTooltipMDF from '@salesforce/label/c.chatTooltipMDF';
import chatTooltipIPA from '@salesforce/label/c.chatTooltipIPA';
import chatTooltipIQR from '@salesforce/label/c.chatTooltipIQR';//IQR AAQ
// Removed fallback string constants for labels

export default class Core_AAQ_TabOverride extends NavigationMixin(LightningElement) {

    @wire(EnclosingUtilityId) utilityId;
    @track isChatModalOpen = false;
    chatUrl = chatUrlLabel; // Use your actual chat URL
    MDFChatUrl = chatUrlMDFLabel;
    IPAChatUrl = chatUrlIPALabel;
    //IQRChatUrl = chatUrlIQRLabel;//IQR AAQ
    chatHeader = chatHeader;
    chatBanner = chatBanner;
    chatTooltipSalesCRM = chatTooltipSalesCRM;
    chatTooltipAE = chatTooltipAE;
    chatTooltipIPS = chatTooltipIPS;
    chatTooltipMDF = chatTooltipMDF;
    chatTooltipIQR = chatTooltipIQR;//IQR AAQ
    @track showIframe = false;


    panelAttrs = {
        label: chatHeader,
        icon: 'einstein',
        highlighted: true,
        iconVariant: 'brand'
    }

    @track categoryColumn = [];
    error;
    isModel;
    isflowReady;
    inputVariables;
    modalHeader;
    newCaseId;
    labels = {};
    images = ''

    connectedCallback() {
        this.initTopic();
        if (localStorage.getItem('recordId')) {
            localStorage.removeItem("recordId");
        }
    }

    closeChatPanel() {
        this.showIframe = false;
    }

    openChatModal(event) {
        // Get the custom chat URL from the button's data attribute if it exists
        const button = event.currentTarget;
        const customChatUrl = button.getAttribute('data-chat-url');
        
        if (customChatUrl) {
            this.chatUrl = customChatUrl;
        }
        
        this.showIframe = true;
        this.isModel = false;
    }

    closeChatModal() {
        this.isChatModalOpen = false;
    }


    /****************************************************************************************** 
     * Init the topic from Custom Setting.
     * @param 
    *****************************************************************************************/
    initTopic() {
        getOnLoadValue().then((data, error) => {
            if (data) {
                this.categoryColumn = data.map((item, index) => {
                    const isChatBotProfile =
                        item.Name === 'Sales CRM' ||
                        item.Name === 'Access & Entitlement for Salesforce' ||
                        item.Name === 'Intel® Premier Support' ||
                        item.Name === 'Partner Investment Center'||
                        item.Name === 'Intel Partner Alliance'||
                        item.Name === 'Intel Quote Request';//IQR AAQ
                    let tooltipText = '';
                    if (item.Name === 'Sales CRM') {
                        tooltipText = chatTooltipSalesCRM;
                    } else if (item.Name === 'Access & Entitlement for Salesforce') {
                        tooltipText = chatTooltipAE;
                    } else if (item.Name === 'Intel® Premier Support') {
                        tooltipText = chatTooltipIPS;
                    } else if (item.Name === 'Partner Investment Center') {
                        tooltipText = chatTooltipMDF;
                    }else if (item.Name === 'Intel Partner Alliance') {
                        tooltipText = chatTooltipIPA;
                    }else if (item.Name === 'Intel Quote Request') {
                        tooltipText = chatTooltipIQR; //IQR AAQ
                    }
                
                    // Add rowClass for first 3 rows and 5th row
                    const rowClass = (index < 3 || index == 4) ? 'aaq-row-pr2' : '';
                    // Add a flag for the 5th row (index 4) to use a different chat URL
                    const isMDFRow = index === 4;
                    // Add a flag for the 8th row (index 7) to use IPA chat URL
                    const isIPARow = index === 7;
                    //const isIQRRow = index ===8;
                    const chatUrl = isMDFRow ? this.MDFChatUrl : isIPARow ? this.IPAChatUrl : this.chatUrl; //IQR AAQ
                    return Object.assign(
                        {},
                        item,
                        { imageURL: Core_AAQImage + '/' + item.Core_Profile_Image__c },
                        { desc: (item.Core_Description__c != null ? item.Core_Description__c : '') + ' ' + (item.Core_Description2__c != null ? item.Core_Description2__c : '') },
                        { isChatBotProfile },
                        { tooltipText },
                        { rowClass },
                        { isMDFRow },
                        { chatUrl }
                    );
                });
            }
            else if (error) {
                this.error = error;
                this.categoryColumn = undefined;
            }
        })
    }

    /****************************************************************************************** 
     * Handle modal and set value as true for modal.
     * @param 
    *****************************************************************************************/
    async handleModal(event) {
        const categoryName = event.currentTarget.dataset.val;
        this.isModel = true;
        this.modalHeader = categoryName;
        this.showIframe = false;
    }

    async handleGetAllUtilityInfo() {
        try {
            const utilityInfo = await getAllUtilityInfo();
            this.utilityCount = utilityInfo.length;

        } catch (error) {
            // return error
        }
    }


    /****************************************************************************************** 
     * Navigate to Related List View.
     * @param 
    *****************************************************************************************/
    navigateRelatedListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'View_ICS_Case',
            }
        });
    }

    /****************************************************************************************** 
     * Handle modal close and set value as false.
     * @param 
    *****************************************************************************************/
    handleModalClose() {
        this.isModel = false;
    }

    /****************************************************************************************** 
         * Return the labels and set the map.
         * @param { } .
         *****************************************************************************************/
        @wire(getLabel)
        getLabels({
            error,
            data
        }) {
            if (data) {
                let labels = {};
                data.forEach(lab => {
                    labels[lab.Name] = lab.Value__c;
                });
                this.labels = labels;
            } else if (error) {
                console.error('Error fetching labels:', error);
            }
        }

    /****************************************************************************************** 
     * Navigate to chatbot page
     * @param 
    *****************************************************************************************/
    navigateToChatbot(){
        window.open(this.labels.SWS_ChatBotURL, '_blank');
    }
}