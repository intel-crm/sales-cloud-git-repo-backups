({
	/**
   	* Executes after the content has been rendered. By this point, the meta tags should be 
    * inserted into the DOM.
   	* @param {Object} component  The Lightning component object.
  	* @param {Object} helper  The Helper associated with this object.
  	*/
    afterRender: function (component, helper) {
        // Standard after render called
        this.superAfterRender();
        
        // Use the library component to send the data and domain for the analytics message.
        // There is a window message listener in the HEAD script that will call the salesforceHit method.
        const analyticsLibrary = component.find("analyticsLibrary");

        // Make the analytics call and add the canonical link
        const analyticsPageType = component.get("v.analyticsPageType");
        analyticsLibrary.callAnalytics(analyticsPageType, 'Marketplace', true);

        // Get components used for the breadcrumbs
        const coreIntcBreadcrumbs = component.find("coreIntcBreadcrumbs");
        const ipaBreadcrumbsServiceMarketplace = component.find("ipaBreadcrumbsServiceMarketplace");

        // Call the service to get the breadcrumbs
        ipaBreadcrumbsServiceMarketplace.getMarketplaceBreadcrumbs().then((breadcrumbs) => {
          breadcrumbs.analyticsData = analyticsLibrary.getAnalyticsData(analyticsPageType, 'Marketplace');
          // Call the component to render the breadcrumbs
          coreIntcBreadcrumbs.renderBreadcrumbs(breadcrumbs);
        });
	},
})