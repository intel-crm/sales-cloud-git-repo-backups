import { LightningElement } from 'lwc';
import iGPTChatURLWithLtdAccess from '@salesforce/label/c.iGPT_ChatUrl';
import iGPTChatURLWithoutLtdAccess from '@salesforce/label/c.iGPTChatURLWithoutLtdAccess';
import hasSMGOneAIPermission from '@salesforce/customPermission/SMG_One_AI_Plugin';
import salesCrmTabLabel from '@salesforce/label/c.Sales_CRM_Tab_Label';
import vitaTabLabel from '@salesforce/label/c.VITA_Tab_Label';
import vitaChatURL from '@salesforce/label/c.VITA_ChatUrl';
import hasVITAPermission from '@salesforce/customPermission/One_AI_VITA';

import vitaErrorMessageBody from '@salesforce/label/c.CRM_Vita_Error_Message_Body';
import vitaErrorMessageHeader from '@salesforce/label/c.CRM_Vita_Error_Message_Header';
import vitaErrorMessageHyperlink from '@salesforce/label/c.ViTA_Error_message_Hyperlink_and_Hyperlink_test';

export default class SmgChatBot extends LightningElement {
    iGPTChatURLWithLtdAccess = iGPTChatURLWithLtdAccess;
    iGPTChatURLWithoutLtdAccess = iGPTChatURLWithoutLtdAccess;
    hasSMGOneAIPermission = hasSMGOneAIPermission;
    currentActiveTab = 'igpt';
    salesCrmTabLabel = salesCrmTabLabel;
    vitaTabLabel = vitaTabLabel;
    vitaChatURL = vitaChatURL;
    hasVITAPermission = hasVITAPermission;
    //putting hardcoed messages in ExternalString (custom Label)
    vitaErrorMessageHyperlink =vitaErrorMessageHyperlink.split(" ; ")[0];
    vitaErrorMessageHyperlinkText = vitaErrorMessageHyperlink.split(" ; ")[1];
    vitaErrorMessageHeader = vitaErrorMessageHeader;
    vitaErrorMessageBody = vitaErrorMessageBody;
    //
    connectedCallback() {
        // Restore the active tab from storage on component load
        this.restoreActiveTab();
    }

    restoreActiveTab() {
        try {
            const savedTab = sessionStorage.getItem('smgChatBotActiveTab');
            if (savedTab && (savedTab === 'igpt' || savedTab === 'salescrm' || savedTab === 'vita')) {
                // Only set to salescrm if user has permission for it
                if (savedTab === 'salescrm' && this.hasSMGOneAIPermission) {
                    this.currentActiveTab = savedTab;
                } else if (savedTab === 'vita') {
                    // Allow VITA tab navigation regardless of permission to show access denied message
                    this.currentActiveTab = savedTab;
                } else {
                    // Default to igpt if no permission for salescrm or if it's igpt
                    this.currentActiveTab = 'igpt';
                }
            } else {
                // Default to igpt on first load
                this.currentActiveTab = 'vita';
            }
        } catch (error) {
            console.warn('SessionStorage not available:', error);
            this.currentActiveTab = 'vita';
        }
    }

    saveActiveTab() {
        try {
            sessionStorage.setItem('smgChatBotActiveTab', this.currentActiveTab);
        } catch (error) {
            // Handle cases where sessionStorage is not available
            console.warn('Unable to save active tab to sessionStorage:', error);
        }
    }

    get igptUrl() {
        return this.iGPTChatURLWithLtdAccess;
    }

    get salesCrmUrl() {
        return this.iGPTChatURLWithoutLtdAccess;
    }

    get vitaUrl() {
        return this.vitaChatURL;
    }

    get showSalesCrmTab() {
        return this.hasSMGOneAIPermission;
    }

    get showVitaTab() {
        return this.hasVITAPermission;
    }

    get isIgptActive() {
        return this.currentActiveTab === 'igpt';
    }

    get isSalesCrmActive() {
        return this.currentActiveTab === 'salescrm';
    }

    get isVitaActive() {
        return this.currentActiveTab === 'vita';
    }

  
    get activeIgptTabClass() {
        return this.currentActiveTab === 'igpt' ? 'slds-tabs_scoped__link slds-is-active' : 'slds-tabs_scoped__link';
    }

    get activeSalesCrmTabClass() {
        return this.currentActiveTab === 'salescrm' ? 'slds-tabs_scoped__link slds-is-active' : 'slds-tabs_scoped__link';
    }

    get activeVitaTabClass() {
        return this.currentActiveTab === 'vita' ? 'slds-tabs_scoped__link slds-is-active' : 'slds-tabs_scoped__link';
    }

    get igptTabContentClass() {
        return this.currentActiveTab === 'igpt' ? 'slds-tabs_scoped__content slds-show' : 'slds-tabs_scoped__content slds-hide';
    }

    get salesCrmTabContentClass() {
        return this.currentActiveTab === 'salescrm' ? 'slds-tabs_scoped__content slds-show' : 'slds-tabs_scoped__content slds-hide';
    }

    get vitaTabContentClass() {
        return this.currentActiveTab === 'vita' ? 'slds-tabs_scoped__content slds-show' : 'slds-tabs_scoped__content slds-hide';
    }

    handleTabChange(event) {
        event.preventDefault();
        const newTab = event.target.dataset.value;
        // Switch tabs without refresh - authentication will be shared
        if (newTab !== this.currentActiveTab) {
            this.currentActiveTab = newTab;
            // Save the active tab to localStorage for persistence
            this.saveActiveTab();
        }
    }
}