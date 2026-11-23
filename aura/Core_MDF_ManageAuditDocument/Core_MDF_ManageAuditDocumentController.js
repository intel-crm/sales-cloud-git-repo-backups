({
  //Initializing the components by setting attributes 
  doInit: function (component, event, helper) {
    console.log('Inside Core_MDF_AuditDocumentHelper'+component.get('v.editClaimId'));
    helper.initiateComponent(component, event, helper); 
  },

  //Upon Susccessful upload Case Review Document records will be created
  // isOpen attribute is set true, to open file selection model    
  handleUploadFinished: function (component, event, helper) {
    helper.createObjectDocuments(component, event);

  },

  // To Display Modal,set "isOpen" attribute to "True"
  openModal: function (component, event, helper) {
    component.set("v.isManageButtonClicked", true);
    component.set("v.isOpen", true);
    var docList = component.get("v.auditDocument");
    helper.getDocName(component, event, docList);
  },

  // To Hide/Close Modal,set "isOpen" attribute to "False"
  closeModal: function (component, event, helper) {
    component.set("v.isOpen", false);
  },

  //Submit button Enable and Disable will handled in this method
  checkSubmitEnable: function (component, event, helper) {
    helper.enableDisableSubmitButton(component, event);   
  },

  //The Changes made from UI will be saved in Database.
  //After successful save, user will be navigated to case details page.
  saveAndClose: function (component, event, helper) {
    component.set("v.isSaveAndCloseClicked", true);
    helper.updateObjectDocuments(component, event);
  },

  //The Changes made from UI will be saved in Database and modal will be retained.
  save: function (component, event, helper) {
    //alert('I clicked on save');
    helper.updateObjectDocuments(component, event);
  },

  //The Changes made from UI will be saved in Database and modal will be retained.
  //Case Status will be set Under Review and SLA Start Date will be set to current date.
  //After successful save, user will be navigated to case details page.
  submit: function (component, event, helper) {
    helper.updateObjectAndDocument(component, event);
  },

  //The Changes made from UI will be saved in Database and modal will be retained.
  //Case Status will be set Under Review and SLA Start Date will be set to current date.
  //After successful save, user will be navigated to case details page.
  downloadAllDocument: function (component, event, helper) {
    helper.autoDownload(component, event);
  },

  // Upon clicking the submit message button on UI, to open the modal "isClaimMessage" is setting to true
  callClaimSubmitterAction: function (component, event, helper) {
    //alert("inside callClaimSubmiiter"+'v.toggleClaimMessagePopUp');
    component.set("v.toggleClaimMessagePopUp", true);
  },

  // Upon clicking on submit button, updateMessageOnCase method is called and message is saved on UI
  // After successful save user will be navigated to case details page.
  onSubmit: function (component, event, helper) {
    //alert("inside onSubmit");
    helper.updateMessageOnCase(component, event, helper);
  },

  // Upon clicking on cancel button, modal will be closed
  // Closing the modal and resetting the submitter message
  onCancel: function (component, event, helper) {
    component.set("v.toggleClaimMessagePopUp", false);
    component.set("v.claimSubmitterMessage", '');
  },


  deleteSelected: function (component, event, helper) {
    var userconfrm = confirm($A.get("$Label.c.Core_MDF_Delete_Confirm"));
    if (userconfrm) {

      var dataId = event.currentTarget.getAttribute("data-Id");
      component.set("v.selectedDocumentId", dataId);

      //console.log('document id selected'+dataId);
      var docIdsToDel = [];
      docIdsToDel.push(dataId);

      var documentids = event.target.dataset.index;

      helper.deleteDocs(component, docIdsToDel, documentids);

    }
  },

  validateDocuments: function (component, event, helper) {
    var doclist = component.get("v.auditDocument");
    component.set("v.showToast", false);
    helper.validateDocuments(component, doclist);
  },

})