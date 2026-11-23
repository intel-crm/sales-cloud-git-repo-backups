({
    // LightningComponentController.js
    doInit: function(component, event, helper) {
        // Get the Coveo Insight Panel Lightning Component
        var coveoAgentPanel = component.find('coveoAgentPanel');
        // Get the Coveo SearchUI base component
        var coveoSearchUI = coveoAgentPanel.get('v.searchUI');
        // Apply the customization
        coveoSearchUI.executeQuery();
    }
    
})