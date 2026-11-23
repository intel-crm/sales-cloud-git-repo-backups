import { LightningElement, api } from 'lwc';

/**
 * Generic reusable Screen Flow launcher modal.
 *
 * Usage (Aura parent):
 *   <c:core_MDF_ScreenFlowLauncher
 *       flowApiName="My_Flow"
 *       headerTitle="Optional Modal Title"
 *       navigateTo="My_Object__c"
 *       flowInputVariables="{!v.myInputVars}"
 *       onclose="{!c.handleFlowDismiss}"
 *       onfinished="{!c.handleFlowDismiss}"
 *       onerror="{!c.handleFlowError}" />
 *
 * Usage (LWC parent):
 *   <c-core_-m-d-f_-screen-flow-launcher
 *       flow-api-name="My_Flow"
 *       navigate-to="My_Object__c"
 *       onclose={handleFlowDismiss}
 *       onfinished={handleFlowDismiss}>
 *   </c-core_-m-d-f_-screen-flow-launcher>
 *
 * Events dispatched:
 *   close    — user clicked the X button
 *   finished — flow completed (FINISHED or FINISHED_SCREEN)
 *   error    — flow encountered an error
 *
 * Navigation is intentionally left to the parent so it works in
 * both Aura (force:navigateToObjectHome) and LWC (NavigationMixin) contexts.
 */
export default class Core_MDF_ScreenFlowLauncher extends LightningElement {
    /** API name of the Screen Flow to launch */
    @api flowApiName;

    /** Optional modal header title. If empty, no header is rendered. */
    @api headerTitle;

    /**
     * Object API name the parent should navigate to on close / finish.
     * Stored here so the parent can read it back from the event if needed.
     */
    @api navigateTo;

    /** Optional array of flow input variables: [{ name, type, value }] */
    @api flowInputVariables = [];

    handleClose() {
        this.dispatchEvent(new CustomEvent('close', { detail: { navigateTo: this.navigateTo } }));
    }

    handleStatusChange(event) {
        const { status } = event.detail;
        if (status === 'FINISHED' || status === 'FINISHED_SCREEN') {
            this.dispatchEvent(new CustomEvent('finished', { detail: { navigateTo: this.navigateTo } }));
        } else if (status === 'ERROR') {
            this.dispatchEvent(new CustomEvent('error'));
        }
    }
}