import { LightningElement, api, wire, track } from 'lwc';
import getTenderComments from '@salesforce/apex/Pricing_CommentsController.getTenderComments';
import updateTenderComments from '@salesforce/apex/Pricing_CommentsController.updateTenderComments';
import createTenderComments from '@salesforce/apex/Pricing_CommentsController.createTenderComments';
import isPricingManager from '@salesforce/apex/Pricing_CommentsController.isPricingManager';
import isFinancialIncentivePricingManager from '@salesforce/apex/Pricing_CommentsController.isFinancialIncentivePricingManager';
import isReadOnlyUser from '@salesforce/apex/Pricing_CommentsController.isReadOnlyUser';
import getPricingManagerComments from '@salesforce/apex/Pricing_CommentsController.getPricingManagerComments';
import updateCommentThroughId from '@salesforce/apex/Pricing_CommentsController.updateCommentThroughId';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import COMMENTS_OBJECT from '@salesforce/schema/Pricing_Comments__c';
import { getRecord } from 'lightning/uiRecordApi';
import minLength from '@salesforce/label/c.Pricing_Tender_Comments_MinLength';
import maxLength from '@salesforce/label/c.Pricing_Tender_Comments_MaxLength';
import questionWithNoMinLength1 from '@salesforce/label/c.Pricing_Tender_Comments_NoMinLengthQuest';
import nonLatinCharacters from '@salesforce/label/c.Pricing_Non_Latin_Char_Validation_Error';
import commentRegex from '@salesforce/label/c.Pricing_Latin_Characters_Regular_Expr_Label';
import SVDQuoteType from '@salesforce/label/c.Pricing_Tender_Small_Volume_Quote';
import { NavigationMixin } from 'lightning/navigation';
import questionWithNoMinLength2 from '@salesforce/label/c.Pricing_Client_Comment_Question_noMinLength';
import { updateRecord } from 'lightning/uiRecordApi';
import INVALIDOPP_FIELD from '@salesforce/schema/SBQQ__Quote__c.Pricing_Invalid_End_Customer_cb__c';
import ID_FIELD from '@salesforce/schema/SBQQ__Quote__c.Id';
import EndCustomerMismatchError from '@salesforce/label/c.Pricing_Quote_EndCustomer_Mismatch_To_OpptyEndCustomer'

const columns = [
    {
        label: 'Comment',
        fieldName: 'Pricing_Answer__c',
        cellAttributes: { alignment: 'top' },
        type: 'text',
        wrapText: true
    },
    {
        label: 'Created By',
        fieldName: 'CreatedBy',
        cellAttributes: { alignment: 'top' },
    },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date',
        typeAttributes: {
            year: 'numeric',
            month: 'long',
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit',
            hour12: 'false',
        },
        cellAttributes: { alignment: 'top' },
    },
];

const progTypeField = ['SBQQ__Quote__c.Pricing_Program_Type_Nm__c', 'SBQQ__Quote__c.Pricing_Quote_Program_Nm__c', 'SBQQ__Quote__c.Pricing_Invalid_End_Customer_cb__c'];

export default class pricing_CommentsComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api quoteStatus;
    @track error;
    @track hasUpdateAccess;
    @track isRPM = false;
    @track isReadOnly = false;
    @track data;
    @track pmComment = '';
    @track quoteRec;
    wiredPMComments;
    commentsList = [];
    comments = [];
    isFIRPM = false;
    nonFIQuote = true;

    @wire(getTenderComments, { recordId: '$recordId' })
    tenderComments;

    @wire(getPricingManagerComments, { recordId: '$recordId' })
    pricingManagerComments(response) {
        this.wiredPMComments = response;
        if (response.error) {
        } else if (response.data) {
            let currentData = [];  // NOSONAR

            response.data.forEach((row) => {
                let rowData = {};  // NOSONAR
                rowData.Pricing_Answer__c = row.Pricing_Answer__c;
                rowData.CreatedDate = row.CreatedDate;
                // User related data
                if (row.CreatedBy) {
                    rowData.CreatedBy = row.CreatedBy.Name;
                }
                currentData.push(rowData);
            });

            this.data = currentData;
        }
    }

    @wire(isReadOnlyUser)
    wiredRecord({ error, data }) {
        if (error) {
            this.isReadOnly = false;
        } else if (data) {
            this.isReadOnly = true;
        }
    }

    @wire(isFinancialIncentivePricingManager)
    getFIUSER({ error, data }) {
        if (error) {
            this.isFIRPM = false;
        } else if (data) {
            this.isFIRPM = true;
        }
    }

    get showRPMComments() {

        let showRPMCommentsValue = false;
        if (this.isReadOnly) {
            showRPMCommentsValue = true;
        }

        if (this.isRPM && this.nonFIQuote) {
            showRPMCommentsValue = true;
        }

        if (this.isFIRPM && !this.nonFIQuote) {
            showRPMCommentsValue = true;
        }
        return showRPMCommentsValue;
    }

    @wire(isPricingManager)
    wiredRecordRPM({ error, data }) {
        if (error) {
            this.isRPM = false;
        } else if (data) {
            this.isRPM = true;
        }
    }

    get disblePMComment() {
        let disable = true;
        if (this.isRPM || this.isFIRPM) {
            disable = false;
        }
        if (this.isReadOnly) {
            disable = true;
        }
        return disable;
    }

    @wire(getRecord, { recordId: '$recordId', fields: progTypeField })
    checkSVDQuote({ data, error }) {
        if (data) {
            this.quoteRec = data.fields.Pricing_Program_Type_Nm__c.value;
            this.nonFIQuote = data.fields.Pricing_Quote_Program_Nm__c.value == 'Financial Incentive' ? false : true;
            this.error = undefined;
            if (data.fields.Pricing_Invalid_End_Customer_cb__c.value) {
                this.showWarningMsg();
            }
        }
        else if (error) {
            this.error = error;
            this.quoteRec = undefined;
        }
    }

    get isCommentOptional() {
        let isCommentOptional = false;
        if (this.quoteRec === SVDQuoteType) {
            isCommentOptional = true;
        }
        return isCommentOptional;
    }

    @track columns = columns;

    createComment() {
        // dont save if the comments are empty
        if (this.pmComment !== undefined && this.pmComment.length === 0) {
            return;
        }
        const recordInput = { pmComments: this.pmComment, quoteId: this.recordId };
        createTenderComments(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Comments saved successfully',
                        variant: 'success',
                    })
                );
                this.template.querySelector('[data-id=\'pmCmnt\']').value = '';
                // Emyty the created comment
                this.pmComment = '';
                // Display fresh data in the datatable
                return refreshApex(this.wiredPMComments);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving record',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    handleComment(event) {
        if (event.target.label === 'Comment') {
            this.pmComment = event.target.value;
        }
    }

    get processedList() {
        this.commentsList =
            this.commentsList.length === 0
                ? JSON.parse(JSON.stringify(this.tenderComments.data))
                : this.commentsList;
        return this.commentsList.map((item) => {
            return {
                Id: item.Id,
                Pricing_Question__c: item.Pricing_Question__c,
                Pricing_Required_Ind__c: item.Pricing_Required_Ind__c,
                Pricing_Answer__c: item.Pricing_Answer__c,
                MaxLength: maxLength,
                MinLength:
                    (item.Pricing_Question__c.includes(questionWithNoMinLength1) || item.Pricing_Question__c.includes(questionWithNoMinLength2))
                        ? 0
                        : minLength,
            };
        });
    }

    @wire(getObjectInfo, { objectApiName: COMMENTS_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.hasUpdateAccess = data.updateable;
        } else if (error) {
            console.error('Error @ getObjectInfo: ' + JSON.stringify(getObjectInfo));
            // eslint-disable-next-line no-console
        }
    }

    handleChange(event) {
        let id = event.target.getAttribute('data-id');  // NOSONAR
        this.comments =
            this.comments.length === 0
                ? JSON.parse(JSON.stringify(this.tenderComments.data))
                : this.comments;

        for (let i in this.comments) {  // NOSONAR
            if (this.comments[i].Id === id) {
                this.comments[i].Pricing_Answer__c = event.target.value;
                break;
            }
        }
    }

    get disableInput() {
        return !(this.hasUpdateAccess && this.quoteStatus === 'Draft');
    }

    handleSave() {
        const updatedRecrds = this.comments;
        const recordInput = { tenderComments: updatedRecrds };

        const allValid = [
            ...this.template.querySelectorAll('lightning-textarea'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (!allValid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please update the invalid form entries and try again.',
                    variant: 'error',
                })
            );
            return;
        }

        updateTenderComments(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Comments saved successfully',
                        variant: 'success',
                    })
                );

                // Display fresh data in the datatable
                return refreshApex(this.tenderComments);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    //text Area On Blur Methord
    textAreaOnBlur(event) {
        let answer = event.target.value;  // NOSONAR
        answer = (answer !== undefined) ? answer.trim() : '';
        let question = event.target.name;  // NOSONAR
        //var answerValue = this.template.querySelector('lightning-textarea');
        let commentId;
        if (answer !== undefined) {
            if (!answer.match(commentRegex)) {
                event.target.setCustomValidity(nonLatinCharacters);
            } else if ((question.includes(questionWithNoMinLength1) || question.includes(questionWithNoMinLength2)) && answer.length === 0) {
                //do nothing
                event.target.setCustomValidity('');
            } else if (
                !question.includes(questionWithNoMinLength1) && !question.includes(questionWithNoMinLength2) &&
                (answer.length === 0 || answer.length < 10)
            ) {
                //do nothing
                event.target.setCustomValidity('Your entry is too short! Minimum 10 characters required');
            } else {
                for (let i = 0; i < this.commentsList.length; i++) {
                    if (this.commentsList[i].Pricing_Question__c === question) {
                        this.commentsList[i].Pricing_Answer__c = answer;
                        commentId = this.commentsList[i].Id;
                        break;
                    }
                }
                let outputText = this.template.querySelector('.' + commentId);  // NOSONAR
                outputText.value = 'Saving..';
                updateCommentThroughId({
                    recordId: commentId,
                    answer: answer,
                })
                    .then((result) => {
                        outputText.value = 'Saved';
                        setTimeout(function () {
                            outputText.value = '';
                        }, 2000);
                        return refreshApex(this.tenderComments);
                    })
                    .catch((error) => {
                    });
                event.target.setCustomValidity('');
            }
            event.target.reportValidity();
        }
    }

    showWarningMsg() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[INVALIDOPP_FIELD.fieldApiName] = false;

        const recordInput = { fields };
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: EndCustomerMismatchError,
                        variant: 'warning'
                    })
                );
            })
            .catch(error => {
                console.error('Error in updating record: ' + JSON.stringify(error));
            });
    }
}