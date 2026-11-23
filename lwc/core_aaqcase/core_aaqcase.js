import { api, track, wire, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import accountTemplate from "./core_accountcase.html";
import { getRecord } from 'lightning/uiRecordApi';
import aaqTemplate from "./core_aaqcase.html";
import { CloseActionScreenEvent } from 'lightning/actions';
import hasAccess from '@salesforce/apex/core_S2S_ViewICSCases.hasAccess';
import USER_ID from '@salesforce/user/Id';
import getLabel from '@salesforce/apex/core_S2S_CaseExternalFeedController.getLabel';

import { refreshApex } from "@salesforce/apex";

const FIELDS = ["User.Email"];

export default class Core_aaqcase extends NavigationMixin(LightningElement) {

    @api modalheader;
    @api ismodal;
    @track currentStep = 0;
    @track multipleAccount = false;
    @track currentStep = 1;
    @track _steps;
    @track readyToRender = false;

    retryMessage = 'unable to obtain exclusive access';
    MAX_RETRIES = 3;
    retry = false;
    isflowReady;
    emailAddress;
    phoneNumber;
    inputVariables;
    newCaseId;
    currentScreen = '';
    flowOutputVariable = new Object();
    haveExternalContact;
    caseSubject = '';
    caseDesc;
    prodSpinner;
    environmentDetailQuestion;
    environmentAnswerQuestion;
    mapOfQuestionAnswer = {};
    mapOfContactWithExternalId = {};
    productSection;
    caseCreationSection;
    fields = {};
    caseCreationSpinner;
    environmentQuestionAnswerSelected = [];
    accountCalledConnectedBack = false;
    isAccountCalled = false;
    currentIndex = 0;
    disableButton = true;
    accountLevelCaseCreation = false;
    recordId;
    productSearch;
    calloutFrom = '';
    productSerchText = '';
    mapOfSearchProductWithExternalId = {};
    searchProductForAccount;
    selectedProductOption;
    isProductExternalPresent;
    isContact = false;
    showAccountCase = false;
    mutipleAccount = false;
    isSeverity = false;
    failedStep;
    caseSeverityLevel = 5;
    caseCreationCreated = false;
    isAccountAsscoiated = true;
    prevScreen = '';
    errorScreen = false;
    errorMessage = '';
    unexpectedError = false;
    labels = {};
    contactDefaultLanguage = '';
    caseProductId = '';
    retryCount = 0;
    accessErrorMessageOrNoServiceMessageTagged ='';

    /****************************************************************************************** 
     * Handles current page reference to get recordId from Account Object.
     * @param {}.
    ******************************************************************************************/
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            if (this.recordId !== undefined) {
                this.showAccountCase = true;
            }
        }
    }

    render() {
        return this.showAccountCase ? accountTemplate : aaqTemplate;
    }

    /****************************************************************************************** 
     * Fetches the current user's email address.
     * @param {object} wireuser - The wire service response containing user data.
    ******************************************************************************************/
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    wireuser({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.emailAddress = data.fields.Email.value;
        }
    }

    /****************************************************************************************** 
    * Return the labels and set the map.
    * @param { } .
    *****************************************************************************************/
    @wire(getLabel)
    getLabels({ error, data }) {
        if (data) {
            let labels = {};
            data.forEach(lab => {
                labels[lab.Name] = lab.Value__c;
            });

            this.labels = labels;
        } else if (error) {
            console.error('Error fetching labels:', error);
        }
    }

    get severityOption() {
        return [
            { label: this.labels.SevirtyCritical, value: '1' },
            { label: this.labels.SevirtyHigh, value: '2' },
            { label: this.labels.SevirtyMedium, value: '3' },
            { label: this.labels.SevirtyLow, value: '4' }
        ];
    }

    get steps() {
        if (!this._steps) {
            this.calculateSteps();
        }
        return this._steps;
    }

    /****************************************************************************************** 
     * Calculates steps for the wizard based on context.
    ******************************************************************************************/
    calculateSteps() {
        if (this.multipleAccount) {
            this._steps = [
                { label: 'Account Selection', class: this.getStepClass(1), completed: this.currentStep > 1, failed: this.failedStep === -1 },
                { label: 'Product Selection', class: this.getStepClass(2), completed: this.currentStep > 2, failed: this.failedStep === -2 },
                { label: 'Case Details', class: this.getStepClass(3), completed: this.currentStep > 3, failed: this.failedStep === -3 },
                { label: 'Additional Details', class: this.getStepClass(4), completed: this.currentStep > 4, failed: this.failedStep === -4 },
                { label: 'Request Creation', class: this.getStepClass(5), completed: this.currentStep > 5, failed: this.failedStep === -5 },
            ];
        } else if (this.calloutFrom === 'AAQ') {
            this._steps = [
                { label: 'Case Details', class: this.getStepClass(1), completed: this.currentStep > 1, failed: this.failedStep === -1 },
                { label: 'Additional Details', class: this.getStepClass(2), completed: this.currentStep > 2, failed: this.failedStep === -2 },
                { label: 'Request Creation', class: this.getStepClass(3), completed: this.currentStep > 3, failed: this.failedStep === -3 },
            ];
        } else if (this.calloutFrom === 'Account') {
            this._steps = [
                { label: 'Product Selection', class: this.getStepClass(1), completed: this.currentStep > 1, failed: this.failedStep === -1 },
                { label: 'Case Details', class: this.getStepClass(2), completed: this.currentStep > 2, failed: this.failedStep === -2 },
                { label: 'Additional Details', class: this.getStepClass(3), completed: this.currentStep > 3, failed: this.failedStep === -3 },
                { label: 'Request Creation', class: this.getStepClass(4), completed: this.currentStep > 4, failed: this.failedStep === -4 },
            ];
        }
    }

    /****************************************************************************************** 
     * Determines the class for the current step.
     * @param {number} stepNumber - The current step number.
    ******************************************************************************************/
    getStepClass(stepNumber) {
        if (this.failedStep === -stepNumber) {
            return 'step failed';
        }
        if (this.currentStep > stepNumber) {
            return 'step completed';
        }
        if (this.currentStep === stepNumber) {
            return 'step active';
        }
        return 'step';
    }

    /****************************************************************************************** 
     * Handles step change.
    ******************************************************************************************/
    handleStepChange() {
        this.calculateSteps();
    }

    /****************************************************************************************** 
     * Advances to the next step.
    ******************************************************************************************/
    nextStep() {
        if (this.currentStep < 6) {
            this.currentStep += 1;
        }
        this.handleStepChange();
    }

    /****************************************************************************************** 
     * Goes back to the previous step.
    ******************************************************************************************/
    prevStep() {
        if (this.currentStep < 6) {
            this.currentStep -= 1;
        }
        this.handleStepChange();
    }

    /****************************************************************************************** 
     * Handles error during the step transition.
    ******************************************************************************************/
    handleError() {
        this.failedStep = (-1 * this.currentStep);
        this.handleStepChange();
        this.caseCreationSpinner = false;
        this.accountLevelCaseCreation = false;
        this.productSection = false;
        this.environmentSection = false;
        this.caseCreationSection = false;
        this.errorScreen = true;
        this.isflowReady - false;
        const event = new ShowToastEvent({
            label: 'Error',
            message: this.labels.ErrorMessage,
            variant: 'Error',
            mode: 'dismissible'
        });
        this.dispatchEvent(event);
    }

    /****************************************************************************************** 
     * Initializes component state on connection.
    ******************************************************************************************/
    connectedCallback() {
        this.template.addEventListener('allflowsfinished', this.handleAllFlowsFinished.bind(this));
        this.prevScreen = this.currentScreen;
        this.currentScreen = 'ConnectedCallback';
        this.accountCalledConnectedBack = true;
        if (this.recordId !== undefined) {
            this.checkForAccess();
        } else {
            this.calloutFrom = 'AAQ';
            var inputVariables = [
                {
                    name: 'CalloutFrom',
                    type: 'String',
                    value: 'AAQ'
                },
                {
                    name: 'CurrentScreenOfLWC',
                    type: 'String',
                    value: 'ConnectedCallback'
                }];
            this.lanchFlow(inputVariables);
            this.productSection = true;
        }
    }

    /****************************************************************************************** 
     * Executes logic after component rendering.
    ******************************************************************************************/
    renderedCallback() {
        if (this.readyToRender) {
            this.handleAllFlowsFinished();
            this.readyToRender = false;
        }
    }

    /****************************************************************************************** 
     * Launches a flow with provided input variables.
     * @param {array} inputVariables - The input variables for the flow.
    ******************************************************************************************/
    lanchFlow(inputVariables) {
        this.inputVariables = inputVariables;
        this.isflowReady = true;
    }

    /****************************************************************************************** 
     * Handles flow status change events.
     * @param {object} event - The event object containing flow status.
    ******************************************************************************************/
    handleStatusChange(event) {
        console.log(event.detail.status); // DON'T DELETE

        var output = (event.detail.outputVariables);
        output.forEach(currentItem => {
            if (currentItem.name === "errorMessage" && currentItem.value !== null && currentItem.value !== undefined) {
                this.errorMessage = this.formatErrorMessage(currentItem.value);
                this.unexpectedError = true;
                this.isflowReady = false;
                if (this.errorMessage.includes(this.retryMessage)) {
                    this.retry = true;
                    this.retryCount++;
                }
            } else if (currentItem.name === 'ICS_Labels' && currentItem.value !== null && currentItem.value !== undefined) {
                let labels = {};
                currentItem.value.forEach(label => {
                    labels[label.Name] = label.Value__c;
                });
                this.labels = labels;
            }
        });

        if (this.retry && this.retryCount < MAX_RETRIES) {
            setTimeout(
                this.lanchFlow(this.inputVariables)
                , '2000'
            );
            this.retry = false;
            return;
        }

        if (!this.unexpectedError) {
            if (event.detail.status === "ERROR" || event.detail.status === "Error") {
                this.handleError();
            } else if (this.currentScreen === 'ConnectedCallback' && this.calloutFrom === 'Account' && event.detail.status === "STARTED") {
                this.multipleAccount = true;
                this.handleStepChange();
            } else if (this.currentScreen === 'SearchProductScreen' && this.calloutFrom === 'Account' && event.detail.status === "FINISHED_SCREEN") {
                var output = (event.detail.outputVariables);
                output.forEach(currentItem => {
                    if (currentItem.name === 'productForAccount') {
                        this.searchProductForAccount = currentItem.value;
                    }
                });
                this.setSearchProductList();
                this.prodSpinner = false;
                this.inputVariables = null;
            } else if (this.currentScreen === 'ConnectedCallback' && this.calloutFrom === 'Account' && (event.detail.status === "FINISHED" || event.detail.status === "FINISHED_SCREEN")) {
                var output = (event.detail.outputVariables);
                output.forEach(currentItem => {
                    this.flowOutputVariable[currentItem.name] = currentItem.value;
                });
                this.handleMutltipleContact();
                this.inputVariables = null;
                if (this.multipleAccount) {
                    this.nextStep();
                }
                this.accountCalledConnectedBack = false;
                this.isAccountCalled = true;
            } else if (this.currentScreen === 'CreateEnvironmentDetail' && event.detail.status === "FINISHED_SCREEN" && this.currentIndex !== 0) {
                if (this.currentIndex < this.environmentQuestionAnswerSelected.length) {
                    this.handleEnvironmentDetailExecution();
                } else {
                    this.readyToRender = false;
                    this.caseCreationSpinner = false;
                    this.caseCreationCreated = true;
                    this.disableButton = false;
                    this.isflowReady = false;
                    this.nextStep();
                    this.inputVariables = null;
                }
            } else if (this.currentScreen === 'ConnectedCallback' && event.detail.status === "FINISHED_SCREEN" && this.calloutFrom === 'AAQ') {
                var output = (event.detail.outputVariables);
                output.forEach(currentItem => {
                    this.flowOutputVariable[currentItem.name] = currentItem.value;
                });
                this.handleFirstScreen();
                this.inputVariables = null;
            } else if (this.currentScreen === 'ProductSelected' && event.detail.status === "FINISHED_SCREEN") {
                var output = (event.detail.outputVariables);
                output.forEach(currentItem => {
                    if (currentItem.name === 'ICSEnvironmentDetailQuestion') {
                        this.environmentDetailQuestion = currentItem.value;
                    } else if (currentItem.name === 'ICSEnvironmentDetailAnswer') {
                        this.environmentAnswerQuestion = currentItem.value;
                    } else if (currentItem.name === 'productExternalId') {
                        this.caseProductId = currentItem.value;
                    }
                });
                this.setEnvironmentQuestionAnswer();
                this.inputVariables = null;
            } else if (this.currentScreen === 'CaseCreationRequest' && event.detail.status === "FINISHED_SCREEN") {
                var output = (event.detail.outputVariables);
                output.forEach(currentItem => {
                    if (currentItem.name === "newCase") {
                        this.newCaseId = currentItem.value.Id;
                    } else if (currentItem.name === "errorMessage") {
                        this.errorMessage = currentItem.value;
                    }
                });

                if (this.newCaseId === null || this.newCaseId === undefined) {
                    this.handleError();
                } else {
                    if (this.currentIndex < this.environmentQuestionAnswerSelected.length) {
                        this.handleEnvironmentDetailExecution();
                    } else {
                        this.readyToRender = false;
                        this.caseCreationSpinner = false;
                        this.caseCreationCreated = true;
                        this.disableButton = false;
                        this.isflowReady = false;
                        this.nextStep();
                        this.inputVariables = null;
                    }
                }
            }
        } else {
            this.handleError();
        }

    }

    /****************************************************************************************** 
    * Shows user if its an existing user or new account will create.
    * @param {}.
   ******************************************************************************************/
    handleFirstScreen() {
        if (this.flowOutputVariable.numExternalContacts === 1) {
            this.haveExternalContact = true;
            const event = new ShowToastEvent({
                label: 'Information',
                message: this.labels.ExistingContact,
                variant: 'info',
                mode: 'dismissible'
            });
            this.dispatchEvent(event);
        } else if (this.flowOutputVariable.numExternalContacts === 0) {
            const event = new ShowToastEvent({
                label: 'Information',
                message: this.labels.NewContact,
                variant: 'info',
                mode: 'dismissible'
            });
            this.dispatchEvent(event);
        }
        this.isflowReady = false;
        this.disableButton = false;
    }

    /****************************************************************************************** 
     * Handles subject value.
     * @param {event}. contains the value of subject
    ******************************************************************************************/
    handleSubject(event) {
        this.caseSubject = event.target.value;
    }

    /****************************************************************************************** 
     * Handles description value.
     * @param {event}. contains the value of description
    ******************************************************************************************/
    handleDescription(event) {
        this.caseDesc = event.target.value;
    }

    /****************************************************************************************** 
    * Handles next screen functionality.
    * @param {}.
   ******************************************************************************************/
    handleNext() {
        this.selectedProductOption = this.selectedProductOption === null || this.selectedProductOption === undefined ? this.modalheader : this.selectedProductOption;
        let validateSubject = (this.validate('input'));
        if (!validateSubject.isValid) {
            return;
        }

        let validateDesc = (this.validate('textarea'));
        if (!validateDesc.isValid) {
            return;
        }
        
        this.disableButton = true;
        this.prevScreen = this.currentScreen;
        this.currentScreen = 'ProductSelected';
        var inputVariables;
        if (this.isProductExternalPresent) {
            inputVariables = [
                {
                    name: 'CalloutFrom',
                    type: 'String',
                    value: 'ExternalId'
                },
                {
                    name: 'CurrentScreenOfLWC',
                    type: 'String',
                    value: 'ProductSelected'
                },
                {
                    name: 'productExternalId',
                    type: 'String',
                    value: this.selectedProductOption
                },
                {
                    name: 'serviceContactLanguage',
                    type: 'String',
                    value: this.contactDefaultLanguage
                }];
        } else {
            inputVariables = [
                {
                    name: 'CalloutFrom',
                    type: 'String',
                    value: 'ExternalId'
                },
                {
                    name: 'CurrentScreenOfLWC',
                    type: 'String',
                    value: 'ProductSelected'
                },
                {
                    name: 'SelectedOption',
                    type: 'String',
                    value: this.selectedProductOption
                },
                {
                    name: 'serviceContactLanguage',
                    type: 'String',
                    value: this.flowOutputVariable.serviceContactLanguage
                }];
        }
        this.lanchFlow(inputVariables);
        this.nextStep();
        this.productSection = false;
        this.environmentSection = true;
    }

    /****************************************************************************************** 
     * Handles modal close based on from where it executed.
     * @param {}
     ******************************************************************************************/
    handleModalClose() {
        this.ismodal = false;
        this.dispatchEvent(new CustomEvent('closemodal'));
        if (this.recordId !== undefined) {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    /****************************************************************************************** 
     * Create a map of environment question and answer 
     * @param {}.
    ******************************************************************************************/
    setEnvironmentQuestionAnswer() {
        this.isflowReady = false;
        this.disableButton = false;
        this.phoneNumber = this.flowOutputVariable.serviceContactPhone;
        this.isContact = true;
        if (this.environmentDetailQuestion === null) {
            return;
        }

        var mapOfQuestionAnswer = [];
        this.environmentDetailQuestion.forEach(question => {
            const questionId = question.ExternalId;

            let setQuestion = {
                questionId: questionId,
                answer: ''
            };

            this.environmentQuestionAnswerSelected.push(setQuestion);

            let objectOfAnswer = {
                required: question.Required_for_Customer_c__c,
                externalId: question.ExternalId,
                question: question.Question_c__c,
                typeTextArea: question.Field_Type_c__c === 'TextArea' ? true : false,
                typeTextBox: question.Field_Type_c__c === 'TextBox' ? true : false,
                typePicklist: question.Field_Type_c__c === 'PickList' ? true : false,
                answers: []
            };
            if (this.environmentAnswerQuestion !== null) {
                this.environmentAnswerQuestion.forEach(ans => {
                    if (ans.Environment_Detail_Question_c__c === questionId) {
                        objectOfAnswer.answers.push({
                            value: ans.Answer_c__c,
                            label: ans.Answer_c__c
                        });
                    }
                });
            }

            mapOfQuestionAnswer.push(objectOfAnswer);
        });

        this.mapOfQuestionAnswer = mapOfQuestionAnswer;
    }

    /****************************************************************************************** 
     * Create case with user inputs 
     * @param {event}. Not using the params
    ******************************************************************************************/
    handleCaseCreation(event) {
        this.disableButton = true;
        this.caseCreationSpinner = true;
        let validateAddQuestion = (this.validate('lightning-combobox'));
        if (!validateAddQuestion.isValid) {
            this.disableButton = false;
            return;
        }

        validateAddQuestion = (this.validate('lightning-input'));
        if (!validateAddQuestion.isValid) {
            this.disableButton = false;
            return;
        }

        this.nextStep();
        this.productSection = false;
        this.environmentSection = false;
        this.caseCreationSection = true;
        this.prevScreen = this.currentScreen;
        this.currentScreen = 'CaseCreationRequest';
        let caseProductId = this.caseProductId;//this.environmentDetailQuestion === null || this.environmentDetailQuestion === undefined ? this.selectedProductOption : this.environmentDetailQuestion[0].Product_c__c;
        var inputVariables = [
            {
                name: 'CurrentScreenOfLWC',
                type: 'String',
                value: 'CaseCreationRequest'
            },
            {
                name: 'serviceAccountId',
                type: 'String',
                value: this.flowOutputVariable.serviceAccountId
            },
            {
                name: 'serviceContactId',
                type: 'String',
                value: this.flowOutputVariable.serviceContactId
            },
            {
                name: 'caseDesc',
                type: 'String',
                value: this.caseDesc
            },
            {
                name: 'caseSubject',
                type: 'String',
                value: this.caseSubject
            },
            {
                name: 'caseProductId',
                type: 'String',
                value: caseProductId
            },
            {
                name: 'caseSeverity',
                type: 'String',
                value: this.caseSeverityLevel.toString()
            },
            {
                name: 'serviceContactPhone',
                type: 'String',
                value: this.phoneNumber
            }
        ];

        this.lanchFlow(inputVariables);
    }

    /****************************************************************************************** 
     * validate user data if they filled the required details
     * @param {input}. contains the name of tag which needs to validate
    ******************************************************************************************/
    validate(input) {
        if (this.doInputValidation(input)) {
            return { isValid: true };
        } else {
            return {
                isValid: false,
                errorMessage: 'Please fill required fields.'
            };
        }
    }

    /****************************************************************************************** 
     * Validate value based using standarad functionlity 
     * @param {input}. contains the name of tag which needs to validate
    ******************************************************************************************/
    doInputValidation(input) {
        return [
            ...this.template.querySelectorAll(input),
        ].reduce((validSoFar, inputCmp) => {
            if (inputCmp.type === 'tel') {
                const phoneRegex = new RegExp(this.labels.PatternForContact);
                const isValidPhone = phoneRegex.test(inputCmp.value);
                if (isValidPhone) {
                    inputCmp.setCustomValidity('');
                } else {
                    inputCmp.setCustomValidity('Invalid phone number format.');
                }
            }
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

    }

    /****************************************************************************************** 
     * Funtion to create environment detail record for case
     * @param {}.
    ******************************************************************************************/
    handleEnvironmentDetailExecution() {
        this.isflowReady = false;
        this.prevScreen = this.currentScreen;
        this.currentScreen = 'CreateEnvironmentDetail';
        if (this.currentIndex < this.environmentQuestionAnswerSelected.length) {
            const item = this.environmentQuestionAnswerSelected[this.currentIndex];
            var inputVariables = [
                {
                    name: 'CurrentScreenOfLWC',
                    type: 'String',
                    value: 'CreateEnvironmentDetail'
                },
                {
                    name: 'caseIdForEnvironment',
                    type: 'String',
                    value: this.newCaseId
                },
                {
                    name: 'questionIdForEnvironment',
                    type: 'String',
                    value: item.questionId
                },
                {
                    name: 'answerForEnvironment',
                    type: 'String',
                    value: item.answer
                }
            ];
            this.inputVariables = inputVariables;
            const allFlowsFinishedEvent = new CustomEvent('allflowsfinished');
            this.dispatchEvent(allFlowsFinishedEvent);
            this.readyToRender = true;
        }
    }

    /****************************************************************************************** 
     * Handles the completion of all flows.
     * @param {object} event - The event object containing flow details.
    ******************************************************************************************/
    handleAllFlowsFinished() {
        this.lanchFlow(this.inputVariables);
        this.currentIndex++;
    }

    /****************************************************************************************** 
     * Handles navigation to specific record
     * @param {} 
    ******************************************************************************************/
    handleNavigation() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                "recordId": this.newCaseId,
                "objectApiName": "Case__x",
                "actionName": "view"
            },
        });

    }

    /****************************************************************************************** 
     * Handles changes made on additional details section
     * @param {event} - pass the targeted event
    ******************************************************************************************/
    handleChange(event) {
        let checker = true;
        if (this.environmentQuestionAnswerSelected.length === 0) {
            let objectOfAnswer = {
                questionId: event.target.dataset.questionid,
                answer: event.detail.value
            };
            this.environmentQuestionAnswerSelected.push(objectOfAnswer);
        } else {
            this.environmentQuestionAnswerSelected.forEach(item => {
                if (item.questionId === event.target.dataset.questionid) {
                    item.answer = event.detail.value;
                    checker = false;
                }
            })
            if (checker) {
                let objectOfAnswer = {
                    questionId: event.target.dataset.questionid,
                    answer: event.detail.value
                };
                this.environmentQuestionAnswerSelected.push(objectOfAnswer);
            }
        }
    }

    /****************************************************************************************** 
     * Handles mutiple contact if exist in service cloud system
     * @param {}.
    ******************************************************************************************/
    handleMutltipleContact() {
        this.isflowReady = false;
        var contactList = this.flowOutputVariable.contactRecordSet;
        var mapOfContactWithExternalId = [];
        if (contactList === null || contactList === undefined) {
            this.isAccountAsscoiated = false;
            this.accessErrorMessageOrNoServiceMessageTagged = this.labels.NoServiceCloud;
        } else {
            contactList.forEach(contact => {
                let objectOfContact = {
                    value: contact.ExternalId,
                    label: contact.Name__c,
                    phone: contact.Phone__c,
                    email: contact.Email__c,
                    language: contact.Core_Language_c__c
                };
                mapOfContactWithExternalId.push(objectOfContact);
            });
            this.contactSection = true;
            this.mapOfContactWithExternalId = mapOfContactWithExternalId;
        }

    }

    /****************************************************************************************** 
     * Handles the contact selection when there mutiple contact exist for the account
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handleContactSelection(event) {
        this.flowOutputVariable.serviceContactId = event.detail.value;
        this.mapOfContactWithExternalId.forEach(contact => {
            if (this.flowOutputVariable.serviceContactId === contact.value) {
                this.flowOutputVariable.serviceContactPhone = contact.phone;
                if (this.calloutFrom === 'Account') {
                    this.emailAddress = contact.email;
                    this.contactDefaultLanguage = contact.language;
                }
            }
        })
    }

    /****************************************************************************************** 
     * Handles the keyword for product search
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handleInputChange(event) {
        this.productSerchText = event.detail.value;
    }

    /****************************************************************************************** 
     * Handles the keyword for product search
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handleSearch() {
        this.prodSpinner = true;
        this.prevScreen = this.currentScreen;
        this.currentScreen = 'SearchProductScreen';
        if (this.productSerchText.length > 3) {
            var inputVariables = [
                {
                    name: 'CalloutFrom',
                    type: 'String',
                    value: 'Account'
                },
                {
                    name: 'CurrentScreenOfLWC',
                    type: 'String',
                    value: 'ProductSelected'
                },
                {
                    name: 'SelectedOption',
                    type: 'String',
                    value: this.productSerchText
                }];
            this.lanchFlow(inputVariables);
        }
    }

    /****************************************************************************************** 
     * Set the search product with specific label and value in the combo-box
     * @param {}.
    ******************************************************************************************/
    setSearchProductList() {
        this.isflowReady = false;
        this.mapOfSearchProductWithExternalId = [];
        var mapOfSearchProductWithExternalId = [];
        if (this.searchProductForAccount !== null) {
            this.searchProductForAccount.forEach(product => {
                let objectOfContact = {
                    value: product.ExternalId,
                    label: product.Name__c,
                    severity: product.Severity_c__c,
                    subscription: product.ICS_Is_Enabled_For_Subscriptions_c__c
                };
                mapOfSearchProductWithExternalId.push(objectOfContact);
            });
            this.mapOfSearchProductWithExternalId = mapOfSearchProductWithExternalId;
            this.productSearch = true;
        } else {
            const event = new ShowToastEvent({
                label: 'Information',
                message: this.labels.ProductNotExist,
                variant: 'info',
                mode: 'dismissible'
            });
            this.dispatchEvent(event);
            this.prodSpinner = false;
        }
    }

    /****************************************************************************************** 
     * Handles the final product selection for case creation
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handleFinalProduct(event) {
        this.selectedProductOption = event.detail.value;
        this.mapOfSearchProductWithExternalId.forEach(prod => {
            if (prod.value === this.selectedProductOption) {
                this.isSeverity = prod.severity;
                this.isProductExternalPresent = true;
            }
        })
        this.disableButton = false
    }

    /****************************************************************************************** 
     * Move forward from product section
     * @param {}
    ******************************************************************************************/
    handleProduct() {
        this.accountLevelCaseCreation = false;
        this.productSection = true;
        this.nextStep();
        this.disableButton = false;
    }

    /****************************************************************************************** 
     * Handle the phone number change, if user is updating it
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handlePhoneNumberChange(event) {
        this.phoneNumber = event.detail.value;
        this.disableButton = false;
    }

    /****************************************************************************************** 
     * Based on product set the severity level
     * @param {event} - passing the current targeted value
    ******************************************************************************************/
    handleSeverityChange(event) {
        this.caseSeverityLevel = event.detail.value;
    }

    /****************************************************************************************** 
     * Handle the previous screen
     * @param {}.
    ******************************************************************************************/
    handleBackFunctionality() {
        if (this.currentScreen === 'ProductSelected' && this.productSection === false) {
            this.currentScreen = this.prevScreen;
            this.productSection = true;
            this.environmentSection = false;
            this.prevStep();
        } else if (this.currentScreen === 'SearchProductScreen' && this.accountLevelCaseCreation === false) {
            this.currentScreen = this.prevScreen;
            this.productSection = false;
            this.accountLevelCaseCreation = true;
            this.prevStep();
        }
    }

    /****************************************************************************************** 
     * Format the error message for in a human readable format
     * @param {errorMessage} - contain the error message
    ******************************************************************************************/
    formatErrorMessage(errorMessage) {
        errorMessage = errorMessage.replaceAll('\\', '');
        const patterns = {
            generalError: /This error occurred when the flow tried to create records: ([^:]*):\s*(.*?)(?: Error received from the external system:|$)/,
            errorDetails: /Error received from the external system: (.*?)(?: You can look up ExceptionCode values in the|$)/,
            soapApiLink: /You can look up ExceptionCode values in the <a href='(.*?)'>SOAP API Developer Guide<\/a>/
        };

        let cleanedMessage = '';

        // Extract general error message
        const generalErrorMatch = errorMessage.match(patterns.generalError);
        if (generalErrorMatch) {
            cleanedMessage += `<strong>Error:</strong><br>${generalErrorMatch[1]}: ${generalErrorMatch[2]}<br><br>`;
        }

        // Extract and clean details of the error received from the external system
        const errorDetailsMatch = errorMessage.match(patterns.errorDetails);
        if (errorDetailsMatch) {
            cleanedMessage += `<strong>Details:</strong><br>${errorDetailsMatch[1]}<br><br>`;
        }

        // Extract and provide a link to the SOAP API Developer Guide
        const soapApiLinkMatch = errorMessage.match(patterns.soapApiLink);
        if (soapApiLinkMatch) {
            cleanedMessage += `<strong>For more information:</strong><br>Please refer to the <a href="${soapApiLinkMatch[1]}">SOAP API Developer Guide</a><br>`;
        } else {
            cleanedMessage += `<strong>For more information:</strong><br>Please refer to the SOAP API Developer Guide.<br>`;
        }

        cleanedMessage += `<br>Please try again later or contact IT support if the problem persists.<br>`;
        return cleanedMessage;
    }

    checkForAccess() {
        return hasAccess({ recordId: this.recordId, userId: USER_ID })
            .then((data, error) => {
                console.log(data);
                if (data === true) {
                    this.calloutFrom = 'Account';
                    this.modalheader = 'Create ICS Case';
                    this.ismodal = true;
                    var inputVariables = [
                        {
                            name: 'CalloutFrom',
                            type: 'String',
                            value: 'Account'
                        },
                        {
                            name: 'CurrentScreenOfLWC',
                            type: 'String',
                            value: 'ConnectedCallback'
                        },
                        {
                            name: 'recordId',
                            type: 'String',
                            value: this.recordId
                        }];
                    this.lanchFlow(inputVariables);
                    this.accountLevelCaseCreation = true;
                } else {
                    this.accessErrorMessageOrNoServiceMessageTagged = this.labels.NoAccessToAccount;
                    this.isAccountAsscoiated = false;
                }
            });
    }
}