import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CORE_MDF_SFTNAME_SHORTENING_IND from '@salesforce/label/c.Core_MDF_SFTNameShortening_Ind';
import getRecordStatus from '@salesforce/apex/Core_MDF_FileRepository.getActivityStatusById';
import getRelatedMDFDocumentsByRecord from '@salesforce/apex/Core_MDF_FileRepository.getRelatedMDFDocumentsByRecord';
import insertMDFDocuments from '@salesforce/apex/Core_MDF_FileRepository.insertMDFDocuments';
import deleteMDFDocument from '@salesforce/apex/Core_MDF_FileRepository.deleteMDFDocument';
import hasExternalActivitySubmitter from '@salesforce/customPermission/Core_MDF_CCP_External_IPA_Activity_Manager';
import hasIPAAccountManager from '@salesforce/customPermission/Core_MDF_CCP_Internal_IPA_Acct_Mgr';
import hasClaimCaseReviewer from '@salesforce/customPermission/Core_MDF_CCP_Internal_Claim_Case_Reviewer';
import hasClaimCaseReviewerManager from '@salesforce/customPermission/Core_MDF_CCP_Internal_Claim_Case_Reviewer_Manager';
import hasExternalIPAClaimSubmitter from '@salesforce/customPermission/Core_MDF_IPAClaimSubmitter';
import mdfFileRepository from '@salesforce/label/c.Core_MDF_File_Repository';
import DocumentUploadDisabledMessage from '@salesforce/label/c.Core_MDF_DocumentUploadDisabledMessage';
import NoMDFDocumentsUploadedMessage from '@salesforce/label/c.Core_MDF_NoMDFDocumentsUploadedMessage';
import fileName from '@salesforce/label/c.Core_MDF_File_Name_Localized';
import fileType from '@salesforce/label/c.Core_MDF_File_Type_Localized';
import uploadedDate from '@salesforce/label/c.Core_MDF_Uploaded_Date_Localized';
import viewAll from '@salesforce/label/c.Core_MDF_View_All';
import deleteButton from '@salesforce/label/c.Core_MDF_Delete_Localized';
import successLabel from '@salesforce/label/c.Core_MDF_Success';
import errorLabel from '@salesforce/label/c.Core_MDF_Error';
import fileUploadSuccessMessage from '@salesforce/label/c.Core_MDF_FileUploadSuccessMessage';
import fileDeleteSuccessMessage from '@salesforce/label/c.Core_MDF_FileDeleteSuccessMessage';

export default class Core_MDF_FileRepository extends LightningElement {
    @api recordId;
    @api view;
    mdfFileRepository = mdfFileRepository;
    DocumentUploadDisabledMessage = DocumentUploadDisabledMessage;
    NoMDFDocumentsUploadedMessage = NoMDFDocumentsUploadedMessage;
    fileName = fileName;
    fileType = fileType;
    uploadedDate = uploadedDate;
    deleteButton = deleteButton;
    viewAll = viewAll;
    successLabel = successLabel;
    errorLabel = errorLabel;
    fileUploadSuccessMessage = fileUploadSuccessMessage;
    fileDeleteSuccessMessage = fileDeleteSuccessMessage;

    @track columnsDetailPage = [];
    @track columnsModal = [
        {
            label: this.fileName, fieldName: 'documentDownloadURL', type: 'url', typeAttributes: {
                label: { fieldName: 'title' },
                target: '_blank'
            }
        },
        { label: this.fileType, fieldName: 'fileType' },
        { label: this.uploadedDate, fieldName: 'createdDate', type: 'date' },
        ...(this.hasFileManageAccess ? [{
            type: 'action',
            typeAttributes: {
                rowActions: [
                    { label: this.deleteButton, name: 'delete' }
                ]
            }
        }] : [])
    ];
    @track files = [];
    error = '';
    uploadAllowed = true;
    wiredMDFDocumentsResult;
    showNoRelatedFilesMessage = false;
    mdfDocumentsToInsertList = [];
    isModalOpen = false;

    get hasFileManageAccess() {
        return hasExternalActivitySubmitter || hasIPAAccountManager || hasClaimCaseReviewer || hasClaimCaseReviewerManager || hasExternalIPAClaimSubmitter;
    }

    renderedCallback() {
        if (!this.columnsDetailPage.length) {
            const wrapper = this.template.querySelector('.table-wrapper');
            if (!wrapper) return;

            const tableWidth = wrapper.offsetWidth;
            this.columnsDetailPage = [
                {
                    label: this.fileName, fieldName: 'documentDownloadURL', type: 'url', typeAttributes: {
                        label: { fieldName: 'title' },
                        target: '_blank'
                    }, initialWidth: Math.floor(tableWidth * (this.hasFileManageAccess ? 0.5 : 0.6))
                },
                { label: this.fileType, fieldName: 'fileType', initialWidth: Math.floor(tableWidth * (this.hasFileManageAccess ? 0.2 : 0.18)) },
                { label: this.uploadedDate, fieldName: 'createdDate', type: 'date', initialWidth: Math.floor(tableWidth * 0.2) },
                ...(this.hasFileManageAccess ? [{
                    type: 'action', initialWidth: Math.floor(tableWidth * 0.1),
                    typeAttributes: {
                        rowActions: [
                            { label: this.deleteButton, name: 'delete' }
                        ]
                    }
                }] : [])
            ];
        }
    }

    get showViewAllButton() {
        return this.files.length > 5;
    }

    get tableContainerClass() {
        return !this.showViewAllButton ? 'table-wrapper' : 'table-container table-wrapper';
    }

    @wire(getRelatedMDFDocumentsByRecord, { recordId: '$recordId' })
    wiredMDFDocuments(result) {
        this.wiredMDFDocumentsResult = result;
        if (result.data) {
            this.files = result.data;
            this.showNoRelatedFilesMessage = this.files.length == 0;
        }
    }

    @wire(getRecordStatus, { recordId: '$recordId' })
    wiredStatus({ data }) {
        if (data) {
            this.uploadAllowed = data !== 'Cancelled';
        }
    }

    handleUploadFinished(event) {
        this.prepareMDFDocumentRecords(event);
        refreshApex(this.wiredMDFDocumentsResult);
    }

    prepareMDFDocumentRecords(event) {
        const uploadedFiles = event.detail.files;

        uploadedFiles.forEach(uploadedFile => {
            let uploadedFileName = uploadedFile.name;
            let encodedUploadedFileNameWithExt = uploadedFileName;
            let reduction = 0;

            if (CORE_MDF_SFTNAME_SHORTENING_IND == 'True') {
                if (uploadedFileName.includes('%')) {
                    uploadedFileName = uploadedFileName.replaceAll('%', 'pct');
                }

                const extPosition = uploadedFileName.lastIndexOf('.');
                const fileExt = uploadedFileName.substring(extPosition);
                let uploadedFileNameWithoutExt =
                    uploadedFileName.substring(0, extPosition);

                let encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);

                encodedUploadedFileNameWithExt = encodeURI(
                    uploadedFileName.replace(/[{}|\\^"~[\]`]/g, "_")
                );

                while (encodedUploadedFileNameWithExt.length > 130) {
                    uploadedFileNameWithoutExt =
                        uploadedFileNameWithoutExt.substring(0, 60 - reduction);

                    encodedUploadedFileName = encodeURI(uploadedFileNameWithoutExt);
                    encodedUploadedFileNameWithExt = encodeURI(uploadedFileNameWithoutExt + fileExt);

                    reduction += 5;
                }
            }

            this.mdfDocumentsToInsertList.push({
                sobjectType: 'Core_MDF_Documents__c',
                Core_MDF_Document_Title_txt__c: uploadedFile.name,
                Core_MDF_Download_Document_Title_txt__c: decodeURI(encodedUploadedFileNameWithExt),
                Core_MDF_Encoded_Document_Title_txt__c: encodedUploadedFileNameWithExt,
                Core_MDF_Document_Id__c: uploadedFile.documentId,
                Core_MDF_App_Document_Types_nm__c: 'Not Applicable',
                Core_MDF_App_File_Id__c: this.generateAppId(),
                Core_MDF_ContentVersion_Id__c: uploadedFile.contentVersionId,
                Core_MDF_Activity_id__c: this.recordId
            });
        });

        insertMDFDocuments({ mdfDocuments: this.mdfDocumentsToInsertList })
            .then(() => {
                this.mdfDocumentsToInsertList = [];
                this.showToast(
                    this.successLabel,
                    this.fileUploadSuccessMessage,
                    'success'
                );
            })
            .catch(error => {
                this.mdfDocumentsToInsertList = [];
                this.showToast(
                    this.errorLabel,
                    error,
                    'error',
                    'sticky'
                );
            });
    }

    handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'delete') {
            deleteMDFDocument({ contentDocumentId: row.contentDocumentId })
                .then(
                    () => {
                        this.showToast(
                            this.successLabel,
                            this.fileDeleteSuccessMessage,
                            'success'
                        );
                        refreshApex(this.wiredMDFDocumentsResult);
                    }
                )
                .catch(error => {
                    this.showToast(
                        this.errorLabel,
                        error,
                        'error',
                        'sticky'
                    );
                    console.error('Error deleting Document', error);
                });
        }
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    generateAppId() {
        const key = this.generateAESKey();
        const hexKey = this.byteArrayToHex(key);
        const timestamp = this.formatDateTime(new Date());

        let guid = hexKey + timestamp;

        guid = guid.replace(/-/g, '').replace(/:/g, '');

        return this.deleteWhitespace(guid);
    }

    generateAESKey() {
        // Generate a random 128-bit (16 bytes) key
        const array = new Uint8Array(16);
        window.crypto.getRandomValues(array);
        return array;
    }

    byteArrayToHex(byteArray) {
        return Array.from(byteArray, byte =>
            ('0' + (byte & 0xFF).toString(16)).slice(-2)
        ).join('');
    }

    formatDateTime(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        const hours = String(date.getHours()).padStart(2, '0');
        const minutes = String(date.getMinutes()).padStart(2, '0');
        const seconds = String(date.getSeconds()).padStart(2, '0');

        return `${year}${month}${day} ${hours}${minutes}${seconds}`;
    }

    deleteWhitespace(str) {
        return str.replace(/\s+/g, '');
    }

    showToast(title, message, variant = 'info', mode = 'dismissable') {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant,
                mode
            })
        );
    }
}