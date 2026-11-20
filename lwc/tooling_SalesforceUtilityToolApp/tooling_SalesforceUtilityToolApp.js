import { LightningElement } from 'lwc';
export default class Tooling_SalesforceUtilityToolApp extends LightningElement {

    // nav related changes
    selectedNav = 'Unused Attributes';

    // Method to toggle the left sidebar panel
    togglePanel() {
        // Get references to the left and right panels
        let leftPanel = this.template.querySelector("div[data-my-id=leftPanel]");
        let rightPanel = this.template.querySelector("div[data-my-id=rightPanel]");

        // Check if the left panel is open or closed, then toggle its class accordingly
        if (leftPanel.classList.contains('slds-is-open')) {
            // If open, close the left panel and expand the right panel
            leftPanel.classList.remove("slds-is-open");
            leftPanel.classList.remove("open-panel");
            leftPanel.classList.add("slds-is-closed");
            leftPanel.classList.add("close-panel");
            rightPanel.classList.add("expand-panel");
            rightPanel.classList.remove("collapse-panel");
        } else {
            // If closed, open the left panel and collapse the right panel
            leftPanel.classList.add("slds-is-open");
            leftPanel.classList.add("open-panel");
            leftPanel.classList.remove("slds-is-closed");
            leftPanel.classList.remove("close-panel");
            rightPanel.classList.remove("expand-panel");
            rightPanel.classList.add("collapse-panel");
        }
    }

    // Method to rotate the refresh button icon when clicked
    refreshUserData(evt) {
        const buttonIcon = evt.target.querySelector('.slds-button__icon');
        buttonIcon.classList.add('refreshRotate');
        setTimeout(() => {
            buttonIcon.classList.remove('refreshRotate');
        }, 1000);
    }

    // Method to handle selection in the vertical navigation menu
    handleSelect(event) {
        const selected = event.detail.name;
        this.selectedNav = selected;
    }

    // Getter property to determine if "Unused Attributes" is selected
    get unsedAttrTrue() {
        return this.selectedNav === 'Unused Attributes';
    }

    // Getter property to determine if "Search Object/Field" is selected
    get sof() {
        return this.selectedNav === 'Search Object/Field';
    }

    // Getter property to determine if "Data Export" is selected
    get exportEnabled() {
        return this.selectedNav === 'Data Export';
    }

    // Getter property to determine if "Check Custom Label Usage" is selected
    get searchLabels() {
        return this.selectedNav === 'Check Custom Label Usage';
    }
}