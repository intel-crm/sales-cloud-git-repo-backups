import { LightningElement,track } from 'lwc';
import uploadFileApex from '@salesforce/apex/FormRecognizerIntegration.readDocumentContents';
import getAnalysisResult from '@salesforce/apex/FormRecognizerIntegration.makeCallout';

export default class claimezy extends LightningElement {
  @track detailsMap=[];
  @track file;
  @track fileContent;
  @track showSpinner = false;
  @track invoiceDetails;

    handleFileChange(event) {
      this.file = event.target.files[0];
  }
  handleUpload() {
    if (this.file) {
        this.readFile();
    } else {
        // Handle error: No file selected
    }
}

readFile() {
  const reader = new FileReader();

  reader.onloadend = () => {
      this.fileContent = reader.result.split(',')[1]; // Extract base64 content
      console.log('fileContent:'+this.fileContent);
      this.showSpinner = true;
      uploadFileApex({ fileContent: this.fileContent})
      .then(result => {
          // Handle the result from the Apex method
          console.log(result);
          this.getContent(result);
      })
      .catch(error => {
          // Handle any errors
          console.error(error);
      });
        
  };

  reader.readAsDataURL(this.file);
}


    getContent(resultId) {
      // Call the Apex method to handle the file content
      getAnalysisResult({ modelId: 'prebuilt-layout',resultId: resultId})
          .then(result => {
            this.invoiceDetails = this.parseInvoiceDetails(result);
            
          })
          .catch(error => {
              // Handle any errors
              console.error(error);
          })
          .finally(() => {
            this.showSpinner = false; // Hide spinner after the call is completed
        });
  }

  parseInvoiceDetails(invoiceString) {
    const detailsArray = invoiceString.split('&');
    return detailsArray.map(detail => {
        const [label, value] = detail.split(':');
        return { key: label.trim(), label: label.trim(), value: value.trim() };
    });
}

}