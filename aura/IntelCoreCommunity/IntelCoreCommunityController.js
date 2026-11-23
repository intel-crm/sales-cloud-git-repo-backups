({
  doInit : function(component, event, helper) {
    // Preload labels that are used in the coreIntcCommunity script - even though they are commented Salesforce will recognize them
    // $Label.c.PMP_SSO_IPA
    // $Label.c.PMP_SSO_Leads
    // $Label.c.PMP_SSO_Marketplace
    
    // There is a listener in the community's HEAD script that will listen for this message  
    var FullLocation = window.location.protocol + '//' + window.location.hostname + (window.location.port ? ':' + window.location.port : '');
      window.postMessage({type: 'intel.loadCommunityCore'}, FullLocation);
    }
})