import { api, LightningElement } from 'lwc';

/**
 * A component to remove the "All" option from a Salesforce Dashboard component and automatically select the first option in the filter.
 *
 * @augments LightningElement
 * @property {string} dashboardId The ID to assign to this dashboard.
 * @property {string} [srcSelector] Optional QuerySelector string to use to find the dashboard component's dashboardContainer.
 *  This text will be added before "div.dashboardContainer iframe" in order to find the dashboard's iframe. 
 */
class IpaDashboardUpdater extends LightningElement {
  // ******* API variables - defined in class properties *******
  @api dashboardId;

  @api srcSelector;


  // ******* Class variables *******
  /**
   * The full URL for the current page. Used when posting window messages.
   *
   * @type {string}
   * @private
   */
  FullLocation = `${window.location.protocol}//${window.location.hostname}${window.location.port ? `:${window.location.port}` : ''}`;



  // ******* Standard Methods ********
  /**
   * Creates the dashboard config object and posts it to the window. This will be picked up by the community's HEAD
   * code and relayed to the CoreIntcCommunity component.
   *
   * @private
   */
  connectedCallback() {
      const dashboard = {
        filters: [
          {
            executeInitial: true,
            removeIndex: 0,
          },
        ],
        id: this.dashboardId,
        srcSelector: this.srcSelector,
      };
      window.postMessage({ type: 'intel.updateDashboard', data: dashboard }, this.FullLocation); // NOSONAR
  }



  /**
   * Posts the dashboard ID to the window in order to cancel any currently running timeouts related to the dashboard.
   * This will be picked up by the community's HEAD code and relayed to the CoreIntcCommunity component.
   *
   * @private
   */
  disconnectedCallback() {
    window.postMessage({ type: 'intel.cancelDashboard', data: this.dashboardId }, this.FullLocation); // NOSONAR
  }
}
export default IpaDashboardUpdater;