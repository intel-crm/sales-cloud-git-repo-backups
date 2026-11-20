import { LightningElement, track } from 'lwc';
import downloadTemplate from '@salesforce/apex/SWS_DownloadTemplateController.downloadTemplate';
import { NavigationMixin } from 'lightning/navigation';

export default class SWS_downloadTemplate extends NavigationMixin(LightningElement) {
    fileName = 'SWS_Cloud_Credit_Import_Template.zip';
    @track isLoading = false;
    currentURL;
    recordPageUrl;

    connectedCallback() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SWS_Cloud_Credit_Request__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            },
        }).then((url) => {
            this.recordPageUrl = url;
        });
        this.handleDownload();
    }

    handleDownload() {
        this.isLoading = true;
        downloadTemplate()
            .then(result => {
                if (result != null) {
                    this.download(result);
                }
            })
            .catch(error => {
                console.error('Error downloading file: ', error);
            })
            .finally(() => {
                this.isLoading = false;
            });
    }


    async download(fileContent) {
        let downloadElement = document.createElement('a');
        downloadElement.download = this.fileName;
        downloadElement.href = 'data:application/zip;base64, ' + fileContent;
        document.body.appendChild(downloadElement);
        await downloadElement.click();
        document.body.removeChild(downloadElement);

        this.currentURL = window.location.href;
        await this.navigateToCreditRequestTab();
    }

    navigateToCreditRequestTab() {
        window.open(this.recordPageUrl,'_self');
    }
}