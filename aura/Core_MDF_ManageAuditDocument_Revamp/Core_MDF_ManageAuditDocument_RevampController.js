({
  //executed on initial load of the component
  doInit: function (component, event, helper) {
    helper.initiateComponent(component, event, helper);
  },

  //This method is executed on click of done, after doc upload is finished
  handleUploadFinished: function (component, event, helper) {
    helper.createObjectDocuments(component, event);
  },

  //This method is executed on selection/de-selection of document types
  checkSubmitEnable: function(component, event, helper) {
    console.log("event params", event.getParam("checkboxName"));
    helper.updateDocumentTypeSelection(component, event, helper);
  },

  //This method is executed on click of save from document type selection popup
  save: function(component, event, helper) {
    helper.updateObjectDocuments(component, event, helper);
  },
  
  // This method is executed on click of delete icon
  deleteSelected: function(component, event, helper) {
    component.set("v.isDeleteClicked", true);
    let dataId = event.currentTarget.getAttribute("data-Id");
    component.set("v.selectedDocumentId", dataId);
    let docName = event.currentTarget.getAttribute("name");
    component.set("v.selectedDocumentName", docName);
    let docIndex  = event.currentTarget.getAttribute("data-Index");
    component.set("v.selectedDocumentIndex", docIndex);
  },

  // This method is executed on click of No from Delete confirmation popup
  handleConfirmNo: function (component, event, helper) {
    component.set("v.isDeleteClicked", false);
  },

// This method is executed on click of yes from Delete confirmation popup
  handleConfirmYes: function (component, event, helper) {
    let docId = component.get("v.selectedDocumentId");
    let docIndex = component.get("v.selectedDocumentIndex");

    helper.deleteDocs(component, docId, docIndex);
    component.set("v.isDeleteClicked", false);
  },

  // This method is executed on click of manage documents button
  openModal: function (component, event, helper) {
    component.set("v.isOpen", true);
    component.set("v.showDeleteOption", true);
    var docList = component.get("v.auditDocument");
    helper.getDocumentDetails(component, docList);
  },
})