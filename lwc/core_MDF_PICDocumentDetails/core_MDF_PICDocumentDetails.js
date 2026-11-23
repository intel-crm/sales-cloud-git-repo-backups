import { LightningElement, api, wire, track } from 'lwc';
import fetchAuditDocuments from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchAuditDocuments';
import fetchQuestionRecords from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchQuestionRecords';
import reviewDataInsertion from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.reviewDataInsertion';
import fetchClaimRecordData from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchClaimRecordData';
import getClaimAttributesFromMetaData from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.getClaimAttributesFromMetaData';
import fetchAuditDocumentList from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchAuditDocumentList';
import fetchTactics from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchTactics';
import fetchAIResponse from '@salesforce/apex/Core_MDF_PICReviewScreen_Controller.fetchAIResponse';  //Sham
import fetchClaimDocAndPICReviewDetails from '@salesforce/apex/Core_MDF_AI_Integration_Outbound.fetchClaimDocAndPICReviewDetails';//Sham
import Id from '@salesforce/user/Id';
import radioYes from '@salesforce/label/c.Core_MDF_DQYes';
import radioNo from '@salesforce/label/c.Core_MDF_DQNo';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import Core_MDF_PICRadioGroupCSS from '@salesforce/resourceUrl/Core_MDF_PICRadioGroupCSS';
import applicationError from '@salesforce/label/c.Core_MDF_ApplicationErrorMessage';
import claimDocumentTypes from '@salesforce/label/c.Core_MDF_Claim_Document_Types';
import claim from '@salesforce/label/c.Core_MDF_Claim';
import claimReviewDocuments from '@salesforce/label/c.Core_MDF_Claim_Review_Documents';
import fileType from '@salesforce/label/c.Core_MDF_File_Type';
import fileName from '@salesforce/label/c.Core_MDF_File_Name';
import uploadedDate from '@salesforce/label/c.Core_MDF_Uploaded_Date';
import issues from '@salesforce/label/c.Core_MDF_Issues';
import filesAffected from '@salesforce/label/c.Core_MDF_Files_Affected';
import noClaimReviewDocuments from '@salesforce/label/c.Core_MDF_No_Claim_Review_Documents';
import noIssues from '@salesforce/label/c.Core_MDF_No_Issues_Found';
import response from '@salesforce/label/c.Core_MDF_Response';
import applicationErrorText from '@salesforce/label/c.Core_MDF_LWC_ApplicationErrorMsgTitle';
import errorMessageOnCompletePICReview from '@salesforce/label/c.Core_MDF_PIC_Error_Message_On_Completion';
import picReviewStatus from '@salesforce/label/c.Core_MDF_PIC_Review_Status';
import picReviewProcess from '@salesforce/label/c.Core_MDF_PIC_Review_Process';
import completePICReview from '@salesforce/label/c.Core_MDF_Complete_PIC_Review';
import startPICReview from '@salesforce/label/c.Core_MDF_Start_PIC_Review';
import picInternalComments from '@salesforce/label/c.Core_MDF_PIC_Internal_Comments';
import picInternalCommentsplaceholder from '@salesforce/label/c.Core_MDF_PlC_Internal_Comments_Placeholder';
import recommendForClaimReview from '@salesforce/label/c.Core_MDF_Recommend_For_Claim_Review';
import downloadAllDocuments from '@salesforce/label/c.Core_MDF_Download_All_Document_Button_Label';
import confirmationPopupMessage1 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Message1';
import confirmationPopupMessage2 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Message2';
import confirmationPopupMessage3 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Message3';
import confirmationPopupLabel1 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Label1';
import confirmationPopupLabel2 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Label2';
import confirmationPopupLabel3 from '@salesforce/label/c.Core_MDF_PICReviewScreen_ConfirmationPopup_Label3';
import claimStatusPICPending from '@salesforce/label/c.Core_MDF_Claim_Status_PIC_Pending';
import claimStatusPaidAndPICPending from '@salesforce/label/c.Core_MDF_Claim_Status_Paid_and_PIC_Pending';
import locale from '@salesforce/i18n/locale';
import timeZone from '@salesforce/i18n/timeZone';
import ipaProgram from '@salesforce/label/c.Core_MDF_IPA_Technical_program_name';  //Roshan - added for IPA OutcomeBased claims

export default class Core_MDF_PICDocumentDetails extends NavigationMixin(LightningElement) {
    auditDocuments;
    error;
    @track selectedAndUnselectedDocs;
    @track questionMetadata;
    claimId;
    @api claimDetails;
    internalComments;
    startTime;
    endTime;
    userId = Id;
    label = {
        radioYes, radioNo, applicationError, claimDocumentTypes, claim, claimReviewDocuments, fileType, fileName, uploadedDate, issues, response, filesAffected, applicationErrorText, noIssues, noClaimReviewDocuments, errorMessageOnCompletePICReview, picReviewStatus, picReviewProcess,
        completePICReview, startPICReview, picInternalComments, picInternalCommentsplaceholder, recommendForClaimReview, downloadAllDocuments, confirmationPopupMessage1, confirmationPopupMessage2, confirmationPopupMessage3, confirmationPopupLabel1, confirmationPopupLabel2, confirmationPopupLabel3,
        claimStatusPICPending, ipaProgram, claimStatusPaidAndPICPending,  //Roshan - added for IPA OutcomeBased claims - ipaProgram
    };
    @api claimLabel = this.label.claim;
    disableResponse = true;
    isRecommendedForAudit = false;
    isReviewFeedbackFailed = false;
    claimDetailOnStartReview;
    claimDetailOnCompleteReview;
    claimAttributes;
    editedClaimAttributes = [];
    enableConfirmationModalPopup;
    claimFields;
    editedClaimAttributeLabels = [];
    auditDocumentResponse;
    disableCompleteReview = true;
    contentDocumentIds = [];
    showSpinner = false;
    hasAuditDocuments = false;
    hasQuestionMetadataRecords = false;
    disableStartReview = false;
    auditDocumentsList = [];
    isClaimStatusChanged = false;
    claimReviewerName;
    auditDocumentsListonStartReview;
    auditDocumentsListonCompleteReview;
    newlyAddedDocuments = [];
    managedExistingDocuments = [];
    picReviewWrapper;
    objectInfo;
    subQuestionMetadata;
    mapOfParentQtnToSubQtns = new Map();
    mapOfSubQtnToParQtn = new Map();
    mapOfSubQtnToResponse = new Map();
    currentlySelectedQtn = '';
    questionNameWithFiles =[];//to store qtns which needts to have file selection
    isCheckedTrue = '' ;
    isOutcomeBasedClaim = false;  //Roshan - added for IPA OutcomeBased claims
    tacticsOptions = [];  //Roshan - Tactics
    isOutcomeBasedComment = false;//Swati
    //Roshan
    campPurposeValuesOnStartReview;
    campPurposeValuesOnCompleteReview;
    campPurposeChanged = false;
    tacticsMetricsValues = {};
    tacticsMetricsChanged = false;
    tacticsSpendingValues = {};
    tacticsSpendingChanged = false;

    //Sham -AI generated Response
    aiResponseRcvd = false;
    disableGenAIBtn = true;
    aiDefaultComment = 'AI comment not available.';
    inProgressErrorMsg = 'AI Validation in progress. Please check back shortly or continue review.';
    failedErrorMsg = 'AI Response not available. Please continue with review.';
    outcomeBasedMsg = 'AI based recommendations not available for outcome-based claims.';
    aiErrorMsg = '';
    latestAIPICReviewId;
    claimOutcomeBasedInd=false;
    @track claimIdToRecordMap = new Map();
    @track claimIdToReviewToCDBLogRec = new Map();
    aiResponseMetadata =[];


    //To fetch the audit documents from apex controller
    @wire(fetchAuditDocuments, { claimId: '$claimId' })
    wiredAuditDocuments(response) {
        let auditDocumentObject = [];
        this.auditDocumentsList = [];
        this.contentDocumentIds = [];
        this.auditDocumentResponse = response;
        const data = response.data;
        if (data && data.length > 0) {
            this.auditDocuments = data;
            this.showSpinner = true;
            this.hasAuditDocuments = true;
            this.auditDocuments.map(auditdoc => {
                let tempAuditDocs = [];
                if (auditdoc.Core_MDF_Document_Types__c) {
                    const docUploadedDate = new Date(auditdoc.CreatedDate).toLocaleString(locale, { year: 'numeric', month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric', second: 'numeric', timeZone: timeZone})

                    this.auditDocumentsList.push({ documentId: auditdoc.Core_MDF_Document_Id__c, documentName: auditdoc.Core_MDF_Document_Title__c, uploadedDate: docUploadedDate });
                    this.contentDocumentIds.push(auditdoc.Core_MDF_Document_Id__c);
                    if (auditdoc.Core_MDF_Document_Types__c.includes(';')) {
                        tempAuditDocs = auditdoc.Core_MDF_Document_Types__c.split(';');
                    } else {
                        tempAuditDocs.push(auditdoc.Core_MDF_Document_Types__c);
                    }
                    tempAuditDocs && tempAuditDocs.map(docType => {
                        let index = auditDocumentObject.findIndex(element => element.fileType == docType);
                        if (index != -1) {
                            auditDocumentObject[index].documentDetails.push({ fileName: auditdoc.Core_MDF_Int_Document_Name__c, uploadedDate: docUploadedDate, documentName:  auditdoc.Core_MDF_Document_Title__c });
                            auditDocumentObject[index].uploadedDate = docUploadedDate;
                        } else if (index == -1) {
                            auditDocumentObject.push({ fileType: docType, uploadedDate: docUploadedDate, documentDetails: [{ fileName: auditdoc.Core_MDF_Int_Document_Name__c, uploadedDate: docUploadedDate, documentName:  auditdoc.Core_MDF_Document_Title__c }] });
                        }
                    });
                }
            });
             if(auditDocumentObject.length > 0 && this.auditDocumentsList.length > 0) {
                auditDocumentObject.map(docObj => {
                    docObj.rowSpan = docObj.documentDetails.length + 1;
                });
                this.auditDocuments = [...auditDocumentObject];
                // sort the files affected dropdown values in aplhabetical order and for the duplicate filenames sort based on uploadeddate
                this.auditDocumentsList.sort((a, b) => (a.documentName.toLowerCase() > b.documentName.toLowerCase()) ? 1 : (a.documentName.toLowerCase() === b.documentName.toLowerCase()) ? ((b.uploadedDate > a.uploadedDate) ? 1 : -1) : -1 );
                
                // sort the file types - POA, POC and POE - may target in future as per feedback
                //this.auditDocuments.sort((a, b) => (a.fileType.toLowerCase() > b.fileType.toLowerCase()) ? 1 : -1 );

                 // sort the filenames in aplhabetical order and for the duplicate filenames sort based on uploadeddate - claim review documents section of pic review screen
                this.auditDocuments.map(auditdoc => {
                    auditdoc.documentDetails.sort((a, b) => (a.documentName.toLowerCase() > b.documentName.toLowerCase()) ? 1 : (a.documentName.toLowerCase() === b.documentName.toLowerCase()) ? ((b.uploadedDate > a.uploadedDate) ? 1 : -1) : -1 );
                });

                this.getClaimAttributes();
                this.setAIResponsefromResult();

            }
        } else if (data && data.length === 0) {
            this.showSpinner = false;
            this.hasAuditDocuments = false;
            this.hideSpinner(true);
        }

    }

    //To get the label for claim fields
    @wire(getObjectInfo, { objectApiName: 'PartnerFundClaim' })
    wiredClaimObjectDetails({ error, data }) {
        if (data) {
            this.objectInfo = data.fields;
        } else if (error) {
            this.showSpinner = false;
            this.hideSpinner(true);
            this.displayServerExceptionMessage(this.label.applicationError, false);
        }
    }

    connectedCallback() {
        this.claimId = this.claimDetails.Id;
        //this.isOutcomeBasedClaim = this.claimDetails.Core_MDF_Program__c === this.label.ipaProgram && this.claimDetails.Core_MDF_Campaign_Id__r.Core_MDF_CampOutcomeOpt_In_Ind__c;
        this.isOutcomeBasedClaim = this.claimDetails.Core_MDF_Program__c === this.label.ipaProgram && this.claimDetails.Core_MDF_OutcomeBased_Ind__c;  //Roshan
        this.claimOutcomeBasedInd = this.claimDetails.Core_MDF_OutcomeBased_Ind__c;//Added By Sham - AI MDF POP
        if (this.isOutcomeBasedClaim) {
            this.loadTactics();
        }
        
        loadStyle(this, Core_MDF_PICRadioGroupCSS);//To load css from static resource
    }

    handleCommentChange(event) {
        const qnToUpdate = this.questionMetadata.find(qnMdt => qnMdt.name === event.target.name);
        const subQnToUpdate = (this.subQuestionMetadata || []).find(qn => qn.name === event.target.name);
        if (qnToUpdate) {
            qnToUpdate.comment = event.target.value;
        }
        if (subQnToUpdate) {
            subQnToUpdate.comment = event.target.value;//Swati
        }
    }
    fetchSelectedTacticValues(event) {
        
        const tactics = (JSON.parse(JSON.stringify(event.detail.valueObj))|| [])
                            .filter(t => t.selected)
                            .map(t => t.value);
        
        const qtnCode = event.target.id.slice(0, 7);
        (this.subQuestionMetadata || []).map((qnMetadata, qnIndex) => {  
            if (qnMetadata.name === qtnCode) {
                this.subQuestionMetadata[qnIndex].tactic = tactics;
            }
        });
        this.questionMetadata = this.questionMetadata.map(qn =>
            qn.name === qtnCode ? { ...qn, tactic: tactics } : qn
        );
    }

    // Roshan
    loadTactics() {
        fetchTactics({ claimId: this.claimId })
        .then(data => {
            const tacticNames = Object.keys(data);
            this.tacticsOptions = tacticNames.map(tactic => ({
                label: tactic,
                value: tactic
            }));
        })
        .catch(error => {
        });
    }

    //returns option for radio group
    get responseOptions() {
        return [
            { label: this.label.radioYes, value: this.label.radioYes },
            { label: this.label.radioNo, value: this.label.radioNo },
        ];
    }

    /**
     * To fetch the affected documents
     * @param {*} event - event contains selected documents from multi select picklist
     * @param {*} selectedFiles - selectedFiles contains internally unselected documents
     */
    fetchSelectedValues(event, selectedFiles) {
        if (selectedFiles != undefined) {
            this.selectedAndUnselectedDocs = selectedFiles;
        } else {
            this.selectedAndUnselectedDocs = JSON.parse(JSON.stringify(event.detail.valueObj));
        }
        const [selectedAndUnselectedDocs, ...remainingSelectedValues] = this.selectedAndUnselectedDocs;
        let questionCode = selectedAndUnselectedDocs.questionCode;
        (this.subQuestionMetadata || []).map((qnMetadata, qnIndex) => {  
            if (qnMetadata.name === questionCode) {
                this.subQuestionMetadata[qnIndex].fileNames = this.selectedAndUnselectedDocs;
            }
        });
        this.questionMetadata.map((qnMetadata, qnIndex) => {
            if (qnMetadata.name === questionCode) {
                this.questionMetadata[qnIndex].fileNames = this.selectedAndUnselectedDocs;
            }
        });
    }

    //To disable the picklist on load
    disablePicklistOnLoad() {
        this.template.querySelectorAll(".multiSelectFiles").forEach(element => {
            element.clear();
            element.disablePickilstMethod();
            element.isValid();
        });
    }

    processMetadata(metadata) {
        let serialNumber =1;
        let duplicateIndexes = [];
        let questionsTableData = [];
        let processedMetadata = metadata ;
        const documentTypesList = this.label.claimDocumentTypes.split(';');
        try {
        if (processedMetadata.length > 0) {  
        processedMetadata.map(qnMdt => {

                            let questionData = {};
                            questionData.comment = '';  //Roshan - added for IPA OutcomeBased claims
                            questionData.tactic = []; //Swati-Tactic
                            questionData.fileType = qnMdt.Core_MDF_Question_File_Type_nm__c;
                            questionData.name = qnMdt.Name;
                            questionData.questionEnglish = qnMdt.Core_MDF_Question_en_US_txt__c;
                            questionData.response = '';
                            questionData.id = qnMdt.Id;
                            questionData.subRows= '';
                            questionData.cssClassName = qnMdt.Core_MDF_Third_Party_Ind__c ? 'issueWithBackground' : 'issueWithOutBackground';
                            questionData.displayFileSelOnParent = false;

                            //Sham - AI Generated Response
                    questionData.hasAIQnResponse = false;
                    questionData.aiQnComment = this.aiDefaultComment;
                    if (this.aiResponseRcvd) {
                        const aiResponse = this.aiResponseMetadata.find(response => response.aiQnId === questionData.id);

                        if (aiResponse) {
                            const { aiQnResponse, aiQnComment } = aiResponse;
                            // Always copy comment
                            questionData.aiQnComment = aiQnComment;
                            // Normalize the response to lower case
                            const normResponse = (aiQnResponse ?? '').toString().trim().toLowerCase();
                            if (qnMdt.Core_MDF_Sub_Question_Ind__c === false) {
                                // Main question
                                const isYes = normResponse === 'yes';
                                const isNo = normResponse === 'no';

                                //assign Response value Yes/No
                                questionData.aiQnResponse = (isYes) ? 'Yes' : (isNo) ? 'No' : '';
                                questionData.hasAIQnResponse = (isYes || isNo);
                            } else {
                                // Sub-question
                                //get the parent's response
                                const parentQnResponse = this.aiResponseMetadata.find(response => response.aiQnId === qnMdt.Core_MDF_Parent_Question__c);
                                const parentVal = (parentQnResponse?.aiQnResponse ?? '').toString().trim().toLowerCase();
                                //assign Response value  True/False
                                questionData.aiQnResponse = (normResponse === 'true') ? 'True' : (normResponse === '') ? 'False' : '';
                                //set hasAIQnResponse to true based on True/False and parent value.
                                if ((questionData.aiQnResponse == 'True' || questionData.aiQnResponse == 'False') && (parentVal === 'no')) {
                                    questionData.hasAIQnResponse = true;
                                }
                            }

                            // CSS Class mapping
                            questionData.aiQnResponseClass = questionData.aiQnResponse
                                ? this.getAIResponseClass(questionData.aiQnResponse)
                                : '';
                        }
                    }
    
                    if(qnMdt.Core_MDF_Sub_Question_Ind__c ===true){
                                questionData.subRows= '';
                            questionData.parentQueCode = qnMdt.Core_MDF_Parent_Question__r.Name;
                                this.mapOfSubQtnToResponse.set(qnMdt.Name,'');
                                if(qnMdt.Core_MDF_Parent_Question__r.Name != null || qnMdt.Core_MDF_Parent_Question__r.Name != ''){
                                    if (this.mapOfParentQtnToSubQtns.has(qnMdt.Core_MDF_Parent_Question__r.Name)) {
                                        this.mapOfParentQtnToSubQtns.get(qnMdt.Core_MDF_Parent_Question__r.Name).push(questionData);
                                    }else{
                                        this.mapOfParentQtnToSubQtns.set(qnMdt.Core_MDF_Parent_Question__r.Name,[questionData]);
                                    }
                                }
                                this.mapOfSubQtnToParQtn.set(questionData.name,qnMdt.Core_MDF_Parent_Question__r.Name);
                            }else{
                                questionData.serialNumber = serialNumber++;
                                if(!this.mapOfParentQtnToSubQtns.has(qnMdt.Name)){
                                    questionData.displayFileSelOnParent = true; 
                                }
                            }
                                let fileTitleTempArray = [];
                                let distinctDuplicateIndexes;
                                this.auditDocumentsList.map(doc => {

                                    let duplicateFileIndex = fileTitleTempArray.findIndex(element => element.value == doc.documentName);
                                    if (duplicateFileIndex == -1) {
                                    fileTitleTempArray.push({ selected: false, value: doc.documentName, label: doc.documentName, originalFileName: doc.documentName, questionCode: questionData.name, parentQueCode: questionData.parentQueCode });
                                    } else {
                                        duplicateIndexes.push(duplicateFileIndex); //to store the index of duplicate element i.e the first reference
                                        const documentNameWithDateTime = doc.documentName + ' ' + '(' + doc.uploadedDate + ')';
                                    fileTitleTempArray.push({ selected: false, value: documentNameWithDateTime, label: documentNameWithDateTime, originalFileName: doc.documentName, questionCode: questionData.name, parentQueCode: questionData.parentQueCode })
                                    }
                                    if(qnMdt.Core_MDF_Sub_Question_Ind__c ===false){
                                        this.questionNameWithFiles.push(questionData.name);
                                        
                                    }
                                });
                                //update the label and value of duplicate document based on the duplicate indexes
                                distinctDuplicateIndexes = Array.from(new Set(duplicateIndexes));
                                distinctDuplicateIndexes && distinctDuplicateIndexes.map(duplicateIndex => {
                                    fileTitleTempArray[duplicateIndex].label = fileTitleTempArray[duplicateIndex].label + ' ' + '(' + this.auditDocumentsList[duplicateIndex].uploadedDate + ')';
                                    fileTitleTempArray[duplicateIndex].value = fileTitleTempArray[duplicateIndex].value + ' ' + '(' + this.auditDocumentsList[duplicateIndex].uploadedDate + ')';

                                })
                                questionData.fileNames = fileTitleTempArray;
                            
                            questionsTableData.push(questionData);
                        });
                        processedMetadata = [...questionsTableData];

        // Return the processed metadata
        return processedMetadata;
        }
        } catch (error) {
            // Optionally, show an error message to the user
            this.showErrorMessage(error.message);
        }
    }

    

    //To fetch the question object records from apex controller
    async getMetadataRecords() {
                                       
        let questionsTableData = [];
        let subQuestionsTableData = [];
        this.questionMetadata = [];
        let serialNumber =1;
        let duplicateIndexes = [];
        const documentTypesList = this.label.claimDocumentTypes.split(';');
        await fetchQuestionRecords({ claimId: this.claimId })
            .then(response => {
                if (response.length > 0) {
                    let qnMetaData;
                    let thirdPartyMetaData;
                      let nexMetaData;
                    //check to retain/remove third party questions
                    let subQnMetaData = response.filter(mdt => mdt.Core_MDF_Sub_Question_Ind__c === true);
                    this.subQuestionMetadata = this.processMetadata(subQnMetaData);
                    
                    
                    response = response.filter(mdt => mdt.Core_MDF_Sub_Question_Ind__c === false);
                    if (this.claimDetails.Core_MDF_3rd_Party_POP_Doc_Required_Ind__c) {
                        qnMetaData = response;
                    } else {
                        const metaData = response;
                        const questionsToRemove = metaData.filter(mdt => mdt.Core_MDF_Question_File_Type_nm__c === 'Third Party');
                        thirdPartyMetaData = [...metaData]
                        if (questionsToRemove.length != qnMetaData) {
                            questionsToRemove && questionsToRemove.map(qnRemove => {
                                let qnToRemoveIndex = thirdPartyMetaData.findIndex(thirdPartyMdt => thirdPartyMdt.Core_MDF_Question_File_Type_nm__c == qnRemove.Core_MDF_Question_File_Type_nm__c);
                                thirdPartyMetaData.splice(qnToRemoveIndex, 1);
                            });
                        } else {
                            this.hasQuestionMetadataRecords = false;
                            this.showSpinner = false;
                            this.hideSpinner(true);
                        }
                        qnMetaData = thirdPartyMetaData;
                    }

                    //check to retain/remove NEX questions
                    if (this.claimDetails.Request.Core_MDF_NEX_Ind__c) {
                        qnMetaData = qnMetaData;
                    } else {
                        const metaData = qnMetaData;
                        const nexQuestionsToRemove = metaData.filter(mdt => mdt.Core_MDF_Question_File_Type_nm__c === 'NEX');
                        nexMetaData = [...metaData]
                        if (nexQuestionsToRemove.length != qnMetaData) {
                            nexQuestionsToRemove && nexQuestionsToRemove.map(qnRemove => {
                                let nexQnToRemoveIndex = nexMetaData.findIndex(nexMdt => nexMdt.Core_MDF_Question_File_Type_nm__c == qnRemove.Core_MDF_Question_File_Type_nm__c);
                                nexMetaData.splice(nexQnToRemoveIndex, 1);
                            });
                        } else {
                            this.hasQuestionMetadataRecords = false;
                            this.showSpinner = false;
                            this.hideSpinner(true);
                        }
                        qnMetaData = nexMetaData;
                    }

                    // add the filenames and default response to track the questions reviewed
                    if (qnMetaData.length > 0) {
                        this.hasQuestionMetadataRecords = true;
                        
                        
                        this.questionMetadata = this.processMetadata(qnMetaData);
                    }
                    this.showSpinner = false;
                    this.hideSpinner(true);
                } else {
                    this.hasQuestionMetadataRecords = false;
                    this.showSpinner = false;
                    this.hideSpinner(true);
                }
            }).catch(error => {
                this.hideSpinner(true);
                this.displayServerExceptionMessage(this.label.applicationError, false);
            });

        //to disable dropdown on load
        this.disablePicklistOnLoad();
                                                   
    }

    /**
     * To track the response selected by pic reviewer
     * @param {*} event - event contains target question details
     */
    handleCheckboxChange(event) {
        event.stopPropagation();
        const name = event.target.name;
        const isChecked  = event.target.checked;
        this.selectedRowId = event.target.value;
        
    let generalQnIndex = this.subQuestionMetadata.findIndex(qn => (qn.name === name));
        let qname = this.subQuestionMetadata[generalQnIndex].name;
        if (isChecked === true) {
            
            this.subQuestionMetadata[generalQnIndex].response = true;
            this.mapOfSubQtnToResponse.set(qname,true);
            this.isCheckedTrue = isChecked;
            this.isOutcomeBasedClaim ? this.isOutcomeBasedComment = true : null; //Swati
        }else{
            
            this.subQuestionMetadata[generalQnIndex].response = '';
            this.mapOfSubQtnToResponse.set(qname,'');
            this.isCheckedTrue = '';
            this.isOutcomeBasedClaim ? this.isOutcomeBasedComment = false : null; //Swati
            this.isOutcomeBasedClaim ? this.subQuestionMetadata[generalQnIndex].comment ='' : null; //Swati
        }
        this.template.querySelectorAll(".multiSelectFiles").forEach(element => {
            const elementName = element.values[0].questionCode;
             const qtnCode = element.id.slice(0, 7);//Swati-added for tactic
            if (isChecked === true && (elementName === qname || qtnCode === qname)) {
                element.enablePickilstMethod();

            } else if (isChecked === false && (elementName === qname || qtnCode === qname)) {
                element.clear();
                element.disablePickilstMethod(true);
                element.isValid();  
                let tempSelectedFile = [];
                this.subQuestionMetadata.map((qnMetadata, qnIndex) => {
                    if (qnMetadata.name === qname) {
                        this.subQuestionMetadata[qnIndex].fileNames.map(file => {
                            file.selected = false;
                            tempSelectedFile.push(file);
                        });
                    }
                });
                this.selectedAndUnselectedDocs = [...tempSelectedFile];
                this.fetchSelectedValues(undefined, this.selectedAndUnselectedDocs);
            }
        })

    }

    handleResponseChange(event) {
        event.stopPropagation();
        const name = event.target.name;
        const eventValue = event.target.value.toLowerCase();
        const responseAsYes = this.label.radioYes.toLowerCase();
        const responeAsNo = this.label.radioNo.toLowerCase();
        //Set the question response based on reviewer's selection
        let generalQnIndex = this.questionMetadata.findIndex(qn => (qn.name === name));
        if (eventValue === responseAsYes) {
            
            this.questionMetadata[generalQnIndex].response = this.label.radioYes;
            this.questionMetadata[generalQnIndex].displaySubQue = false;
            this.questionMetadata[generalQnIndex].comment = '';  //Roshan - added for IPA OutcomeBased claims
            this.questionMetadata[generalQnIndex].tactic = []; 
            this.isCheckedTrue = '';
            this.isOutcomeBasedClaim ? this.questionMetadata[generalQnIndex].isOutcomeBasedComment = false : null;
            if (this.questionMetadata[generalQnIndex].subRows != undefined && this.questionMetadata[generalQnIndex].subRows != '') {
                let mainQntoSubQnMapCopy = this.mapOfParentQtnToSubQtns;
                let relatedSubQns = new Array();
                relatedSubQns = mainQntoSubQnMapCopy.get(name);
                let subQnIdToSubQnMap = new Map();
                if(relatedSubQns.length > 0) {
                    relatedSubQns.forEach(subQn => {
                        subQnIdToSubQnMap.set(subQn.name, subQn);
                    })
                }
                //Comments
                this.isOutcomeBasedClaim ? this.isOutcomeBasedComment = false : null;
                
                this.template.querySelectorAll(".multiSelectFiles").forEach(element => {
                    if (element.values[0].parentQueCode === name) {
                        element.clear();
                        element.disablePickilstMethod(true);
                        let subQuestionCode = subQnIdToSubQnMap.get(element.values[0].questionCode).name;
                        let indexFromOriginalSubQnMtd = this.subQuestionMetadata.findIndex(subQn => subQn.name === subQuestionCode);
                        if (indexFromOriginalSubQnMtd !== -1) {
                            let tempSelectedFile = [];
                            this.subQuestionMetadata[indexFromOriginalSubQnMtd].fileNames.forEach(file => {
                                file.selected = false;
                                tempSelectedFile.push(file);
                            });
                            this.subQuestionMetadata[indexFromOriginalSubQnMtd].response = '';
                            this.isOutcomeBasedClaim ? this.subQuestionMetadata[indexFromOriginalSubQnMtd].comment = '' : null;//comment
                            this.selectedAndUnselectedDocs = [...tempSelectedFile];
                            this.fetchSelectedValues(undefined, this.selectedAndUnselectedDocs);
                        }
                       
                    }
                });
            }
        } else {
            this.isCheckedTrue = '';
            this.questionMetadata[generalQnIndex].response = this.label.radioNo;
            this.questionMetadata[generalQnIndex].displaySubQue = true; 
            let questionname = this.questionMetadata[generalQnIndex].name;
            this.questionMetadata[generalQnIndex].subRows = this.mapOfParentQtnToSubQtns.get(questionname);
             this.isOutcomeBasedClaim ? (this.questionMetadata[generalQnIndex].isOutcomeBasedComment = (!this.questionMetadata[generalQnIndex].subRows || !this.questionMetadata[generalQnIndex].subRows?.length) ? true : false) : null ;//Swati
            
        }
        if(this.questionMetadata[generalQnIndex].displayFileSelOnParent === true){
                this.template.querySelectorAll(".multiSelectFiles").forEach(element => {
                    const elementName = element.values[0].questionCode;
                 const qtnCode = element.id.slice(0, 7);//Swati
                if (eventValue === responeAsNo && (elementName === name || qtnCode === name)) {//Swati added qtnCode for tactic
                        element.enablePickilstMethod();

                } else if (eventValue === responseAsYes && elementName === name || qtnCode === name) {
                        element.clear();
                        element.disablePickilstMethod(true);
                        element.isValid();
                        let tempSelectedFile = [];
                        this.questionMetadata.map((qnMetadata, qnIndex) => {
                            if (qnMetadata.name === name) {
                                this.questionMetadata[qnIndex].fileNames.map(file => {
                                    file.selected = false;
                                    tempSelectedFile.push(file);
                                });
                            }
                        });
                        this.selectedAndUnselectedDocs = [...tempSelectedFile];
                        this.fetchSelectedValues(undefined, this.selectedAndUnselectedDocs);
                    }
                });
            }
        this.currentlySelectedQtn = name;
        
                

    }
    renderedCallback() {
        if (this.questionNameWithFiles.includes(this.currentlySelectedQtn)) {//recently updated qtn
            this.template.querySelectorAll(".multiSelectFiles").forEach(element => {
                const elementName = element.values[0].questionCode ||element.id.slice(0, 7);//Swati element.id.slice(0, 7)
                
                if (this.isCheckedTrue === ''&& this.mapOfSubQtnToParQtn.get(elementName) === this.currentlySelectedQtn) {
                    element.disablePickilstMethod(true);

                } 
            });
        }
    }

    /**
     * To track the internal comments
     * @param {*} event - holds internal comments provided by reviewer
     */
    handleInternalComments(event) {
        this.internalComments = event.target.value;
    }

    //Actions to be taken on click of submit
    handleSubmit() {
        this.disableCompleteReview = true;
        this.hideSpinner(false);
        this.editedClaimAttributes = [];
        this.editedClaimAttributeLabels = [];
        this.newlyAddedDocuments = [];
        this.managedExistingDocuments = [];
        this.endTime = new Date();
        this.claimFields = this.objectInfo;
        const claimAttributeList = this.claimAttributes;

        //Roshan
        this.campPurposeChanged = false;
        this.tacticsMetricsChanged = false;
        this.tacticsSpendingChanged = false;
        
        this.getClaimRecordData()
            .then(response => {
                if (Object.keys(response).length) {
                    this.claimDetailOnCompleteReview = response;
                    
                    //Roshan
                    this.campPurposeValuesOnCompleteReview = this.claimDetailOnCompleteReview.Core_MDF_Quantity_to_Date_Nbr__c;
                    if(this.campPurposeValuesOnCompleteReview !== this.campPurposeValuesOnStartReview) {
                        this.campPurposeChanged = true;
                    }
                    
                    claimAttributeList.map(claimAttr => {
                        if (this.claimDetailOnCompleteReview[claimAttr] !== this.claimDetailOnStartReview[claimAttr]) {
                            this.editedClaimAttributes.push(claimAttr);
                        }
                    });
                }
                this.getAuditDocumentList()
                    .then(response => {
                        if (response.length) {
                            this.auditDocumentsListonCompleteReview = response;
                            if (this.auditDocumentsListonStartReview.length && this.auditDocumentsListonCompleteReview.length) {
                                if (this.auditDocumentsListonStartReview.length !== this.auditDocumentsListonCompleteReview.length) {
                                    this.auditDocumentsListonCompleteReview.map(auditDocument => {
                                        let docIndex = this.auditDocumentsListonStartReview.findIndex(doc => doc.Core_MDF_Document_Title__c + doc.CreatedDate === auditDocument.Core_MDF_Document_Title__c + auditDocument.CreatedDate);
                                        if (docIndex === -1) {
                                            this.newlyAddedDocuments.push(auditDocument.Core_MDF_Document_Title__c);
                                        }
                                    });
                                }
                                this.auditDocumentsListonStartReview.map((auditDocument, docIndex) => {
                                    if (this.auditDocumentsListonCompleteReview[docIndex].Core_MDF_Document_Types__c !== auditDocument.Core_MDF_Document_Types__c) {
                                        this.managedExistingDocuments.push(auditDocument.Core_MDF_Document_Title__c);
                                    }
                                });
                            }
                            //Roshan
                            this.getTacticsData()
                                .then(result => {
                                    const allTactics = Object.values(result).flat();
                                    allTactics.forEach(t => {
                                        if (t.Core_MDF_Type_nm__c === 'KPI - Claim') {
                                            if (this.tacticsMetricsValues[t.Core_MDF_Field_Name_nm__c + '_' + t.Core_MDF_Type_nm__c]) {
                                                this.tacticsMetricsValues[t.Core_MDF_Field_Name_nm__c + '_' + t.Core_MDF_Type_nm__c].valueOnReviewEnd = t.Core_MDF_Field_Value_nbr__c;
                                            }
                                        } else if (t.Core_MDF_Type_nm__c === 'Spend This Period') {
                                            if (this.tacticsSpendingValues[t.Core_MDF_Tactics_nm__c + '_' + t.Core_MDF_Type_nm__c]) {
                                                this.tacticsSpendingValues[t.Core_MDF_Tactics_nm__c + '_' + t.Core_MDF_Type_nm__c].valueOnReviewEnd = t.Core_MDF_Field_Value_nbr__c;
                                            }
                                        }
                                    });

                                    this.tacticsMetricsChanged = Object.values(this.tacticsMetricsValues).some(v => v.valueOnReviewStart !== v.valueOnReviewEnd);
                                    this.tacticsSpendingChanged = Object.values(this.tacticsSpendingValues).some(v => v.valueOnReviewStart !== v.valueOnReviewEnd);
                                    
                            if (this.editedClaimAttributes.length > 0 || this.newlyAddedDocuments.length > 0 || this.managedExistingDocuments.length > 0 || this.campPurposeChanged || this.tacticsMetricsChanged || this.tacticsSpendingChanged) {
                                if (this.editedClaimAttributes.includes('Core_MDF_Status__c')) {
                                    this.isClaimStatusChanged = true;
                                    this.claimReviewerName = this.claimDetailOnCompleteReview.Core_MDF_Last_Reviewed_By_id__r.Name;
                                    this.hideSpinner(true);
                                } else {
                                    this.editedClaimAttributes.map(updatedClaimAttr => {
                                        this.editedClaimAttributeLabels.push(this.claimFields[updatedClaimAttr].label);
                                    });
                                    this.enableConfirmationModalPopup = true;
                                    this.hideSpinner(true);
                                }
                            } else {
                                this.completeReview();
                            }

                            //Roshan
                            }).catch(error => {
                                this.hideSpinner(true);
                                this.displayServerExceptionMessage(this.label.applicationError, false);
                            });
                            
                        }
                    }).catch(error => {
                        this.hideSpinner(true);
                        this.displayServerExceptionMessage(this.label.applicationError, false);
                    });
            }).catch(error => {
                this.hideSpinner(true);
                this.displayServerExceptionMessage(this.label.applicationError, false);
            });

    }

    completeReview() {
        let validationArray = [];
        let showValidationErrorToast = false;
        let finalQuestionMetadata;
        this.isReviewFeedbackFailed = false;
        let responseOfQuestion='';

        this.questionMetadata.map(qnMdt => {
            if (qnMdt.response === "") {
                showValidationErrorToast = true;
            } else if (qnMdt.response.toLowerCase() === this.label.radioNo.toLowerCase()) {
                this.isReviewFeedbackFailed = true;
            }
        });

        (this.subQuestionMetadata || []).map(qnMdt => {  //Roshan - added for IPA OutcomeBased claims
            if (qnMdt.response === true) {
                this.isReviewFeedbackFailed = true;
            }
        });

        //Roshan - added for IPA OutcomeBased claims
        if (this.isOutcomeBasedClaim) {
            const needsComment = this.questionMetadata.some(qnMdt => {
            const hasSubQn = !!qnMdt.subRows?.length;

             if (hasSubQn) {
                    return this.subQuestionMetadata.some(subQn => {
                        return (
                            subQn.response === true && 
                            (!subQn.comment || !subQn.comment.trim())
                        );
                    });
                } else {
                    return (
                        qnMdt.response.toLowerCase() === this.label.radioNo.toLowerCase() &&
                        (!qnMdt.comment || !qnMdt.comment.trim())
                    );
                }
            });
            if (needsComment) {
                const errorToastEvent = new ShowToastEvent({
                    title: 'Submit Error',
                    message: 'Please provide valid PIC rejection comments',
                    variant: 'error'
                });
                this.dispatchEvent(errorToastEvent);
                this.hideSpinner(true);
                this.disableCompleteReview = false;
                return;
            }

            //Swati Tactic validation
            const needsTactic = this.questionMetadata.some(qnMdt => {
            const hasSubQn = !!qnMdt.subRows?.length;
             if (hasSubQn) {
                    return this.subQuestionMetadata.some(subQn => {
                        return (
                            subQn.response === true && 
                            (!subQn.tactic ||  subQn.tactic.length === 0)
                        );
                    });
                } else {
                    return (
                        qnMdt.response.toLowerCase() === this.label.radioNo.toLowerCase() &&
                        (!qnMdt.tactic || qnMdt.tactic.length === 0)
                    );
                }
            });
            
            if (needsTactic) {
                const errorToastEvent = new ShowToastEvent({
                    title: 'Submit Error',
                    message: 'Select at least one Tactic',
                    variant: 'error'
                });
                this.dispatchEvent(errorToastEvent);
                this.hideSpinner(true);
                this.disableCompleteReview = false;
                return;
            }

        }

        if (showValidationErrorToast) {
            const errorToastEvent = new ShowToastEvent({
                title: 'Submit Error',
                message: this.label.errorMessageOnCompletePICReview,
                variant: 'error'
            });

            this.dispatchEvent(errorToastEvent);
            this.hideSpinner(true);
            this.disableCompleteReview = false;
        } else {
            

            //submit the response only if all the validations are true
            if (!validationArray.includes(false)) {
                //toast to display on successful submission of review
                let toastEvent = new ShowToastEvent({
                    title: this.label.picReviewStatus,
                    message: this.isReviewFeedbackFailed ? `The PIC Review for the claim ${this.claimDetails.Core_MDF_Claim_Ref_Number__c} is completed with the result PIC Failed` : `The PIC Review for the claim ${this.claimDetails.Core_MDF_Claim_Ref_Number__c} is completed with the result PIC Passed`,
                    variant: this.isReviewFeedbackFailed ? 'error' : 'success'
                });


                //passing required data to controller for new record creation
                
                finalQuestionMetadata = [...this.questionMetadata, ...this.subQuestionMetadata || []];  //Roshan - added for IPA OutcomeBased claims
                this.picReviewWrapper = { questionData: finalQuestionMetadata, internalComments: this.internalComments, startDateTime: this.startTime, endDateTime: this.endTime, claimId: this.claimId, userId: this.userId, isReviewFailed: this.isReviewFeedbackFailed, isRecommendedForAudit: this.isRecommendedForAudit, latestAIPICreviewID: this.latestAIPICReviewId }
                this.insertPICReviewData(this.picReviewWrapper, toastEvent);
            } else {
                this.disableCompleteReview = false;
                this.hideSpinner(true);
            }
        }


    }

    async insertPICReviewData(picReviewWrapper, toastEvent) {
        try {
            this.hideSpinner(false);
            await reviewDataInsertion({ picReviewWrapper: picReviewWrapper });
            this.hideSpinner(true);
            this.dispatchEvent(toastEvent);
            this.hidePICReviewScreen(true);
        } catch (error) {
            this.hideSpinner(true);
            this.displayServerExceptionMessage(this.label.applicationError, false);
        }
    }
    //track start time and enable response column on start of review
    OnStartReview() {
        this.disableStartReview = true;
        this.disableGenAIBtn = true;
        this.getClaimRecordData()
            .then(response => {
                if (Object.keys(response).length) {
                                                                       
                    this.claimDetailOnStartReview = response;
                    
                    //Roshan
                    this.campPurposeValuesOnStartReview = this.claimDetailOnStartReview.Core_MDF_Quantity_to_Date_Nbr__c;
                    
                    if (this.claimDetailOnStartReview.Core_MDF_Status__c.toLowerCase() !== this.label.claimStatusPICPending.toLowerCase() && this.claimDetailOnStartReview.Core_MDF_Status__c.toLowerCase() !== this.label.claimStatusPaidAndPICPending.toLowerCase()) {
                        //1st way - show PIC completed POP
                        this.isClaimStatusChanged = true;
                        this.claimReviewerName = this.claimDetailOnStartReview.Core_MDF_Last_Reviewed_By_id__r.Name;
                }
                    else {
        this.getAuditDocumentList()
                            .then(res => {
                                if (res.length) {
                                    this.auditDocumentsListonStartReview = res;
                }
            }).catch(error => {
                this.displayServerExceptionMessage(this.label.applicationError, false);
            })
                        //Roshan
                        this.getTacticsData()
                            .then(result => {
                                if (!result || Object.keys(result).length === 0) { return; }

                                const allTactics = Object.values(result).flat();
                                allTactics.forEach(t => {
                                    if (t.Core_MDF_Type_nm__c === 'KPI - Claim') {
                                        this.tacticsMetricsValues[t.Core_MDF_Field_Name_nm__c + '_' + t.Core_MDF_Type_nm__c] = {
                                            valueOnReviewStart: t.Core_MDF_Field_Value_nbr__c,
                                            valueOnReviewEnd: null
                                        };
                                    } else if (t.Core_MDF_Type_nm__c === 'Spend This Period') {
                                        this.tacticsSpendingValues[t.Core_MDF_Tactics_nm__c + '_' + t.Core_MDF_Type_nm__c] = {
                                            valueOnReviewStart: t.Core_MDF_Field_Value_nbr__c,
                                            valueOnReviewEnd: null
                                        };
                                    }
                                });


                        }).catch(error => {
                            this.displayServerExceptionMessage(this.label.applicationError, false);
                        });
                    }
                }
            }).catch(error => {
                this.displayServerExceptionMessage(this.label.applicationError, false);
            });
        this.disableResponse = false;
        this.disableCompleteReview = false;
        this.startTime = new Date();
    }


    handleAuditrecommendation(event) {
        this.isRecommendedForAudit = event.target.checked;
    }

    //To get the updated data of claim from apex controller
    async getClaimRecordData() {
        const result = await fetchClaimRecordData({ claimId: this.claimId })
        return result;
    }

    async getAuditDocumentList() {
        const result = await fetchAuditDocumentList({ claimId: this.claimId })
        return result;
    }

    //Roshan
    async getTacticsData() {
        const result = await fetchTactics({ claimId: this.claimId })
        return result;
    }
    
    //To get the claim field names from  custom label config metadata
    getClaimAttributes() {
        getClaimAttributesFromMetaData({ claimId: this.claimId })
            .then(response => {
                if (response) {
                                                                       
                    this.claimAttributes = response;
                }
            }).catch(error => {
            this.hideSpinner(true);
                this.displayServerExceptionMessage(this.label.applicationError, false);
            })
    }

    //Cancel review submission on update of claim - close the confirmation popup, refresh claim details, reset the responses selected
    cancelReviewSubmission() {
        this.hideSpinner(false);
        this.refreshClaimDetails();
        this.claimDetailOnStartReview = this.claimDetailOnCompleteReview;
        this.auditDocumentsListonStartReview = this.auditDocumentsListonCompleteReview;
        this.updateTacticStartValues();  //Roshan
        this.enableConfirmationModalPopup = false;
        this.template.querySelector('.internalComments').value = '';
        this.template.querySelector('.recommendForClaimReview').checked = false;
        this.disableCommentsOnLoad();  //Roshan
        refreshApex(this.auditDocumentResponse);
        this.resetResponse();
        this.disablePicklistOnLoad();
        this.disableResponse = true;
        this.disableCompleteReview = true;
        this.disableStartReview = false;
        this.hideSpinner(true);
    }

    //To refresh the claim details in the PIC Review Screen on update of claim - dispatch an event to parent comp
    refreshClaimDetails() {
        const refreshClaimEvent = new CustomEvent('updateofclaim', {});
        this.dispatchEvent(refreshClaimEvent);
    }

    // To reset all the responses selected
    resetResponse() {
        const documentTypes = this.label.claimDocumentTypes.split(';');
        this.questionMetadata.map(qnMetadata => {
            qnMetadata.response = '';
            if (documentTypes.includes(qnMetadata.fileType)) {
                qnMetadata.fileNames.map(file => {
                    file.selected = false;
                });
            }
        });
    }

    //Roshan
    updateTacticStartValues() {
        this.campPurposeValuesOnStartReview = this.campPurposeValuesOnCompleteReview;
        Object.keys(this.tacticsMetricsValues).forEach(key => {
            this.tacticsMetricsValues[key].valueOnReviewStart = this.tacticsMetricsValues[key].valueOnReviewEnd;
            this.tacticsMetricsValues[key].valueOnReviewEnd = null;
        });

        Object.keys(this.tacticsSpendingValues).forEach(key => {
            this.tacticsSpendingValues[key].valueOnReviewStart = this.tacticsSpendingValues[key].valueOnReviewEnd;
            this.tacticsSpendingValues[key].valueOnReviewEnd = null;
        });
    }

    //Roshan
    disableCommentsOnLoad() {
        if (this.questionMetadata && this.questionMetadata.length) {
            this.questionMetadata.forEach(qn => {
                qn.isOutcomeBasedComment = false;
                qn.comment = '';
            });
        }
        if (this.subQuestionMetadata && this.subQuestionMetadata.length) {
            this.subQuestionMetadata.forEach(qn => {
                qn.isOutcomeBasedComment = false;
                qn.comment = '';
            });
        }
    }
    
    //continue review submission on update of claim - refresh the claim details and complete the review process
    onContinueReviewCompletion() {
        this.hideSpinner(false);
        this.claimDetailOnStartReview = this.claimDetailOnCompleteReview;
        this.auditDocumentsListonStartReview = this.auditDocumentsListonCompleteReview;
        this.updateTacticStartValues();  //Roshan
        this.enableConfirmationModalPopup = false;
                                           
        this.completeReview();
    }

    //download all the claim review documents
    downloadFiles() {
        this.contentDocumentIds && this.contentDocumentIds.map(contentDoc => {
            this.downloadDocuments(contentDoc);
        });
    }

    downloadDocuments(contentDocumentId) {
        const docUrl = '/sfc/servlet.shepherd/document/download/' + contentDocumentId;
        const hyperLinkElement = document.createElement('a');
        hyperLinkElement.href = docUrl;
        hyperLinkElement.target = '_blank';
        hyperLinkElement.download;
        hyperLinkElement.id = 'a1';
        document.body.appendChild(hyperLinkElement);
        hyperLinkElement.click();
    }

    //show toast mesage on application exceptions
    displayServerExceptionMessage(errorMessage, isReload) {
        this.showSpinner = false;
        const toastEvent = new ShowToastEvent({
            title: this.label.applicationErrorText,
            message: errorMessage,
            variant: 'error'
        });
        this.dispatchEvent(toastEvent);
        this.hidePICReviewScreen(isReload);
    }

    //to close the modal window, dispatch event from child lwc to parent lwc
    hidePICReviewScreen(isReload = true) {
        const picReviewScreenEvent = new CustomEvent('hidepicreviewscreen', {
            detail: { isReload: isReload }
        });
        this.dispatchEvent(picReviewScreenEvent);
    }

    hideSpinner(hideSpinner) {
        const picReviewScreenEvent = new CustomEvent('hidespinner', {
            detail: { hide: hideSpinner }
        });
        this.dispatchEvent(picReviewScreenEvent);
    }
    //Sham - AI Generated Response
    // Helper method to determine if a response is positive or Negative
    getAIResponseClass(response) {
        if (response === null || response === undefined)
            return '';
        const normalized = response.toString().trim().toLowerCase();

        if (normalized === 'yes' || normalized === 'false') {
            return 'ai-response-yes';
        }
        if (normalized === 'no' || normalized === 'true') {
            return 'ai-response-no';
        }
        return '';
    }




    //Sham - AI Generated Response
    setAIResponsefromResult() {
        // helper method to update status for failure
        const setAIResponseAndLoadUI = ({ isAIResAvailable, disableGenAI, errMessage }) => {
            this.aiResponseRcvd = isAIResAvailable;
            this.disableGenAIBtn = disableGenAI;//VB -change this variable
            this.aiErrorMsg = errMessage || '';
            this.getMetadataRecords();
        };

        // Early return for outcome-based claims
        if (this.claimOutcomeBasedInd) {
            setAIResponseAndLoadUI({ isAIResAvailable: false, disableGenAI: true, errMessage: this.outcomeBasedMsg });
            return;
        }
        
        fetchAIResponse({ claimId: this.claimId })
            .then(aiResult => {//VB - change this variable name ?
                try {
                    
                    // Validate the response structure
                    if (!aiResult || typeof aiResult !== 'object') {
                        setAIResponseAndLoadUI({ isAIResAvailable: false, disableGenAI: true, errMessage: this.failedErrorMsg });
                        return;
                    }

                    // Reset state before processing new data
                    this.aiResponseRcvd = false;
                    this.disableGenAIBtn = true;
                    this.aiErrorMsg = '';

                    const results = aiResult.picReviewDetails || [];
                    
                    if (aiResult.status === 'AVAILABLE' && results.length > 0) { 
                        // Process AI response metadata
                        this.aiResponseMetadata = results.map(result => ({
                            aiQnId: result.Core_MDF_Question_id__c,
                            aiQnResponse: result.Core_MDF_Response_txt__c,
                            aiQnComment: result.Core_MDF_Comment_txt__c || this.aiDefaultComment
                        }));
                        
                        // latest AI PIC review id for manual Pic Review 
                        this.latestAIPICReviewId = aiResult.picReviewId;
                        setAIResponseAndLoadUI({ isAIResAvailable: true, disableGenAI: false, errMessage: '' });
                    } else {
                        const errMsg = aiResult?.status === 'INPROGRESS' ? this.inProgressErrorMsg : this.failedErrorMsg;
                        setAIResponseAndLoadUI({ isAIResAvailable: false,disableGenAI: true,errMessage: errMsg });
                    }
                } catch (error) {
                    setAIResponseAndLoadUI({ isAIResAvailable: false, disableGenAI: true, errMessage: this.failedErrorMsg });
                }
            })
            .catch(error => {
                setAIResponseAndLoadUI({ isAIResAvailable: false, disableGenAI: true, errMessage: this.failedErrorMsg });
            });
    }

    async handleGenerateAIValidation() {
        this.disableGenAIBtn=true;
        this.showSpinner = true;
        try {
            //First call: fetch claim record
            const claimRec = await fetchClaimRecordData({ claimId: this.claimId });

            this.claimIdToRecordMap.set(this.claimId, claimRec);
            const claimRecordsObj = Object.fromEntries(this.claimIdToRecordMap);
            const reviewMapObj = this.claimIdToReviewToCDBLogRec
                ? Object.fromEntries(this.claimIdToReviewToCDBLogRec)
                : {};

            //Second call: CDB Call
            const status = await fetchClaimDocAndPICReviewDetails({ claimRecordsMap: claimRecordsObj, claimIdToPicReviewIdToFinalCDBLog: reviewMapObj });

            // Handle explicit error status returned by Apex
            if (status === 'ERROR') {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error in Generating AI Recommendations',
                    message: 'There was an error fetching AI Recommendations. Please try again or continue with the review.',
                    variant: 'error',
                    mode: 'sticky'
                }));
            }
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error in Generating AI Recommendations',
                message: 'There was an error fetching AI Recommendations. Please try again or continue with the review.',
                variant: 'error',
                mode: 'sticky'
            }));
        } finally {
            this.showSpinner = false;
            this.setAIResponsefromResult();
        }
    }
}