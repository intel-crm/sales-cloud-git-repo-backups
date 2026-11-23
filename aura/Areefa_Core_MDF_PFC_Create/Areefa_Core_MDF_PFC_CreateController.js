({
    // Method is called on component Initalization
    doInit: function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    
    // Method is called on click of cancel icon
    closeModal: function(component, event, helper) {
        helper.closeModel(component);
    },
    
    // This method fetches the Activity details
    fetchActivityDetails : function(component,event,helper){
        helper.fetchActivityRecord(component, event, helper);        
    },
    
    // This method sets the RequestId and escalationId on change of Activity LookUp
    updateLookUpId : function(component,event,helper){
        helper.updateLookupField(component,event);
    },
    
    // This method clears the RequestId and escalationId on change of Activity LookUp
    clearLookUpId : function(component,event,helper){
        helper.clearLookupField(component,event);
    },
    //This function is used to close error toast message
    closeErrorToast: function(component, event, helper) {
        var cmpTarget = component.find('errorToast');
        $A.util.addClass(cmpTarget, 'slds-hide');  
    },    
    
    // Method is called on click of Finish and Save Button
    finish : function(component,event,helper){
        helper.saveClaim(component);        
    },
    
    //This function is used to moveNext/KPI/Document uploade section from duplicate OK button
    handleDuplicateClick : function(component,event,helper){
        component.set("v.isOkDisabled",true);
        component.set("v.isDuplicate", false);
        //Navigate to POP and KPI tab, on click of duplicate OK button and click on POP Tab
        helper.navigateToPopAndKpiTab(component);
    },
    
    //This function used to open popup, if duplicate claim exists
    openDuplicateModel: function(component,event,helper){
        component.set('v.isDuplicate',true);
        component.set("v.isOkDisabled",false);
    },
    
    
    //This function is used to close duplicate model
    closeDuplicateModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isDuplicate" attribute to "False"  
        component.set("v.isDuplicate", false);
        component.set("v.isSaveDisabled",false);
        component.set("v.isOkDisabled",false);
        component.set("v.currentStep", "1");
    },
    
    // This function is use to move to pervious Tab
    moveBack : function(component,event,helper){
        helper.navigateToPreviousTab(component);
    },
    
    // This method fetches the escalation details
    fetchEscalationDetails : function(component,event,helper){
        helper.fetchEscalationDetails(component);
    },    
    
    //This function is use to set KPI flag to show KPI section
    setKpiFlag:function(component,event){
        component.set('v.isKpiSectionVisible',event.getParam('isKpiApplicable'));
        //Spinner stops when KPI tab opens
        component.set("v.Spinner", false);
    },
    
    // This function is use to move to Next/pervious Tab on click on Tab
    navigateOverTab : function(component,event,helper){
        helper.navigationOverTab(component,event,helper);
    },
    
    // This function is use to move to next Tab on click of next button
    moveNext: function(component,event,helper){
        helper.navigateToNextTab(component,event,helper);
    },
    
    // Show/ Hide Vat OptIn Picklist field based on the Legal Entity(bank) Selected
    showOrHideVatOptInOnLEChange: function(component,event,helper){
        helper.showOrHideVatOptIn(component);
    },
    
    showOrHideclaimMediaVehicle: function(component,event,helper){
        helper.showOrHideclaimMediaVehicle(component);
    },
    
    //POC Method Below
    onMultiSelectChange: function(cmp) {
         var selectCmp = cmp.find("InputSelectMultiple");
         var resultCmp = cmp.find("multiResult");
         resultCmp.set("v.value", selectCmp.get("v.value"));
	 },
    
    poc2: function(cmp) {
        // FIX (ALTERNATE) if need to set default in markup
        // use a different attribute
        // var list = cmp.get('v.groceriesDefault');
        // FIX: Set the value in code
        var list = ['Eggs', 'Bacon', 'Bread'];
        // Some logic
        cmp.set('v.groceries', list);
    },
    onSelectChange : function(component, event, helper) {
    var selected = component.find("levels").get("v.value");
    //do something else
},
    handleChange: function (component, event) {
        //helper.handleChange(component);        
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        alert("Option selected with value: '" + selectedOptionValue.toString() + "'");
        component.set("v.inputValue",selectedOptionValue);
    },
    onBudgetSelection : function(component, event, helper) {
        debugger;
        //let arrayFromChild = event.detail;
       	component.set("v.inputValue",event.getParam('value')); 
        component.set("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c", event.getParam('value'));
       	//component.set("v.inputValue",event.getParam('selectedvalues'));
        //component.set("v.inputValue",event.detail.recordId);
        //var selectedOptionValue = event.getParam('value');
        //alert("Option selected with value: '" + selectedOptionValue);
       //component.set("v.inputValue",event.getParam('value'));
       //alert("Option selected with value: '" + event.getParam("recordId").toString() + "'");
	   //component.set("v.inputValue",event.getParam('budgetValues'));
       // console.log("option selected with value:",component.get("v.inputValue"));
	},
    onValueSelection : function(component, event, helper) {
        debugger;
    	component.set("v.inputValue",event.getParam('value')); 
        component.set("v.simpleNewClaim.Core_MDF_Activity_SubType_nm__c", event.getParam('value'));
    }
    
})