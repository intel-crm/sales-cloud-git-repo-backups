({
  doInit : function(component, event, helper) {
    // Preload labels that are used in the coreIntcCommunity script - even though they are commented Salesforce will recognize them
    // $Label.c.Core_Intc_Language_Change_Error
    // $Label.c.Core_Intc_Language_Change_Error_Link
    // $Label.c.Core_Intc_Locales1
    // $Label.c.Core_Intc_Locales2
    // $Label.c.Core_Intc_Ighf_Url
    // $Label.c.Core_Intc_Siteminder_Status
    // $Label.c.PMP_SSO_IPA
    // $Label.c.PMP_SSO_Leads
    // $Label.c.PMP_SSO_Licensing
    // $Label.c.PMP_SSO_Marketplace

    // There is a listener in the community's HEAD script that will listen for this message
    const fullLocation = `${window.location.protocol}//${window.location.hostname}${window.location.port ? `:${window.location.port}` : ''}`;
    window.postMessage({type: 'intel.loadCommunityCore'}, fullLocation); // NOSONAR

    // Needed for error handling
    const pendingErrors = [];
    let coreErrorHandlerLoaded = false;

    // Set up a listener for errors thrown outside of the Salesforce framework (like those from the coreIntcCommunity.js file)
    window.addEventListener('message', function(evt) {
      if (evt.origin === fullLocation && evt.data) {
        if (evt.data.type === 'intel.coreErrorLoaded') {
          // This type means the coreIntcErrorHandler component has been loaded, and it has subscribed to the coreIntcErrorMessages channel
          coreErrorHandlerLoaded = true;
          const messageComponent = component.find('coreErrorChannel');

          // Publish any errors that were thrown before the handler was loaded
          if (pendingErrors.length) {
            pendingErrors.forEach((error) => {
              messageComponent.publish(error);
            });
            pendingErrors.length = 0;
          }
        } else if (evt.data.type === 'intel.coreError') {
          // An error was captured so change its type before publishing it
          evt.data.type =  evt.data.coreType;
          delete evt.data.coreType;

          // Check if need to convert the error object from a string back to an object
          if (typeof evt.data.error === 'string') {
            evt.data.error = JSON.parse(evt.data.error);
          }

          // Only publish if the handler has loaded, otherwise add it to an array
          if (coreErrorHandlerLoaded) {
            component.find('coreErrorChannel').publish(evt.data);
          } else {
            pendingErrors.push(evt.data);
          }
        }
      }
    });
  },
});