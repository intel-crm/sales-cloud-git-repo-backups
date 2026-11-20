/* All Custom Labels */
import askQuestionHeadingLabel from '@salesforce/label/c.PMP_LeadGen_AskAQuestion';
import requestQuoteHeadingLabel from '@salesforce/label/c.PMP_LeadGen_RequestAQuote';
import thankYouLabel1 from '@salesforce/label/c.PMP_LeadGen_ThankYouQuoteNote1';
import thankYouLabel2 from '@salesforce/label/c.PMP_LeadGen_ThankYouQuoteNote2';
import volumeLabel from '@salesforce/label/c.PMP_LeadGen_Volume';
import deliveryDateLabel from '@salesforce/label/c.PMP_LeadGen_DeliveryDate';
import descriptionLabel from '@salesforce/label/c.PMP_LeadGen_Description';
import youAreContactingLabel from '@salesforce/label/c.PMP_LeadGen_YourAreContacting';
import whatWouldYouLikeToKnowLabel from '@salesforce/label/c.PMP_LeadGen_WhatWouldYouLikeToKnow';
import tellUsAboutYouLabel from '@salesforce/label/c.PMP_LeadGen_TellUsAboutYou';
import fieldsArePopulatedLabel from '@salesforce/label/c.PMP_LeadGen_FieldsArePopulated';
import requiredLabel from '@salesforce/label/c.PMP_LeadGen_Required';

// errors
import missingValueLabel from '@salesforce/label/c.PMP_LeadGen_CompleteThisField';
import invalidNameLabel from '@salesforce/label/c.PMP_Invalid_Name';
import deliveryDateBadLabel from '@salesforce/label/c.PMP_CTA_Delivery_Date';
import phoneCheckLabel from '@salesforce/label/c.PMP_Phone_NumberCheck';
import emailCheckLabel from '@salesforce/label/c.PMP_CTA_Email_Validation';
import noHTMLLabel from '@salesforce/label/c.PMP_Invalid_Notes';
import noURLLabel from '@salesforce/label/c.PMP_Invalid_Notes_URL';

// inputs
import firstNameLabel from '@salesforce/label/c.PMP_LeadGen_FirstName';
import lastNameLabel from '@salesforce/label/c.PMP_LeadGen_LastName';
import jobFunctionLabel from '@salesforce/label/c.PMP_LeadGen_JobFunction';
import PartnerProfessionLabel from '@salesforce/label/c.PMP_LeadGen_PartnerProfession';
import companyNameLabel from '@salesforce/label/c.PMP_LeadGen_CompanyName';
import countryLabel from '@salesforce/label/c.PMP_LeadGen_Country';
import stateLabel from '@salesforce/label/c.PMP_LeadGen_State';
import phoneLabel from '@salesforce/label/c.PMP_LeadGen_Phone';
import emailLabel from '@salesforce/label/c.PMP_LeadGen_Email';
import chooseOneLabel from '@salesforce/label/c.PMP_LeadGen_ChooseOne';

import submitLabel from '@salesforce/label/c.PMP_LeadGen_Submit';
import submittedMsgLabel from '@salesforce/label/c.PMP_LeadGen_SubmittedMessage';
import closeLabel from '@salesforce/label/c.PMP_LeadGen_Close';
import cancelLabel from '@salesforce/label/c.PMP_Search_Cancel';

import termsLabel from '@salesforce/label/c.PMP_LeadGen_TermsConditions';
import termsUrlLabel from '@salesforce/label/c.Core_Intc_TermsAndConditionsUrl';
import privacyLabel from '@salesforce/label/c.PMP_LeadGen_PrivacyPolicy';
import privacyUrlLabel from '@salesforce/label/c.Core_Intc_PrivacyPolicyUrl';
import elqFormOptInLabel from '@salesforce/label/c.PMP_ELQ_Lead_Form_OPTIN';
import partnerShareLabel1 from '@salesforce/label/c.PMP_Share_To_Partner1';
import partnerShareLabel2 from '@salesforce/label/c.PMP_Share_To_Partner2';

import termsNoticeLabel from '@salesforce/label/c.PMP_LeadGen_TermsNotice';
import termsAriaLabel from '@salesforce/label/c.PMP_LeadGen_TermsAndConditions';

import inquiryProgressLabel from '@salesforce/label/c.PMP_Inquiry_Progress';
import submittedLabel from '@salesforce/label/c.PMP_LeadGen_Submitted';
import partnerReviewLabel from '@salesforce/label/c.PMP_LeadGen_PartnerReview';
import partnerRespondLabel from '@salesforce/label/c.PMP_LeadGen_PartnerRespond';

import maxCharLimitLabel from '@salesforce/label/c.PMP_Maximum_Character_Limit_Msg';
import charsRemainingDescriptionLabelDynamic from '@salesforce/label/c.PMP_Description_Characters_Remaining';

export const insertLabelValue = (label, value) => label.replace('{0}', value);

export const labels = {
  errors: {
    missing: missingValueLabel,
    deliveryDate: deliveryDateBadLabel,
    invalidName: invalidNameLabel,
    phoneCheck: phoneCheckLabel,
    emailCheck: emailCheckLabel,
    noHTML: noHTMLLabel,
    noURL: noURLLabel,
  },
  askQuestion: {
    heading: askQuestionHeadingLabel,
    youAreContacting: youAreContactingLabel,
    whatWouldYouLikeToKnow: whatWouldYouLikeToKnowLabel,
  },
  requestQuote: {
    heading: requestQuoteHeadingLabel,
    thankYou: thankYouLabel1,
    thankYou2: thankYouLabel2,
    volume: volumeLabel,
    deliveryDate: deliveryDateLabel,
    description: descriptionLabel,
  },
  tellUsAboutYou: tellUsAboutYouLabel,
  fieldsArePopulated: fieldsArePopulatedLabel,
  required: requiredLabel,

  // form inputs
  firstName: firstNameLabel,
  lastName: lastNameLabel,
  jobFunction: jobFunctionLabel,
  profession: PartnerProfessionLabel,
  companyName: companyNameLabel,
  country: countryLabel,
  state: stateLabel,
  phone: phoneLabel,
  email: emailLabel,
  chooseOne: chooseOneLabel,
  // buttons
  cancel: cancelLabel,
  submit: submitLabel,
  submittedMsg: submittedMsgLabel,
  close: closeLabel,

  // terms and conditions
  termsAria: termsAriaLabel,
  termsAndConditions: termsLabel,
  termsAndConditionsUrl: termsUrlLabel,
  termsNotice: termsNoticeLabel, // extra notice
  elqOptIn: elqFormOptInLabel,
  partnerInfoShare1: partnerShareLabel1,
  partnerInfoShare2: partnerShareLabel2,

  // privacy notice
  privacyPolicy: privacyLabel,
  privacyPolicyUrl: privacyUrlLabel,

  // progress
  inquiryProgress: inquiryProgressLabel,
  submitted: submittedLabel,
  partnerReview: partnerReviewLabel,
  partnerRespond: partnerRespondLabel,

  charLimits: {
    description: charsRemainingDescriptionLabelDynamic,
    volume: insertLabelValue(maxCharLimitLabel, 35),
    firstName: insertLabelValue(maxCharLimitLabel, 100),
    lastName: insertLabelValue(maxCharLimitLabel, 100),
    companyName: insertLabelValue(maxCharLimitLabel, 100),
  },
};