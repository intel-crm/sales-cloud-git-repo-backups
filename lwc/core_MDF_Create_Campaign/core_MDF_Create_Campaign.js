import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType, getPicklistValues, getObjectInfos } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import Core_MDF_DisabledFieldsOnCampaignUI_CSS from '@salesforce/resourceUrl/Core_MDF_DisabledFieldsOnCampaignUI_CSS';
import CAMPAIGN_OBJECT from '@salesforce/schema/Campaign';
import getObjectFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.getObjectFields';
import getAccPropBasedValues from '@salesforce/apex/Core_MDF_CampaignCreatePage.getAccPropBasedValues';
import getBudgetType from '@salesforce/apex/Core_MDF_CampaignCreatePage.getBudgetType';
import getAccSpecificBudgetTypes from '@salesforce/apex/Core_MDF_CampaignCreatePage.getAccSpecificBudgetTypes';
import saveCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.saveCampaign';
import loadCampaignRecord from '@salesforce/apex/Core_MDF_CampaignCreatePage.loadRecord';
import getFieldEditibilityMapping from '@salesforce/apex/Core_MDF_CampaignCreatePage.getFieldEditibilityMapping';
import getActivityFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.getActivityFields';
import geoToCountryMappingValueConnectedCallBack from '@salesforce/apex/Core_MDF_CampaignCreatePage.geoToCountryMappingValueConnectedCallBack';
import checkClaimsAssociatedToCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.checkClaimsAssociatedToCampaign';
import ipaCampCreate from './core_MDF_IPA_Campaign.html'; import rmfCampCreate from './core_MDF_RMF_Campaign.html';
import opalCCFCampCreate from './core_MDF_CCF_Campaign.html';
import opalDCFCampCreate from './core_MDF_DCF_Campaign.html';
import Core_MDF_Save from "@salesforce/label/c.Core_MDF_Save";
import Core_MDF_Cancel from "@salesforce/label/c.Core_MDF_Cancel";
import Core_MDF_Country_Filter from "@salesforce/label/c.Core_MDF_Country_Filter";
import Core_MDF_PFR_None_Translation from "@salesforce/label/c.Core_MDF_PFR_None_Translation";
import applicationErrorMsg from "@salesforce/label/c.Core_MDF_ApplicationErrorMessage";
import Core_MDF_IPA_Others_Message from "@salesforce/label/c.Core_MDF_IPA_Others_Message";
import Core_MDF_Chosen_Label from "@salesforce/label/c.Core_MDF_Chosen_Label";
import Core_MDF_Available_Label from "@salesforce/label/c.Core_MDF_Available_Label";
import Core_MDF_NewCampaign_Label from "@salesforce/label/c.Core_MDF_NewCampaign_Label";
import Core_MDF_Edit from "@salesforce/label/c.Core_MDF_Edit";
import getBudgetsForCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.getBudgetsForCampaign';
import Core_MDF_CCF_Budget_Warning_Message from "@salesforce/label/c.Core_MDF_CCF_Budget_Warning_Message";
import Core_MDF_DCF_Budget_Warning_Message from "@salesforce/label/c.Core_MDF_DCF_Budget_Warning_Message";
import Core_MDF_No_Available_Budgets_Warning from "@salesforce/label/c.Core_MDF_No_Available_Budgets_Warning";
import getCampaignBudgetsForCampaign from '@salesforce/apex/Core_MDF_CampaignCreatePage.getCampaignBudgetsForCampaign';
import Core_MDF_IPA_Initiave_None_Selection_Error from '@salesforce/label/c.Core_MDF_IPA_Initiave_None_Selection_Error';
import Core_MDF_OPAL_BudgetTypes from "@salesforce/label/c.Core_MDF_OPAL_BudgetTypes";
import Core_MDF_ExternalVisibilityError from '@salesforce/label/c.Core_MDF_ExternalVisibilityError';
import Core_MDF_CCF_RecordTypeName from "@salesforce/label/c.Core_MDF_CCF_RecordTypeName";
import Core_MDF_DCF_RecordTypeName from "@salesforce/label/c.Core_MDF_DCF_RecordTypeName";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Core_MDF_Campaign_Budgets_Error from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Error";
import Core_MDF_Available_Budgets_Label from "@salesforce/label/c.Core_MDF_Available_Budgets_Label";
import Core_MDF_Retail_Record_Type_Developer_Name from '@salesforce/label/c.Core_MDF_Retail_Record_Type_Developer_Name';
import Core_MDF_IPA_RecordType from '@salesforce/label/c.Core_MDF_IPA_RecordType';
import Core_MDF_EEF_RecordType from '@salesforce/label/c.Core_MDF_EEF_RecordType';
import Core_MDF_Retail_Program_Name from '@salesforce/label/c.Core_MDF_Retail_Program_Name';
import Core_MDF_IPA_Program_Name from '@salesforce/label/c.Core_MDF_IPA_Program_Name';
import Core_MDF_Localized_IPA_Name from '@salesforce/label/c.Core_MDF_Localized_IPA_Name';
import getBudgetsOnActiveActivities from '@salesforce/apex/Core_MDF_CampaignCreatePage.getBudgetsOnActiveActivities';
import Core_MDF_budgetTypeRRValuesMap from '@salesforce/label/c.Core_MDF_budgetTypeRRValuesMap';
import Core_MDF_CampaignBudgets_ErrMsg from '@salesforce/label/c.Core_MDF_CampaignBudgets_ErrMsg';
import loadDynamicFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.loadDynamicFields';
import Core_MDF_Multiple_Countries_Soft_Msg from '@salesforce/label/c.Core_MDF_Multiple_Countries_Soft_Msg';
import Core_MDF_Multi_Geo_Error from '@salesforce/label/c.Core_MDF_Country_Multiple_Geo_Error';
import Core_MDF_Activity_Type from '@salesforce/label/c.Core_MDF_Activity_Type';
import Core_MDF_Start_Date from "@salesforce/label/c.Core_MDF_Start_Date"; import rmfRecTypeNm from '@salesforce/label/c.Core_MDF_RetailProgram';
import Core_MDF_End_Date from "@salesforce/label/c.Core_MDF_End_Date";
import Core_MDF_StartEndDate_Soft_Msg from "@salesforce/label/c.Core_MDF_StartEndDate_Soft_Msg";
import noneSelErrRMFTechnology from "@salesforce/label/c.Core_MDF_RMF_None_Selection_Error";
import Core_MDF_KpiSection_Label from "@salesforce/label/c.Core_MDF_KpiSection_Label";
import campaignDateRangeErr from "@salesforce/label/c.Core_MDF_Campaign_Date_Check_Error";
import Core_MDF_Activity_Note from "@salesforce/label/c.Core_MDF_Activity_Note";
import Core_MDF_Activity_Event_60_Days from "@salesforce/label/c.Core_MDF_Activity_Event_60_Days";
import Core_MDF_60DaysMoreThan_50K from "@salesforce/label/c.Core_MDF_60DaysMoreThan_50K";
import Core_MDF_ManagerApprovalThreshold from "@salesforce/label/c.Core_MDF_ManagerApprovalThreshold";
import Core_MDF_Proposal_EndDate_ErrMsg from '@salesforce/label/c.Core_MDF_Proposal_EndDate_ErrMsg';
import Core_MDF_Activity_Creation_Page_Header from '@salesforce/label/c.Core_MDF_Activity_Creation_Page_Header';
import fetchPicklist from './core_MDF_Create_Campaign_Helper.js';
import { checkActivityEventValidation, checkActivityInitiativeValidation, callingGeoToCountryMappingValue, getSIOrISVAccounts, handleISVAccountSelection, fetchCampToActPartnerData, calReimbursementAmt, handleDateChange, handlePicklistDependentValueChangeEdits, fetchActivityCategoryTypeValues, getValuesRefOnActivities, retainAndUpdateCampaignBudgetsOldMap, resetOrRollbackPriority2Or3, handlePriorityNoneValueSelection, updateOutcomeFieldVisibility,handleOEMDateChange } from './core_MDF_Create_Campaign_Helper.js';
import { handleServerExceptionsName, validateOpportunityId, budgetDataWrapperMDF, budgetDataWrapper, validatePicklistvalues, localizeCountrymap, campFieldAPINametoPFRFieldAPIName, checkForUndefinedEmptyAndNull, validatePickListValuesBasedOnFC, lovValuesAddition, validateSelectedBudgets, getBudgetNameString, getObjectFieldDetails, prepActClassificationMapBasedOnActType, getPFRFieldsDependency, valMandateInpFldsOnActivity, getPFRActCategoryAndTypeDependency, getpicklistSize } from './core_MDF_Create_Campaign_Helper.js';
import { addExistingReimbursementRate } from 'c/core_MDF_utilityModule';
import Core_MDF_SPIF_Activity_Types from '@salesforce/label/c.Core_MDF_SPIF_Activity_Types';
import Core_MDF_Complete_SPIF_Warning from '@salesforce/label/c.Core_MDF_Complete_SPIF_Warning';
import completeThisFieldErr from '@salesforce/label/c.Core_MDF_CompleteThisField_ErrorMessage';
import checkEditProposalAccess from '@salesforce/apex/Core_MDF_CampaignCreatePage.checkEditProposalAccess';
import getFieldSetName from '@salesforce/apex/Core_MDF_CampaignCreatePage.getFieldSetName';
import picklistValueRemovalErrorOnClone from '@salesforce/label/c.Core_MDF_IPA_Clone_PicklistValue_Removal_Error';
import picklistValueRemovalErrorOnCloneActivity from '@salesforce/label/c.Core_MDF_IPA_Clone_PicklistValue_Removal_Error_Activity';
import picklistValueRemovalErrorOnEdit from '@salesforce/label/c.Core_MDF_IPA_Edit_PicklistValue_Removal_Error';
import getFieldSets from '@salesforce/apex/Core_MDF_PartnerFundRequestCreatePage.loadDynamicFields';
import Core_MDF_MandatoryFieldsCheckOnProposal from '@salesforce/label/c.Core_MDF_MandatoryFieldsCheckOnProposal';
import Core_MDF_MandatoryFieldsCheck from '@salesforce/label/c.Core_MDF_MandatoryFieldsCheck';
import Core_MDF_IPA_NA_Message from "@salesforce/label/c.Core_MDF_IPA_NA_Message";
import Core_MDF_Intel_MDF_Fields from '@salesforce/label/c.Core_MDF_Intel_MDF_Fields';
import apitoLabelReference from '@salesforce/apex/Core_Intel_customPicklistController.apitoLabelReferenceCampaign';
import Core_MDF_Initiative_None_Selection_Error from '@salesforce/label/c.Core_MDF_Initiative_None_Selection_Error';
import Core_MDF_IPA_Others_Selection_Error from '@salesforce/label/c.Core_MDF_IPA_Others_Selection_Error';
import Core_MDF_NegativeInputWarningMsg from '@salesforce/label/c.Core_MDF_NegativeInputWarningMsg';
import campaignAccBasedBlank from '@salesforce/label/c.Core_MDF_Campaign_AccBased_Blank';
import Core_MDF_LegacyRestricBudgetTypes from '@salesforce/label/c.Core_MDF_LegacyRestricBudgetTypes';
import focusAreaDependentFields from '@salesforce/label/c.Core_MDF_Campaign_FocusArea_DependentFields';
import focusAreaDependentValueError from '@salesforce/label/c.Core_MDF_FocusArea_DependetValueSel_Error';
import campaignEndDateValidation from '@salesforce/label/c.Core_MDF_Campaign_EndDate_Validation'; import negativeInpValErr from '@salesforce/label/c.Core_MDF_CCF_DCF_ERROR';
import campaignSpanYearsValidation from '@salesforce/label/c.Core_MDF_Campaign_SpanOfYears_Validation';
import singleFocusAreaSelectionTextMessage from '@salesforce/label/c.Core_MDF_Single_FocusArea_Selection_Message';
import crossGeoCountrySelectionTextMessage from '@salesforce/label/c.Core_MDF_Cross_Geo_County_Selection_Message';
import partnerContactFieldValidation from '@salesforce/label/c.Core_MDF_Partner_Contact_FieldValidation';
import emptyFieldError from '@salesforce/label/c.Core_MDF_Empty_Field_Error';
import getConstants from '@salesforce/apex/Core_MDF_CCP_ConstantClass.getAllConstants';
import invalidOpportunityError from '@salesforce/label/c.Core_MDF_OpportunityID_Error';
import internalExternalCommentsCharLimit from '@salesforce/label/c.Core_MDF_Camp_InternalExternalComments_CharLimit';
import fullStop from '@salesforce/label/c.Core_MDF_Remove_Fields_Validation_OPAL';
import EEFCampCreate from './core_MDF_EEF_Campaign.html';
import errorMsgForTotalCampCostAmt from '@salesforce/label/c.Core_MDF_KPI_Quantity_Input_Error';
import noneSelErrIPACampEcosysPartner from "@salesforce/label/c.Core_MDF_IPA_None_Selection_Error";
import Core_MDF_CCF_Program_Name from '@salesforce/label/c.Core_MDF_NonTranslateCCFRecordType';
import Core_MDF_DCF_Program_Name from '@salesforce/label/c.Core_MDF_NonTranslateDCFRecordType';
import Core_MDF_EEF_Program_Name from '@salesforce/label/c.Core_MDF_EEF_Program_Name';
import blankMetricError from '@salesforce/label/c.Core_MDF_Blank_Metric_Error';
import blankTacticMetricError from '@salesforce/label/c.Core_MDF_Blank_TacticMetric_Error';
import Core_MDF_PartnerMap_Error_Msg from '@salesforce/label/c.Core_MDF_PartnerMap_Error_Msg';
import campaignStartYear from '@salesforce/label/c.Core_MDF_CampaignStartYear';
import Core_MDF_Co_GTM_RecordType from '@salesforce/label/c.Core_MDF_Co_GTM_RecordType';
import Core_MDF_Co_GTM_program_name from '@salesforce/label/c.Core_MDF_Co_GTM_program_name';
import Core_MDF_Co_GTM_Technical_program_name from '@salesforce/label/c.Core_MDF_Co_GTM_Technical_program_name';
import coGTMCampCreate from './core_MDF_GTM_Campaign.html';
import getCampaignContractLineItems from '@salesforce/apex/Core_MDF_CampaignCreatePage.getCampaignContractLineItems';
import getInternalAndExternalUsersByAccount from '@salesforce/apex/Core_MDF_CampaignCreatePage.getInternalAndExternalUsersByAccount';
import Core_MDF_Selected_Budgets from "@salesforce/label/c.Core_MDF_Selected_Budgets";
import Core_MDF_Campaign_Outcome_Validation from '@salesforce/label/c.Core_MDF_Campaign_Outcome_Validation';
import Core_MDF_Campaign_Purpose from '@salesforce/label/c.Core_MDF_Campaign_Purpose';
import clickHere from "@salesforce/label/c.Core_MDF_Click_here";
import outcomeSalesMarketingGuidebookLink from "@salesforce/label/c.Core_MDF_Outcome_Sales_Marketing_Link";
import outcomeSalesMarketingGuidebook from "@salesforce/label/c.Core_MDF_Outcome_Sales_Marketing_Guidebook";
import IncreaseBy from '@salesforce/label/c.Core_MDF_Increase_by';
import DecreaseBy from '@salesforce/label/c.Core_MDF_Decrease_by';
import outcomeStmtFrom from '@salesforce/label/c.Core_MDF_from';
import outcomeStmtTo from '@salesforce/label/c.Core_MDF_to_Ac';
import outcomeStmtFor from '@salesforce/label/c.Core_MDF_for';
import outcomeStmtAnd from '@salesforce/label/c.Core_MDF_and_Ac';
import outcomeStmtClosedBracket from '@salesforce/label/c.Core_MDF_CloseBracket';
import getCampaignOutcomes from '@salesforce/apex/Core_MDF_CampaignCreatePage.getCampaignOutcomes';
import campStartDtBudgetStartDtValErrMessage from "@salesforce/label/c.Core_MDF_Camp_StartDt_Budget_StartDt_Val_ErrMsg";
import getUserTodayDate from '@salesforce/apex/Core_MDF_CCP_GenericUtility.getUserTodayDate';
import coGTMCampaignStartDateValidation from '@salesforce/label/c.Core_MDF_CoGTM_Campaign_External_StartDate_Validation';
import Core_MDF_Campaign_Outcome_Based_Validation from '@salesforce/label/c.Core_MDF_Campaign_Outcome_Based_Validation';
import campaignIPAOutcomeConfigureDate from '@salesforce/label/c.Core_MDF_IPA_Outcome_Configure_Date';
import Core_MDF_Campaign_Budgets_Label from "@salesforce/label/c.Core_MDF_Campaign_Budgets_Label";
import Core_MDF_Non_OutcomeBased_Selection_Error from '@salesforce/label/c.Core_MDF_Non_OutcomeBased_Selection_Error';// Ealaya TWC3117-14432 Activity Category changes -->
import Core_MDF_AccountPlan_StartDate_Error from '@salesforce/label/c.Core_MDF_AccountPlan_StartDate_Error';
import Core_MDF_IPA_AccountBased_StartDate from '@salesforce/label/c.Core_MDF_IPA_AccountBased_StartDate';
import userLocale from '@salesforce/i18n/locale';
import Core_MDF_Activity_Purpose_Header from '@salesforce/label/c.Core_MDF_Activity_Purpose_Header';
// Roshan - Commented as part of TWC3117-18965
//import getDomainsForAccount from '@salesforce/apex/Core_MDF_CampaignCreatePage.getDomainsForAccount';
import Core_MDF_InvalidEmailError from '@salesforce/label/c.Core_MDF_InvalidEmailError';
//import Core_MDF_IntelDomainError from '@salesforce/label/c.Core_MDF_IntelDomainError';
//import Core_MDF_UnsupportedDomain_Error from '@salesforce/label/c.Core_MDF_UnsupportedDomain_Error';
//import Core_MDF_No_Approved_Domains_Error from '@salesforce/label/c.Core_MDF_No_ApprovedDomain_Error';
import Core_MDF_Other_Specify from '@salesforce/label/c.Core_MDF_Other_Specify';
//TWC3117-17805 - Aditya 
import Core_MDF_CCF_DCF_BlockCampaign_StartDate from '@salesforce/label/c.Core_MDF_CCF_DCF_BlockCampaign_StartDate';
const dateJune2025 = '2025-06-29';
const dateOct2025 ='2025-10-01';
const CMP_BUDGET_TYPES = ['OEM CMP'];

export default class Core_MDF_Create_Campaign extends NavigationMixin(LightningElement) {
	@api recordTypeId;
	@api recordTypeName;
	@api recordTypeDeveloperName;
	@api recordId;
	@api objectApiName;
	@api fieldSetName;
	@api mode;
	@api status;
	@api isCommunity;
	@api pfrEditRecord;
	@api proposalBasedIndicator;
	@api claimAssociatedIndicator;
	@api activityListEdit;
	@track mandateComment = false;
	@track isLoaded = false;
	@track campaignFields;
	@track campaignFieldVisibility = {};
	@track campaignFieldDisabled = {};
	@track campaignFieldLabel = {};
	@track campaignFieldHelpText = {};
	@track campaignFieldValue = {};
	@track campaignRequiredFields = {};
	@track campaignPicValues = {};
	@track countryOption = {};
	@track btnDisabled = { cancelBtn: false, saveAndNewBtn: true, saveBtn: true };
	@track error;
	@track picValuesByRecType;
	@track countryPicklist;
	@track othersHelpText = {};
	@track countryValue = [];
	@track geoValue = [];
	@track tempCountrySelected = [];
	@track tempGeoSelected = [];
	@track showForm = false;
	@track showAvailableBudgets = false;
	@track showAvailableBudgetRequired = false;
	@track showCampaignBudgets = false;
	@track showLegacyFields = false;
	@track activityFields;
	@track activityRequiredFields = {};
	@track budgetWarning = {};
	@track availableBudgetWarning = {};
	@track campaignBudgetsForSave = [];
	@track finalDependentVal = [];
	@track countryPicklist = [];
	@track onBudgetTypeChange = false;
	@track storeBudgetType;
	@track noBudgetsWarning = false;
	@track selectedAvailableBudgets = [];
	@track selectedCmpBudgets = [];
	@track arrayFromAvailableBudgets = [];
	@track ConnectedCallbackGeoCountryValue = new Map();
	@track budgetIdTypeMap = new Map();
	@track isBudgetAmountDecreased = false;
	@track getBudgetsAmountOnActiveActivities = false;
	@track multipleGeoSelected = false;
	@api activityListClone = [];
	@api activityToAttributeList = [];
	@track mandatoryActFieldsError = false;
	@track recPFRList = [];
	@track expandDetail;
	@track showSPIFRestrictError = false;
	@track campaignDateRangeError = false;
	@track savePFRClonecampaign = true;
	@track viewActivityFieldList = [];
	@track updatedActivityFieldsvalue;
	@track pfrListCloneInsert = [];
	@track checkIfClone = false;
	@track campSection;
	@track isEdit = true;
	@track CountryDisplay = [];
	@track allCountryDisplay = [];
	@track initialRRValue;
	@track customRRValues = [];
	@track finalRRrate;
	@track customRRate;
	@track isClaimsAcssociated = false;
	@track crrHelpText = false;
	@track crrMessage = '';
	@track isCustomRRValid = true;
	@track hideGenericError = false;
	@track proposalBasedIndicatorCamp = undefined;
	@track accountBasedIndicatorCamp = undefined;
	@track dynamicload = undefined;
	@track previousCampaignCountries = [];
	@track isCountryChanged = false;
	@track recActList;
	@api budgetOptions;
	@api startEndDateErr = false;
	@track getBudgetsAmountOnActiveActivities = false;
	@track initalLoad = false;
	@track loadBudgetTypefields = false;
	@track picklistSize = {}
	// Roshan - Commented as part of TWC3117-18965
	//@track availableDomains = [];
	//@track domainsLoaded = false;
	activityErrorMessage;
	isAnyPicklistValueChanged = false;
	campPickListValuesChangedObj = [];
	isL1Approver = false;
	isL2Approver = false;
	isBusinessApprover = false;
	isLegalReviewer = false;
	ipacontrollingFieldValue;
	isProposalCampaign;
	program;
	selectedActCatTypePicValues = '';
	pageHeaderTxt = '';
	startEndDateSoftWarning = Core_MDF_StartEndDate_Soft_Msg;
	sourceLabelStr = Core_MDF_Available_Label;
	selectedLabelStr = Core_MDF_Chosen_Label;
	countryFilterLabelTxt = Core_MDF_Country_Filter;
	saveBtnLabelTxt = Core_MDF_Save;
	cancelBtnLabelTxt = Core_MDF_Cancel;
	noneStr = Core_MDF_PFR_None_Translation;
	accountQueryFilter = '';
	othersMessage = Core_MDF_IPA_Others_Message;
	editText = Core_MDF_Edit;
	ccfBudgetWarningMessage = Core_MDF_CCF_Budget_Warning_Message;
	dcfBudgetWarningMessage = Core_MDF_DCF_Budget_Warning_Message;
	availableBudgetWarningMessage = Core_MDF_No_Available_Budgets_Warning;
	campaignBudgetsError = Core_MDF_Campaign_Budgets_Error;
	availableBudgetsLabel = Core_MDF_Available_Budgets_Label;
	spifWarningError = Core_MDF_Complete_SPIF_Warning;
	multipleCountriesSoftMsg = Core_MDF_Multiple_Countries_Soft_Msg;
	multipleGeoError = Core_MDF_Multi_Geo_Error;
	datevalid = true;countryError = false;industryError = false;multiGeoError = false;activityType = Core_MDF_Activity_Type;
	skipOutcomeFieldUpdate = false;
	startDate = Core_MDF_Start_Date;
	endDate = Core_MDF_End_Date;
	campActDateerror = campaignDateRangeErr;
	metrics = Core_MDF_KpiSection_Label;
	note = Core_MDF_Activity_Note;
	validation60Days = Core_MDF_Activity_Event_60_Days;
	threshold60Days = Core_MDF_60DaysMoreThan_50K;
	inValidOppError = invalidOpportunityError;
	blankMetricError = blankMetricError;
	blankTacticMetricError = blankTacticMetricError;
	amount50K = Core_MDF_ManagerApprovalThreshold;
	validationInitiativeNone = Core_MDF_Initiative_None_Selection_Error;
	availableBudgetValues = [];
	budgetsOnActiveActivities = [];
	cloneHeader = Core_MDF_Activity_Creation_Page_Header;
	campaignBudgets = [];oldcampaignBudgets = [];activityBudgetAmt = [];allCampaignBudgets = [];allCmpBudgetsMap = new Map();selectedAvailableBudgetsMap = new Map();
	@track selectPartnerBudgetTypeWarning = {};
	accountDisable = undefined;
	accountVisible = true;
	@track naHelpText = {};
	naMessage = Core_MDF_IPA_NA_Message;
	selectPartnerBudgetTypeError = '';
	picklistApitoLabelReferenceMap = new Map();
	budgetTypeRrOptionMap = new Map();
	budgetTypeRrOptionsStr = Core_MDF_budgetTypeRRValuesMap;
	budgetAmountDecreasedErr = Core_MDF_CampaignBudgets_ErrMsg;
	memberVisibilityValid = false;
	memberVisibilityError = Core_MDF_ExternalVisibilityError;
	cmpFieldAPINametoPFRFieldAPIName;
	focusAreaDependentFieldValues = []; label = { singleFocusAreaSelectionTextMessage, internalExternalCommentsCharLimit, applicationErrorMsg, crossGeoCountrySelectionTextMessage, Core_MDF_MandatoryFieldsCheck, Core_MDF_Campaign_Outcome_Validation, Core_MDF_Campaign_Outcome_Based_Validation, Core_MDF_Campaign_Budgets_Label,Core_MDF_Non_OutcomeBased_Selection_Error,Core_MDF_AccountPlan_StartDate_Error,Core_MDF_IPA_AccountBased_StartDate,partnerContactFieldValidation}; //Ealay
	ccfRecordType; dcfRecordType;
	defaultCampRRpct;
	customPicklistValueDependency; 
	pfrIPALovFields;
	pfrIPAActCatAndTypeDepFlds;
	recordTypeWithMultiSelectValues;
	multiSelectPickFlds = [];
	activityTypeToClassificationMap = new Map();
	pfrDependencyBasedOnFocusArea;
	pfrDependencyBasedOnActCatAndType;
	@track priorityPecFlag = false;
	campaignSource = '';
	priorityPecAbove100 = false;
	changeInPriorityPct = false;
	priorityPer1 = 0;
	priorityPer2 = 0;
	priorityPer3 = 0;
	campAmountFields;
	@track isPriorityPec = false;
	@api virtualCorpsData;
	 @api vitualCorpToNodeAcc; 
	@api NodeAccountsList;
	partnerMapError = Core_MDF_PartnerMap_Error_Msg;
	selectedCampBudgets=[]; campBudgetMap = new Map();
	isvAccountOptions={};
	@track isvAccIds = [];
	cspToISVAccountsMap;
	@track showAvailableISVAccounts = false;
	@track selectedActPartners = '';
	@track noAvailablePartnerAccounts = false;
	isDefaultBudget=false;
	singleCampBudget=[];
	@track isActSelOnClone = true;
	@track validCountriesFromCPObject = [];
	activityCategoryTypeValuesFromCPObject = [];
	startYearOfCampaign = '';
	supportsLegacy = '';
	isDateChanged = false; isCampaignBudgetsInitiallyLoaded = false; @track campaignBudgetsPrevMap = new Map();
	priorityValuesForRollback = {}; campaignStartDateInitialPhase = ''; campaignStartDatePrevPhase = ''; campaignStartDateCurrPhase = ''; isBudgetTypeChangedOnce = false;
	campaignBefore2025ActCatTypeValues = []; campaignEqualsOrAfter2025ActCatTypeValues = []; isActAssociatedBudgetTypeRemoved = false; validateCampaignBudgetsAmount = false;
	@track cmpBudgetsErrorToRetainMap = new Map(); @track isCmpBudgetsValidOnChangeOfFields = true;
	showContractLineItemSection = false;
	@track contractLineItemsList = [];
	@track contractLineItemsListToSave = [];
	@track internalAndExternalUsersMap = new Map();
	@track intelOwnerOptions = [];
	@track memberAcceptorOptions = [];
	@track intelVerifierOptions = [];
	intelOwnerError = false;
	memberAcceptorError = false;
	intelVerifierError = false;
	virtualCorpAccId = '';
	disableContractLineItems = false;
	disableCampaignBudgets = false;	
	selectedBudgetsLabel = Core_MDF_Selected_Budgets;
	title = Core_MDF_Campaign_Purpose;
	clickHere = clickHere;
	outcomeSalesMarketingGuidebookLink = outcomeSalesMarketingGuidebookLink;
	outcomeSalesMarketingGuidebook = outcomeSalesMarketingGuidebook;
	increaseByLabel = IncreaseBy;
	decreaseByLabel = DecreaseBy;
	outcomeStmtFrom = outcomeStmtFrom;
	outcomeStmtTo = outcomeStmtTo;
	outcomeStmtFor = outcomeStmtFor;
	outcomeStmtAnd = outcomeStmtAnd;
	outcomeStmtClosedBracket = outcomeStmtClosedBracket;
	multipleValuesSelected= false;
	@track editedOutcomeData = {};		
	@track isOutcomeValid = true;
	@track isStartDateValid = true;//Added By AN
	@track outcomeErrorMessages = [];
	@track columns = [];
	@track rows = [];	
	@track selectedOutcomes = [];
	outcomeFieldLabels = {};
		outcomeFieldHelpText = {};
		outcomePicklistValues = {};
	originalOutcomesOptions = [];  //Roshan - defect fix
	outcomeFieldRequired = {};
	currentApprovalStage;
	startDateChangedOnce = false;
	contractLineItemsOnLoad = [];
	focusAreaValid = true;
	userTodayDate;
	isPastDatedCampaign = false;
	bypassBudgetTypeLoad = false;
	activityCategoryBasedError = false; // Ealaya TWC3117-14432 Activity Category changes -->
	@track isvalidActCatType = true;
	@track showIPAStartDateError = false;
	//TWC3117-17805 - Aditya 
	@track showCCFDCFStartDateError = false;
	@track isCCFDCFStartDateValid = true;
	campaignPurposeDescriptiveHeader = Core_MDF_Activity_Purpose_Header;

	validOutcomeMetricRecordType = [
		Core_MDF_IPA_RecordType,
		Core_MDF_CCF_RecordTypeName,
		Core_MDF_DCF_RecordTypeName,
		rmfRecTypeNm
	];
	validOutcomeMetricProgram = [
		Core_MDF_IPA_Program_Name,
		Core_MDF_CCF_Program_Name,
		Core_MDF_DCF_Program_Name,
		Core_MDF_Retail_Program_Name
	];
	validOutcomeMetricRecordTypeWithOutIPA = [
		Core_MDF_CCF_RecordTypeName,
		Core_MDF_DCF_RecordTypeName
	]; 

	@wire(getConstants)
	allConstants({ error, data }) {
		if (data) {
			this.ccfRecordType = data.CMP_CCF_RECORDTYPE; this.dcfRecordType = data.CMP_DCF_RECORDTYPE;
			this.pfrIPALovFields = data.PFR_IPA_LOV_Fields;
			this.pfrIPAActCatAndTypeDepFlds = data.PFR_IPA_ACT_CAT_TYPE_FIELDS;
			this.recordTypeWithMultiSelectValues = {};
			this.recordTypeWithMultiSelectValues[Core_MDF_IPA_RecordType] = data.campaignIPAMultiSelectFieldsOnUI;
			this.recordTypeWithMultiSelectValues[Core_MDF_CCF_RecordTypeName] = data.campaignCCFAndDCFMultiSelectFieldsOnUI;
			this.recordTypeWithMultiSelectValues[Core_MDF_DCF_RecordTypeName] = data.campaignCCFAndDCFMultiSelectFieldsOnUI;
			this.recordTypeWithMultiSelectValues[rmfRecTypeNm] = data.campaignRMFMultiSelectFieldsOnUI;
			this.recordTypeWithMultiSelectValues[Core_MDF_EEF_RecordType] = data.campaignEEFMultiSelectFieldsOnUI;
			this.recordTypeWithMultiSelectValues[Core_MDF_Co_GTM_RecordType] = data.campaignGTMMultiSelectFieldsOnUI;
			this.multiSelectPickFlds = this.recordTypeWithMultiSelectValues[this.recordTypeDeveloperName];
			this.defaultCampRRpct = data.defaultRR_Pct;
		} else {this.error = error;}
	} 
	fetchSelectedValues() {
		let selections = this.template.querySelector('c-core_-m-d-f_-campaign_-available_-budgets_-picklist');
		this.showCampaignBudgets = true;
	}
	render() {
		return this.recordTypeDeveloperName === Core_MDF_IPA_RecordType ? ipaCampCreate : this.recordTypeDeveloperName === 'Core_MDF_Client_CoMarketing_Fund' ? opalCCFCampCreate : this.recordTypeDeveloperName === 'Core_MDF_Data_Center_CoMarketing_Fund' ? opalDCFCampCreate : this.recordTypeDeveloperName === rmfRecTypeNm ? rmfCampCreate : this.recordTypeDeveloperName === Core_MDF_EEF_RecordType ? EEFCampCreate : this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType ? coGTMCampCreate : ipaCampCreate;
	}

	@wire(getUserTodayDate)
	wiredDate({ error, data }) {
		if (data) {
			this.userTodayDate = data; // format 'YYYY-MM-DD'
		} else if (error) {
			console.error('Error getting user date:', error);
		}
	}

	@wire(getPicklistValuesByRecordType, {
		recordTypeId: '$recordTypeId',
		objectApiName: '$objectApiName'
	})
	wiredOptions({ error, data }) {
		if (data) {
			this.picValuesByRecType = data;
			this.error = undefined;
			this.initialization();
		} else if (error) {
			this.error = error;
			this.picValuesByRecType = undefined;
		}
	}
	@wire(getObjectInfo, {
		objectApiName: CAMPAIGN_OBJECT
	}) campaignObjectInfo;
	connectedCallback() {
		loadStyle(this, Core_MDF_DisabledFieldsOnCampaignUI_CSS);
		if (this.isCommunity === undefined || this.isCommunity === null || this.isCommunity === '') {
			this.isCommunity = false;
			var sPageURL = decodeURIComponent(window.location.href);
			if (sPageURL.includes('Partnercenter') || sPageURL.includes('partnercenter')) {
				this.isCommunity = true;
			}
		}
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
			this.accountQueryFilter = "RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = '" + Core_MDF_IPA_Program_Name + "'";
		} else if (this.recordTypeDeveloperName === Core_MDF_Retail_Record_Type_Developer_Name) {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = '" + Core_MDF_Retail_Program_Name + "'";
		} else if (this.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName) {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND  Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = 'Client'";
		} else if (this.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName) {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND  Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = 'Datacenter'";
		}else if (this.recordTypeDeveloperName === Core_MDF_EEF_RecordType) {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND  Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = 'Ecosystem Extension Fund' AND Core_MDF_Partner_Type_nm__c includes ('Primary Partner')";
		} else if (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = '" + Core_MDF_Co_GTM_program_name + "'";
		}else {
			this.accountQueryFilter = " RecordType.DeveloperName = 'Core_MDF_Co_Marketing' AND  Core_MDF_Parent_Fund_Account__r.RecordType.DeveloperName != 'Core_MDF_Co_Marketing' AND Core_MDF_Channel_Program__r.Name = '" + this.recordTypeName + "'";
		}
		this.accountQueryFilter = this.accountQueryFilter + ' AND Core_MDF_Active_Ind__c = true';
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
			this.pageHeaderTxt = Core_MDF_NewCampaign_Label + ': ' + Core_MDF_Localized_IPA_Name;
		} else {
			this.pageHeaderTxt = Core_MDF_NewCampaign_Label + ': ' + this.recordTypeName;
		}
		if (this.recordId != undefined && this.recordId != null && this.recordId != '' && (this.mode == 'edit')) {
			this.getBudgetsOnActiveActivities();
		}
		
			apitoLabelReference({objName: 'Core_MDF_Custom_Picklist__c',pfrPiclistField: Core_MDF_Intel_MDF_Fields.split(',')}).then(result => {
				this.picklistApitoLabelReferenceMap = new Map(Object.entries(result));
			}).catch(error => {
				console.log('error:' + error)
			});
		//TWC3117-10490 - [CCF/DCF/IPA] - Reimbursement Rate Values
		const budgetTypeRRMap = new Map(Object.entries(JSON.parse(this.budgetTypeRrOptionsStr)));
		for (const key of budgetTypeRRMap.keys()) {
			const rrOtions = [];

			const options = budgetTypeRRMap.get(key);
			options.forEach(value => {
				rrOtions.push({ label: value, value: value });
			});
			this.budgetTypeRrOptionMap.set(key, rrOtions);
		}

		if (this.recordTypeDeveloperName != rmfRecTypeNm && this.recordTypeDeveloperName != Core_MDF_Co_GTM_RecordType) { this.fetchGeoCountryMappingValue(); }
		if (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
			this.showContractLineItemSection = true;
			if (this.mode == 'edit') {
				this.disableCampaignBudgets = this.disableContractLineItems = this.status == 'Completed' ? true : false;
				this.fetchContractLineItems();
			}
			if (checkForUndefinedEmptyAndNull(this.contractLineItemsList) && this.contractLineItemsList.length == 0) {
				this.contractLineItemsList = [{
					value: '',
					type: 'new',
					tempKey: 'temp-' + Date.now(), //key to render UI
					parentId: this.recordId
				}]
			}
		}
		if (this.validOutcomeMetricRecordType.includes(this.recordTypeDeveloperName)) { this.initializeOutcome(); } 
	}

	handleUsersChangeForCoGTM(event) {
		const name = event.target.name;
		const value = event.target.value;
		if (name === 'Core_MDF_Intel_Owner_id__c') {
			this.intelOwnerOptions = value;
			this.intelOwnerError = value.length > 1;
		} else if (name === 'Core_MDF_Member_Acceptor_id__c') {
			this.memberAcceptorOptions = value;
			this.memberAcceptorError = value.length > 1;
		} else if (name === 'Core_MDF_Intel_Verifier_id__c') {
			this.intelVerifierOptions = value;
			this.intelVerifierError = value.length > 1;
		}
	}
	handleOptInChange(event) {
		const isChecked = event.target.checked;
		this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = isChecked;
		if (this.recordTypeDeveloperName == Core_MDF_IPA_RecordType && this.campaignFieldValue["StartDate"] >=dateJune2025 && this.campaignFieldValue["StartDate"] < dateOct2025) {
			this.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = isChecked;
			this.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = isChecked;
			this.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = isChecked; //Aditya
			if (!isChecked) {
				this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = null;
				this.editedOutcomeData = {};
				this.isOutcomeValid = true;
				this.multipleValuesSelected = false;
				this.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = false; //Aditya
				this.campaignFiedValue["Core_MDF_Other_Outcome_Criteria_txt__c"] = null;
			}
			this.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = false;
			this.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"] =  null ;
			this.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = false;
			this.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
		}
		
		if(this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] == false && this.campaignFieldValue["StartDate"] >=dateJune2025 && this.campaignFieldValue["StartDate"] < dateOct2025){
			this.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"]= true;
			this.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"] = this.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"];
			this.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = false; //Aditya
		}
		this.filterOtherFromOutcomeMetric();
		if (!isChecked) {
			// Only clear quantity for each outcome row
			Object.keys(this.editedOutcomeData).forEach(key => {
				this.editedOutcomeData[key].baselineQuantity = null;
				this.editedOutcomeData[key].baselinePeriod = null;  //Roshan - 17969
			});
			this.rows = Object.values(this.editedOutcomeData);
		}
		this.setColumns();
		this.validateOutcomeError();
		this.validateActivityCategory();// Ealaya TWC3117-14432 Activity Category changes
		//IPA-Jegan
		const customEvent = new CustomEvent('outcomechange', {
			detail: { value: event.target.checked }
		});
		this.dispatchEvent(customEvent);
	}		
	handleOutcomeChange(event) {
		const selectedValues = event.detail.value;
		const isOtherSelected = selectedValues.includes("Other");
		const showOtherField = isOtherSelected;
		this.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = showOtherField;
		this.campaignRequiredFields["Core_MDF_Other_Outcome_txt__c"] = showOtherField;
		if (!isOtherSelected) {
			this.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
		}
		this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = selectedValues;
		this.validateOutcomeError();
		this.selectedOutcomes = selectedValues;
		this.multipleValuesSelected = selectedValues.length > 1;
		const updatedEditedOutcomeData = {};
		selectedValues.forEach(outcome => {
			if (this.editedOutcomeData && this.editedOutcomeData[outcome]) {
				updatedEditedOutcomeData[outcome] = this.editedOutcomeData[outcome];
			} else {
				updatedEditedOutcomeData[outcome] = {
					id: `row-${outcome}`,
					outcome: outcome,
					outcomeLabel: this.outcomePicklistValues["Core_MDF_Outcomes_nm__c"]?.[outcome] || outcome,
					baselineQuantity: null,
					goalQuantity: null,
					quantity: null,
					baselinePeriod: '',
					outcomeCriteria: ''
				};
			}
		});	
		this.editedOutcomeData = updatedEditedOutcomeData;
		this.rows = Object.values(this.editedOutcomeData);
		this.setColumns(); //Recompute columns so outcome criteria column shows/hides based on current rows
	}	
	handleTableChange(event) {
		const updatedRows = event.detail;		
		// Create a temporary object to hold only selected/edited outcomes
		const updatedEditedOutcomeData = {};	
		updatedRows.forEach((row) => {
			let outcomeKey = row.outcome;	
			if (outcomeKey && this.selectedOutcomes.includes(outcomeKey)) {
				const existing = this.editedOutcomeData[outcomeKey] || {};
				updatedEditedOutcomeData[outcomeKey] = { ...existing, ...row };
			}
		});	
		this.editedOutcomeData = updatedEditedOutcomeData;
	}
	async initializeOutcome() {
		try {
			const fieldMetadata = await loadDynamicFields({pickListObj: 'Core_MDF_Campaign_Outcomes__c',budType: [''],objectName:'Core_MDF_Campaign_Outcomes__c'});
			for (let field of fieldMetadata) {
				this.outcomeFieldLabels[field.fieldAPIName] = field.fieldLabel;
				this.outcomeFieldHelpText[field.fieldAPIName] = field.helpText;
				this.outcomeFieldRequired[field.fieldAPIName] = field.isRequired;
				if (field.pickListValues) {
					this.outcomePicklistValues[field.fieldAPIName] = field.pickListValues;
				}				
			}			
			this.campaignFieldDisabled["Core_MDF_Quantity_nbr__c"] = true;
			this.setColumns();
			// Only load existing data in edit mode
			if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
				await this.loadExistingOutcomes(this.recordId);
			}
		} catch (error) {
			console.error('Initialization failed:', error);
		}
	}
	async loadExistingOutcomes(campaignId) {
		try {
			const result = await getCampaignOutcomes({ campaignId });
			this.rows = result.map(row => ({
				id: row.recordId,
				outcome: row.outcome,
				outcomeLabel: this.outcomePicklistValues["Core_MDF_Outcomes_nm__c"]?.[row.outcome] || row.outcome,
				baselineQuantity: row.baselineQuantity,
				goalQuantity: row.goalQuantity,
				quantity: row.quantity,
				baselinePeriod: row.baselinePeriod,
				outcomeCriteria: row.outcomeCriteria
			}));
			this.selectedOutcomes = this.rows.map(row => row.outcome);
			this.editedOutcomeData = {};
			this.rows.forEach(row => {
				this.editedOutcomeData[row.outcome] = {
					id: row.id,
					outcome: row.outcome,
					outcomeLabel: this.outcomePicklistValues["Core_MDF_Outcomes_nm__c"]?.[row.outcome] || row.outcome,
					baselineQuantity: row.baselineQuantity,
					goalQuantity: row.goalQuantity,
					quantity: row.quantity,
					baselinePeriod: row.baselinePeriod,
					outcomeCriteria: row.outcomeCriteria
				};
			});
			this.rows = [...this.rows];			
		} catch (error) {
			console.error('Error loading outcomes:', error);
		}
	}
	
	fetchContractLineItems() {
		getCampaignContractLineItems({ parentId: this.recordId })
			.then(result => {
				if (result && result.length > 0) {
					this.contractLineItemsList = result.map(item => ({
						...item,
						type: 'existing',
						tempKey: 'existing-' + item.Id, //key to render UI
						value: item.Core_MDF_Contract_Section_Details_txt__c,
						existingHistoryValue: item.Core_MDF_Contract_Section_Details_Histry__c,
						parentId: this.recordId
					}))
					this.contractLineItemsOnLoad = [...this.contractLineItemsList];
					
				}
			})
			.catch(error => {
				console.error('Error fetching contract line items:', error);
			});
	}

	updateContractLineItems(event) {
		this.contractLineItemsList = event.detail; // Capture updates from campaign contract line items child component
	}

	getBudgetsOnActiveActivities() {
		getBudgetsOnActiveActivities({ campaignId: this.recordId })
			.then((result) => {
				if (result) {
					this.budgetsOnActiveActivities = result;
				}
			}).catch((error) => {
				console.log('OUTPUT : 350', error);
			});
	}
	initialization() {
		this.cmpFieldAPINametoPFRFieldAPIName = campFieldAPINametoPFRFieldAPIName(this.recordTypeDeveloperName);
		if ((this.status === 'Draft' && (this.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName || this.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName || this.recordTypeDeveloperName === Core_MDF_EEF_RecordType)) || (this.recordId != undefined && this.recordId != null && this.recordId != '') && (this.mode == 'edit' || this.mode == 'clone')) {
			this.isLoaded = true;
			if (this.mode == 'edit') {
				if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType) {
					/*if (checkForUndefinedEmptyAndNull(this.virtualCorpsData)){
						this.NodeAccountsList = this.virtualCorpsData['NodeAccountsList'];
						for (let key in this.virtualCorpsData['vitualCorpToNodeAcc']) {
								this.vitualCorpToNodeAcc[key] = (this.virtualCorpsData['vitualCorpToNodeAcc'])[key];
							}
						 }*/

				}

				checkEditProposalAccess({
					campaignId: this.recordId,
					recTypeDevloperName: this.recordTypeDeveloperName
				}).then(result => {
					if (result.isEditProposalAccess == false) {
						this.showErrorToast(result.returnValue, 'pester');
						this.navigateToRecordDetailPage(this.objectApiName, this.recordId);
						setTimeout(function () {
							window.location.reload();
						}, 1000);
					}
					this.isL1Approver = result.isUserL1Approver;
					this.isL2Approver = result.isUserL2Approver;
					this.isClaimsAcssociated = result.isClaimAssociated;
					this.isBusinessApprover = result.isUserBusinessApprover;
					this.isLegalReviewer = result.isUserLegalReviewer;

					getFieldEditibilityMapping({ objectName: this.objectApiName, recTypeDevloperName: this.recordTypeDeveloperName, status: this.status, campaignId: this.recordId, proposalBasedIndicator: result.isProposalBased, claimAssociatedIndicator: result.isClaimAssociated })
						.then(result => {
							if (result) {
								this.fieldEditibilityList = result;
								if (this.fieldEditibilityList !== undefined && this.fieldEditibilityList !== null && this.fieldEditibilityList.length === 0) {
									this.btnDisabled["saveBtn"] = true;
								}

								// fix to avoid race condition between fieldEditibilityList and getObjectFieldDetails
								if(checkForUndefinedEmptyAndNull(this.campaignFields)) {
									getObjectFieldDetails(this);
									if (this.validOutcomeMetricRecordType.includes(this.recordTypeDeveloperName)) {
										this.setColumns();
									}
								}

							}
						}).catch(error => {
							console.log('OUTPUT : 385', error);
						})
				}).catch(error => {
					console.log('OUTPUT : 388', error);
				})
			}
			if (this.mode == 'edit' || this.mode == 'clone') {
				getCampaignBudgetsForCampaign({ campaignId: this.recordId })
					.then(result => {
						if (result !== undefined && result !== null && result.length > 0) {
							let selBudgetIds = [];
							let campaignBudgetsArray = [];
							for (let i = 0; i < result.length; i++) {
								if (!selBudgetIds.includes(result[i].Core_MDF_Budget_Name_Id__c) && result[i].Core_MDF_Active_ind__c == true) {
									selBudgetIds = [...selBudgetIds, result[i].Core_MDF_Budget_Name_Id__c];
									this.selectedAvailableBudgetsMap.set(result[i].Core_MDF_Budget_Name_Id__c, result[i]);
								}let rrOptions;
								if (this.budgetIdTypeMap.has(result[i].Core_MDF_Budget_Name_Id__c)) {const budgetType = this.budgetIdTypeMap.get(result[i].Core_MDF_Budget_Name_Id__c);
									if (this.budgetTypeRrOptionMap.has(budgetType)) {rrOptions = this.budgetTypeRrOptionMap.get(budgetType);}}
						let budgetNameString = getBudgetNameString(result[i].Core_MDF_Budget_Name_Id__r.Title, result[i].Core_MDF_Budget_Type_Nm__c,result[i].Core_MDF_Start_Date_Dt__c, result[i].Core_MDF_End_Date_Dt__c,result[i].Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c);
						let obj;if (this.mode === 'edit' && result[i].Core_MDF_Active_ind__c) {
						if (this.budgetsOnActiveActivities.includes(result[i].Core_MDF_Budget_Name_Id__c)) {
						campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(result[i], true, true, rrOptions, budgetNameString)];
						} else {campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(result[i], true, false, rrOptions, budgetNameString)];
						}
					} else if (this.mode === 'clone' && result[i].Core_MDF_Active_ind__c) {
						//Clone CCF/DCF RR% changes
						let selectedRROnCamp = result[i].Core_MDF_Reimbursement_Rate_Pct__c;
						let selectedBudgetType = result[i].Core_MDF_Budget_Type_Nm__c;
						let rrToBeStamped;

						if (selectedBudgetType != null) {
								const allowedRRs = this.budgetTypeRrOptionMap.get(selectedBudgetType)?.map(option => option.value);

								//Check if allowedRRs includes selectedRROnCamp
								if (allowedRRs && allowedRRs.includes(selectedRROnCamp)) {
									rrToBeStamped = selectedRROnCamp;  //Set the base campaign's RR%
								} else {
									rrToBeStamped = this.defaultCampRRpct;  //Default to 50% if selectedRROnCamp is not in allowed values
								}
						}
						let rrValue = parseFloat(rrToBeStamped) / 100; //Used to calculate Campaign Intel Contribution
					obj = {
					budgetId: result[i].Core_MDF_Budget_Name_Id__c,
					isActive: true,
					budgetName: budgetNameString,
					budgetAmount: result[i].Core_MDF_Budget_Amt__c,
					budgetRR: rrToBeStamped,  // new RR changes
					budgetRAmount: result[i].Core_MDF_Budget_Amt__c * rrValue,  // new RR changes
					options: rrOptions,
					budgetType: result[i].Core_MDF_Budget_Type_Nm__c
					};
					campaignBudgetsArray = [...campaignBudgetsArray, obj];}this.allCmpBudgetsMap = this.allCmpBudgetsMap.set(result[i].Core_MDF_Budget_Name_Id__c, result[i]);}
							this.oldcampaignBudgets = campaignBudgetsArray;
							if((this.recordTypeDeveloperName != Core_MDF_EEF_RecordType) || (this.mode == 'edit' && this.recordTypeDeveloperName == Core_MDF_EEF_RecordType)){
								this.campaignBudgetsForSave = campaignBudgetsArray;
								this.selectedAvailableBudgets = selBudgetIds;
								this.selectedCmpBudgets = selBudgetIds;
							}
						}
					}).catch(error => { console.log('OUTPUT : 437', error); })
			}
			loadCampaignRecord({
				recordId: this.recordId,
					operation: this.mode,
				objectName: this.objectApiName,
				fieldSetName: this.fieldSetName
			}).then(result => {
				if (result) {
					var controlllingField = [];
					this.campaignRecord = result;
					let isActiveAccount = result["Core_MDF_Account__r"].Core_MDF_Active_Ind__c;
					if (isActiveAccount || (!isActiveAccount && this.mode == 'edit')) {
						this.selectedAccount = { 
							Id: result["Core_MDF_Account__r"].Id, 
							Name: result["Core_MDF_Account__r"].Name,
							ultimateAcc: result['Core_MDF_Account__r'].Core_MDF_CoMarketing_Ultimate_Account__c,
							virtualCorpAcc: result['Core_MDF_Account__r'].Core_MDF_Virtual_Corp_Account_Id__c,
							programId: result['Core_MDF_Channel_Program__c']
						}; 
						this.selectedAccountId = result["Core_MDF_Account__r"].Id;
					}
					if (this.recordTypeDeveloperName == rmfRecTypeNm) {
						controlllingField.push(result["Core_MDF_Budget_Type_txt__c"]);
					} else if (this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) {
						if (typeof result["Core_MDF_Focus_Area_nm__c"] != 'undefined' && typeof result["Core_MDF_Focus_Area_nm__c"] != null && typeof result["Core_MDF_Focus_Area_nm__c"] != '') {
							controlllingField = controlllingField.concat(result["Core_MDF_Focus_Area_nm__c"].split(';'));
						}
					} else if(this.recordTypeDeveloperName == Core_MDF_EEF_RecordType){
						controlllingField.push(result["Core_MDF_Opal_Budget_Type_Txt__c"]);
					} else {
						controlllingField = result["Core_MDF_Opal_Budget_Type_Txt__c"].split(';')
					}
					this.selectedBudType = result["Core_MDF_Opal_Budget_Type_Txt__c"];
					this.isProposalCampaign = result["Core_MDF_Proposal_Based_Ind__c"];
					this.program = result["Core_MDF_Program__c"];
					if ((this.mode === 'edit' || this.mode === 'clone') && (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType || this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType)) {
						if (this.campaignFieldValue["Core_MDF_Integrated_Campaign__c"] == 'Yes') {
							this.campaignRequiredFields["Core_MDF_Integrated_Campaign_Details__c"] = true;
						}
						if(this.mode === 'clone' && !checkForUndefinedEmptyAndNull(this.selectedAccountId)){
							this.loadBudgetTypefields = false;
							this.isLoaded = false;
						}
						else {
							let accountDetails = (this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) ? this.selectedAccountId : this.selectedAccount;
							this.bypassBudgetTypeLoad = true;
							this.handleSelectedAccount(accountDetails);
							this.loadBudgetTypefields = true;
						}
						this.campaignFieldValue["Core_MDF_Program__c"] = this.program;
						this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = this.selectedBudType;
						// Roshan - Commented as part of TWC3117-18965
						//const virtualCorpId = this.selectedAccount.virtualCorpAcc ? this.selectedAccount.virtualCorpAcc: this.selectedAccount.Id;
						//this.fetchDomainsForAccount(virtualCorpId);
						this.populateDynamicfields(result);	
					}
					this.initalLoad = true;
					getFieldSetName({ pickListObj: 'Core_MDF_Custom_Picklist__c', budType: controlllingField, objectName: 'Campaign', recordTypeDevName: this.recordTypeDeveloperName })
						.then(result => {
							this.fieldSetApiName = result; if (this.recordTypeDeveloperName != Core_MDF_IPA_RecordType) { this.getCampaignFields(); this.loadBudgetTypefields = true; }
						}).catch(error => console.log(error));
				}
				if(result["Core_MDF_Program__c"] === Core_MDF_CCF_Program_Name || result["Core_MDF_Program__c"] === Core_MDF_DCF_Program_Name){
					this.campaignSource = result["Core_MDF_Campaign_Source_nm__c"];
					if(result["Core_MDF_Campaign_Source_nm__c"] === 'Target Setting' && this.mode === 'edit'){
						this.priorityPecFlag = true;
						this.priorityPer1 =  parseFloat(result["Core_MDF_Priority_Percentage__c"]);
						this.priorityPer2 = parseFloat(result["Core_MDF_Priority_Percentage_2__c"]);
						this.priorityPer3 = parseFloat(result["Core_MDF_Priority_Percentage_3__c"]);
					}
				}
			})
				.catch(error => { console.log(error); this.isLoaded = false; })
		} else {
			this.getCampaignFields();
			this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
		}
	}
	async getCampaignFields() {
		this.isLoaded = true; let objAPIName = 'Core_MDF_Custom_Picklist__c'; var fldSetName = new Array(); fldSetName[0] = this.fieldSetApiName;
		if (this.mode === 'edit' || this.mode === 'clone') {
			fldSetName = this.fieldSetApiName;
		} else { fldSetName[0] = this.fieldSetName; }
		await getObjectFields({ objectName: objAPIName, fieldSetNameList: fldSetName, isCommunityUser: this.isCommunity })
			.then(result => {
				this.campaignFields = result; this.oldCampFields = this.campaignFields;
				getObjectFieldDetails(this);
				if(this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) {
					if (this.mode == 'edit') {
						if(checkForUndefinedEmptyAndNull(this.budgetOptions) && this.budgetOptions.length > 0) {
							this.campaignPicValues['Core_MDF_Opal_Budget_Type_Txt__c'] = this.budgetOptions;
						}
						this.campaignPicValues = lovValuesAddition(this.campaignPicValues, this.campaignFieldValue, this.campRecordTypeName, this.picklistApitoLabelReferenceMap, this);
						this.budgetOptions = this.campaignPicValues['Core_MDF_Opal_Budget_Type_Txt__c'];
						this.accountDisable = true;
						this.accountVisible = false;
					}
					this.campaignFieldValue = this.mode === 'clone' ? validatePicklistvalues(this.campaignPicValues, this.campaignFieldValue, this.campaignFields, this) : this.campaignFieldValue;
					let selectedBudget = this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'];
					//Show Measurement Approach for IPA proposal based campaigns
					const showMeasurementApproach = this.proposalBasedIndicatorCamp === true;
					this.campaignFieldVisibility["Core_MDF_Measurement_Approach_nm__c"] = showMeasurementApproach;
					if (!showMeasurementApproach) {
						this.campaignRequiredFields["Core_MDF_Measurement_Approach_nm__c"] = false;
						this.campaignFieldVisibility["Core_MDF_Other_Measurement_Approach_txt__c"] = false;
						this.campaignRequiredFields["Core_MDF_Other_Measurement_Approach_txt__c"] = false;
					}
					if (selectedBudget == "" || selectedBudget == null || !checkForUndefinedEmptyAndNull(this.selectedAccountId)) {
						this.loadBudgetTypefields = false; this.dynamicload = false;
						this.campaignFieldVisibility['Core_MDF_Focus_Area_nm__c'] = false;
						this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] = '';
					}
					let selFA = this.campaignFieldValue['Core_MDF_Focus_Area_nm__c'];
					if (!checkForUndefinedEmptyAndNull(selFA)) {
						this.dynamicload = false;
						this.isActSelOnClone = false;
					}
					if (this.mode === 'clone' && this.campaignFieldValue['Core_MDF_Proposal_Based_Ind__c'] && this.activityListClone.length > 0) {
						this.clearFieldValuesOnClone();// Method to clear field values on clone of a proposal
						this.pfrDependencyBasedOnActCatAndType = getPFRActCategoryAndTypeDependency(this.activityListClone, this.customPicklistValueDependency);
						if(this.dynamicload) {
							let cntrlVal = [];
							cntrlVal.push(this.campaignRecord['Core_MDF_Focus_Area_nm__c']);
							cntrlVal.push(this.campaignRecord['Core_MDF_Program__c']);
							this.pfrDependencyBasedOnFocusArea = getPFRFieldsDependency(this.customPicklistValueDependency, this.pfrIPALovFields, cntrlVal, this.pfrIPAActCatAndTypeDepFlds);
							this.validateMandateActivityFlds(this.activityListClone, 'load');
						}
						this.clearKPIfieldsClone();
					}
					if (this.mode === 'clone' && this.campaignFieldValue['Core_MDF_Proposal_Based_Ind__c'] ) {
						this.campaignFieldValue['Core_MDF_Partner_Contact_txt__c'] = '';
					}
				} else {
					if(this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType) {
						this.campaignFieldDisabled["Core_MDF_Total_Campaign_Cost_Amt__c"] = true;
						this.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = (this.mode == 'edit') ? checkForUndefinedEmptyAndNull(this.campaignFieldValue['Core_MDF_Reason_for_Back_Dating_Nm__c']) && this.campaignFieldValue["StartDate"] < this.userTodayDate ? true : false : false;
						this.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = (this.mode == 'edit') ? (this.campaignFieldValue["StartDate"] < this.userTodayDate && checkForUndefinedEmptyAndNull(this.campaignFieldValue['Core_MDF_Reason_for_Back_Dating_Nm__c']) && this.campaignFieldValue['Core_MDF_Reason_for_Back_Dating_Nm__c'] == 'Other') ? true : false : false;
						this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = ['Co-Engineering'];
						this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] = true;
						this.campaignFieldDisabled["Core_MDF_Profit_Center__c"] = true;
						if(this.isCommunity){
							this.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = false;
							this.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = false;
							this.campaignFieldVisibility['Core_MDF_MMID__c'] = false;
							this.campaignFieldVisibility['Core_MDF_Profit_Center__c'] = false;
							this.campaignFieldVisibility["Core_MDF_IPA_Co_Engineering_Campaign_ind__c"] = false;
						}
						if(this.mode === 'clone') {
							this.campaignFieldValue['Core_MDF_Total_Campaign_Cost_Amt__c'] = '';
							this.campaignFieldValue['Core_MDF_Reason_for_Back_Dating_Nm__c']='';
							this.campaignFieldValue['Core_MDF_Other_Reason_Name_txt__c'] = '';
							this.campaignFieldValue['Core_MDF_MMID__c'] = '';
							this.campaignFieldValue['Core_MDF_Profit_Center__c'] = '';
                            this.campaignFieldValue['Core_MDF_IPA_Co_Engineering_Campaign_ind__c']=false;
							//aditya
							if(!this.isCommunity){
								this.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = this.campaignFieldValue["StartDate"] < this.userTodayDate ? true : false;
							}else{
								//this.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = false;
								if(this.campaignFieldValue["StartDate"] < this.userTodayDate){
									this.isPastDatedCampaign = true;
								}
							}
							this.selectedCmpBudgets = [];
							this.campaignBudgetsForSave = [];
							this.campaignFieldValue["Core_MDF_MyDeals_txt__c"] = '';
						}
						const editableFields = Array.isArray(this.fieldEditibilityList) ? this.fieldEditibilityList : [];
						if (this.mode == 'edit' && ((this.isBusinessApprover || this.isL2Approver || this.isLegalReviewer) || (editableFields.includes('Core_MDF_Contract_Line_Item__c') && editableFields.includes('Core_MDF_Campaign_Budgets__c')))) {
							this.disableCampaignBudgets = this.disableContractLineItems = true;
						}
					}
					this.getPicklistValFromCPObj();
				}
				if (this.validOutcomeMetricRecordType.includes(this.recordTypeDeveloperName)) {

					if (this.mode == 'edit' || this.mode == 'clone') {
						updateOutcomeFieldVisibility(this.campaignFieldValue["StartDate"], this);
					}
					if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
						this.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = this.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] ? true : (checkForUndefinedEmptyAndNull(this.activityListEdit) && this.activityListEdit.length > 0);
						this.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = !(this.accountBasedIndicatorCamp && this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]);
						if (this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]) {
							this.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = true;
						}
						this.showOtherOutcomeTextField();
						this.filterOtherFromOutcomeMetric();
					}

					if (this.mode == 'clone') {
						if (this.validOutcomeMetricRecordType.includes(this.recordTypeDeveloperName)) { 
							this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.proposalBasedIndicatorCamp && this.campaignFieldValue["StartDate"] >= campaignIPAOutcomeConfigureDate ? true : false;
							const customEvent = new CustomEvent('outcomechange', {
								detail: { value: this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]}
							});
							this.dispatchEvent(customEvent);
							if(this.campaignFieldValue["StartDate"] >= dateOct2025){
								this.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = true;
								this.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = true;
							}else{
								this.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = false;
								this.campaignFieldValue["Core_MDF_Other_Outcome_Criteria_txt__c"] = null;
								this.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = false;
							}	
						}
						this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = null;
						this.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
						this.campaignFieldValue["Core_MDF_Other_Outcome_Criteria_txt__c"] = null;

						const activityCategoryValue = this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"];
						if(this.validOutcomeMetricRecordTypeWithOutIPA.includes(this.recordTypeDeveloperName) && !this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] && checkForUndefinedEmptyAndNull(activityCategoryValue) && activityCategoryValue.includes('Outcome-Based->Outcome-Based')){
							this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"] = null;//TWC3117-14626
						}						
					}
					this.setColumns();
				}
				getpicklistSize(this.multiSelectPickFlds, this);
				if(this.recordTypeDeveloperName == Core_MDF_EEF_RecordType){
					this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = 'Cloud';
				}
			})
			.catch(e => { console.log(e); this.isLoaded = false; this.btnDisabled["saveBtn"] = false; this.scrollUp(); });
	}
	handleActPartnerAccountSelection(event) {
		handleISVAccountSelection(event, this);
	}
	
	setColumns() {
		if (this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true) { 
			this.columns = [
				{ label: this.outcomeFieldLabels["Core_MDF_Outcomes_nm__c"], fieldName: 'outcome', displayField: 'outcomeLabel', editable: false },
				{ label: this.outcomeFieldLabels["Core_MDF_Initial_Baseline_Quantity_nbr__c"], fieldName: 'baselineQuantity', editable: !this.campaignFieldDisabled["Core_MDF_Initial_Baseline_Quantity_nbr__c"], type: 'number', required: this.outcomeFieldRequired["Core_MDF_Initial_Baseline_Quantity_nbr__c"], min: 0, max: 2147483647, step: 1, helpText: this.outcomeFieldHelpText["Core_MDF_Initial_Baseline_Quantity_nbr__c"] },
				{ label: this.outcomeFieldLabels["Core_MDF_Goal_Quantity_nbr__c"], fieldName: 'goalQuantity', editable: !this.campaignFieldDisabled["Core_MDF_Goal_Quantity_nbr__c"], type: 'number', required: this.outcomeFieldRequired["Core_MDF_Goal_Quantity_nbr__c"], min: 1, max: 2147483647, step: 1, helpText: this.outcomeFieldHelpText["Core_MDF_Goal_Quantity_nbr__c"] }
			];
		} else {
			this.columns = [
				{ label: this.outcomeFieldLabels["Core_MDF_Outcomes_nm__c"], fieldName: 'outcome', displayField: 'outcomeLabel', editable: false },
				{ label: this.outcomeFieldLabels["Core_MDF_Goal_Quantity_nbr__c"], fieldName: 'goalQuantity', editable: !this.campaignFieldDisabled["Core_MDF_Goal_Quantity_nbr__c"], type: 'number', required: this.outcomeFieldRequired["Core_MDF_Goal_Quantity_nbr__c"], min: 1, max: 2147483647, step: 1, helpText: this.outcomeFieldHelpText["Core_MDF_Goal_Quantity_nbr__c"] },
				
			];
		}
		const baselinePeriodOptions = Object.entries(this.outcomePicklistValues["Core_MDF_Baseline_Period_nm__c"] || {}).map(([value, label]) => ({ label, value }));
		
		if(this.isIPAProposalBasedProgram){
			if (this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true) {  //Roshan - 17969
				this.columns.push({ label: this.outcomeFieldLabels["Core_MDF_Baseline_Period_nm__c"], fieldName: 'baselinePeriod', editable: !this.campaignFieldDisabled["Core_MDF_Baseline_Period_nm__c"], type: 'picklist', required: true, options: baselinePeriodOptions, placeholder: this.outcomeFieldLabels["Core_MDF_Baseline_Period_nm__c"], cellClass: 'col-lg', helpText: this.outcomeFieldHelpText["Core_MDF_Baseline_Period_nm__c"] });
			}
			this.columns.push({ label: this.outcomeFieldLabels["Core_MDF_Quantity_nbr__c"], fieldName: 'quantity', editable: !this.campaignFieldDisabled["Core_MDF_Quantity_nbr__c"], type: 'number', helpText: this.outcomeFieldHelpText["Core_MDF_Quantity_nbr__c"], min: 1, max: 2147483647 });
			const hasOutcomeCriteriaData = (this.rows || []).some(row => checkForUndefinedEmptyAndNull(row.outcomeCriteria));
			if (hasOutcomeCriteriaData) {
				this.columns.push({ label: this.outcomeFieldLabels["Core_MDF_Outcome_Criteria_txt__c"], fieldName: 'outcomeCriteria', editable: false, type: 'textarea', maxLength: 1000, required: this.outcomeFieldRequired["Core_MDF_Outcome_Criteria_txt__c"], helpText: this.outcomeFieldHelpText["Core_MDF_Outcome_Criteria_txt__c"] });
			}
		} else{
			this.columns.push({ label: this.outcomeFieldLabels["Core_MDF_Quantity_nbr__c"], fieldName: 'quantity', editable: !this.campaignFieldDisabled["Core_MDF_Quantity_nbr__c"], type: 'number', helpText: this.outcomeFieldHelpText["Core_MDF_Quantity_nbr__c"], min: 1, max: 2147483647 });
			this.columns.push({ label: this.outcomeFieldLabels["Core_MDF_Outcome_Criteria_txt__c"], fieldName: 'outcomeCriteria', editable: !this.campaignFieldDisabled["Core_MDF_Outcome_Criteria_txt__c"], type: 'textarea', maxLength: 1000, required: this.outcomeFieldRequired["Core_MDF_Outcome_Criteria_txt__c"], helpText: this.outcomeFieldHelpText["Core_MDF_Outcome_Criteria_txt__c"] });
		}
	}

	async getPicklistValFromCPObj() {
		if (this.recordTypeDeveloperName !== Core_MDF_IPA_RecordType) {
			let controllingFieldValue = [];
			let selectedProgram = this.campaignFieldValue['Core_MDF_Program__c'];
			controllingFieldValue.push(selectedProgram);
			if (this.mode == 'edit' || this.mode == 'clone') {
				if (this.recordTypeDeveloperName == rmfRecTypeNm) {
					controllingFieldValue.push(this.campaignFieldValue['Core_MDF_Budget_Type_txt__c']);
				} else if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType) {
					controllingFieldValue.push(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']);
				} else {
					let selBT = JSON.parse(JSON.stringify(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']));
					controllingFieldValue.push(...selBT)
				}
				let wrapper = await fetchPicklist(this.recordTypeDeveloperName, this.campaignPicValues, controllingFieldValue, this.picklistApitoLabelReferenceMap, 'loadAllFields', this);
				this.campaignPicValues = wrapper.campaignPicValues;
				this.getActcategoryTypeValues();
				this.initalLoad = false;
				if (this.mode == 'edit') { this.campaignPicValues = lovValuesAddition(this.campaignPicValues, this.campaignFieldValue, this.recordTypeDeveloperName, this.picklistApitoLabelReferenceMap, this); this.accountDisable = true; this.accountVisible = false; }
				this.campaignFieldValue = this.mode === 'clone' ? validatePicklistvalues(this.campaignPicValues, this.campaignFieldValue, this.campaignFields, this) : this.campaignFieldValue;
				let selectedBudget;
				if (this.recordTypeDeveloperName == rmfRecTypeNm) {
					selectedBudget = this.campaignFieldValue['Core_MDF_Budget_Type_txt__c']
				}else if(this.recordTypeDeveloperName === Core_MDF_EEF_RecordType){
					fetchCampToActPartnerData(this);
				} else {
					selectedBudget = this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'];
				}
				if (selectedBudget == "" || selectedBudget == null || selectedBudget == undefined) {
					this.loadBudgetTypefields = false; this.dynamicload = false; this.isLoaded = false;
				}
				if (this.mode === 'clone') { validateSelectedBudgets(this); }
				getpicklistSize(this.multiSelectPickFlds, this);
				if (this.priorityValuesForRollback["initiallyAssigned"] != true && (this.mode === 'clone' || this.mode == 'edit') && (this.recordTypeDeveloperName == this.ccfRecordType || this.recordTypeDeveloperName == this.dcfRecordType
					|| this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName == rmfRecTypeNm)) {
						this.priorityValuesForRollback["Core_MDF_Priority_2_nm__c"] = this.campaignFieldValue["Core_MDF_Priority_2_nm__c"];
						this.priorityValuesForRollback["Core_MDF_Priority_3_nm__c"] = this.campaignFieldValue["Core_MDF_Priority_3_nm__c"];
						this.priorityValuesForRollback["initiallyAssigned"] = true;
				}
				this.isLoaded = false;
			} else {
				let selContext;
				if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType) {
					selContext = 'loadAllFields';
					let ctrlFields = this.recordTypeDeveloperName == Core_MDF_EEF_RecordType ? this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] :  'Co-Engineering';
					controllingFieldValue.push(ctrlFields);
				} else {
					selContext = 'loadFieldsBasedOnProgram';
				}
				let wrapper = await fetchPicklist(this.recordTypeDeveloperName, this.campaignPicValues, controllingFieldValue, this.picklistApitoLabelReferenceMap,selContext, this);
				this.campaignPicValues = wrapper.campaignPicValues;
				if(this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType && checkForUndefinedEmptyAndNull(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']) && this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'].length > 0) {
					this.loadBudgetTypefields = true;
				}
				this.getActcategoryTypeValues();
				this.isLoaded = false;
			}
		}
	}
	editActivityOnCamp(event) {
		let actId = event.target.name;
		var selectedEvent = new CustomEvent('recSelectedAct', { detail: {actId: actId, oldActivityListClone : this.activityListClone}});
		this.dispatchEvent(selectedEvent);
		this.expandDetail = 'A';
		var campaignAttributeChangeEvt = new CustomEvent('campaignAttributeChangeEvt', { detail: {fieldValue: this.campaignFieldValue} });
		this.dispatchEvent(campaignAttributeChangeEvt);
	}
	handleIntCampChange(event) {
		this.campaignFieldValue["Core_MDF_Integrated_Campaign__c"] = event.target.value;
		if (event.target.value == 'Yes') {
			this.campaignRequiredFields["Core_MDF_Integrated_Campaign_Details__c"] = true;
		} else {
			this.campaignRequiredFields["Core_MDF_Integrated_Campaign_Details__c"] = false;
		}
	}
	handleDateChanges(event) {
		handleDateChange(event, this);
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true) {
			this.filterOtherFromOutcomeMetric();
		}
		//Aditya TWC3117-17805 
		this.validateCCFDCFStartDateError();
	}
	handleOEMDateChanges(event) {
		handleOEMDateChange(event, this);
	}
	handlePriorityChange(event) {
		let PriorityCmp = this.template.querySelector(".Priority");
		let SecondPriorityCmp = this.template.querySelector(".SecondPriority");
		let ThirdPriorityCmp = this.template.querySelector(".ThirdPriority");
		if (event.target.name == 'Core_MDF_Priority__c') {
			this.campaignFieldValue["Core_MDF_Priority__c"] = event.target.value;
			if(this.status === 'Draft'){
				this.campaignFieldDisabled["Core_MDF_Priority_Percentage__c"] = false;
			}
		} else if (event.target.name == 'Core_MDF_Priority_2_nm__c') {
			this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] = event.target.value;
			handlePriorityNoneValueSelection(event, this, 'Core_MDF_Priority_Percentage_2__c', '.SecondPriorityPercentage');
		} else if (event.target.name == 'Core_MDF_Priority_3_nm__c') {
			this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] = event.target.value;
			handlePriorityNoneValueSelection(event, this, 'Core_MDF_Priority_Percentage_3__c', '.ThirdPriorityPercentage');
		}
		if(this.recordTypeDeveloperName != Core_MDF_Co_GTM_RecordType) {
			if (((this.campaignFieldValue["Core_MDF_Priority__c"] == this.campaignFieldValue["Core_MDF_Priority_2_nm__c"]) && this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] != '') ||
			((this.campaignFieldValue["Core_MDF_Priority__c"] == this.campaignFieldValue["Core_MDF_Priority_3_nm__c"]) && this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] != '') && this.campaignFieldValue["Core_MDF_Priority__c"] != '') {
			PriorityCmp.setCustomValidity("Select a value not already selected for Priority #2 or Priority #3.");
			PriorityCmp.reportValidity();
		} else {
			PriorityCmp.setCustomValidity("");PriorityCmp.reportValidity();
		}
		if ((this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] !== 'None') && (((this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] == this.campaignFieldValue["Core_MDF_Priority_3_nm__c"]) &&
			this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] != '' && this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] != '') ||
			(this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] == this.campaignFieldValue["Core_MDF_Priority__c"]) && this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] != '')) {
			SecondPriorityCmp.setCustomValidity("Select a value not already selected for Priority or Priority #3.");
			SecondPriorityCmp.reportValidity();
		} else {
			SecondPriorityCmp.setCustomValidity("");
			SecondPriorityCmp.reportValidity();
		}
		if ((this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] !== 'None') && (((this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] == this.campaignFieldValue["Core_MDF_Priority_2_nm__c"]) &&
			this.campaignFieldValue["Core_MDF_Priority_2_nm__c"] != '' && this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] != '') ||
			(this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] == this.campaignFieldValue["Core_MDF_Priority__c"]) && this.campaignFieldValue["Core_MDF_Priority_3_nm__c"] != '')) {
			ThirdPriorityCmp.setCustomValidity("Select a value not already selected for Priority or Priority #2.");
			ThirdPriorityCmp.reportValidity();
		} else {
			ThirdPriorityCmp.setCustomValidity("");ThirdPriorityCmp.reportValidity();
		}
		}
		
	}
	handlePriorityPctChange(event){
		if((this.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_CCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_DCF_Program_Name) && this.campaignSource === 'Target Setting'){
			if(event.target.name === 'Core_MDF_Priority_Percentage__c'){
				if(!isNaN(parseFloat(event.target.value))){
					this.priorityPer1 = parseFloat(event.target.value);
				}else if(isNaN(parseFloat(event.target.value))){
					this.priorityPer1 = 0;
					event.target.value = 0;
				}
			}
			if(event.target.name === 'Core_MDF_Priority_Percentage_2__c'){
				if(!isNaN(parseFloat(event.target.value))){
					this.priorityPer2 = parseFloat(event.target.value);
				}else if(isNaN(parseFloat(event.target.value))){
					this.priorityPer2 = 0;
					event.target.value = 0;
				}
			}
			if(event.target.name === 'Core_MDF_Priority_Percentage_3__c'){
				if(!isNaN(parseFloat(event.target.value))){
					this.priorityPer3 = parseFloat(event.target.value);
				}else if(isNaN(parseFloat(event.target.value))){
					this.priorityPer3 = 0;
					event.target.value = 0;
				}
			}
		}
	}
	handleCategoryTypeChange(event) {
		this.selectedActCatTypePicValues = event.target.value;
		this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"] = event.target.value;
		if (this.mode != 'edit' || this.mode != 'clone') {
			this.activityCategoryValues = this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"];
		}
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_CCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_DCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_EEF_Program_Name){
			this.handlePicklistDependentValueChange(event);
		}
		// Ealaya TWC3117-14432 Activity Category changes -->
		this.validateActivityCategory();
		// Ealaya TWC3117-14432 Activity Category changes -->
	}
	handleInitiativeChange(event) {
		this.campaignFieldValue["Core_MDF_Initiative_nm__c"] = event.target.value;
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_DCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_Retail_Program_Name) {
			this.handlePicklistDependentValueChange(event);
			this.throwErrorOnNonevalueSelection(event, '.validateNoneForInitiative');
			if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && !event.target.value.includes('None')) { this.validatePickValuesBasedOnFocusArea(event); }
		}
	}
	handleBrandChange(event) {
		this.campaignFieldValue["Core_MDF_Brand__c"] = event.target.value; this.handlePicklistDependentValueChange(event);
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) { this.validatePickValuesBasedOnFocusArea(event); }
	}
	handleEcosystemPartnerChange(event) {
		this.campaignFieldValue["Core_MDF_Ecosystem_Partner_Nm__c"] = event.target.value;
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) { 
			this.handlePicklistDependentValueChange(event);
		}
		this.throwErrorOnNonevalueSelection(event, '.validateNoneForEcoSystemPartner');
		this.othersMandate(event.target.name, event.target.value);
	}
	handleOtherEcoSystemPartner(event){this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] = event.target.value;}
	throwErrorOnNonevalueSelection(event, className) {
		var inputCmp = this.template.querySelector(className);
		if (event.target.value.includes('None') && event.target.value.length > 1)
			inputCmp.setCustomValidity(event.target.name === 'Core_MDF_Initiative_nm__c' ? Core_MDF_IPA_Initiave_None_Selection_Error : event.target.name === 'Core_MDF_Technology__c' ? noneSelErrRMFTechnology : noneSelErrIPACampEcosysPartner);
		else
			inputCmp.setCustomValidity('');
	}
	throwErrorOnOthersvalueSelection(values, className) {
		var inputCmp = this.template.querySelector(className);
		if (values.includes('Others') && values.length > 1) {
			inputCmp.setCustomValidity(Core_MDF_IPA_Others_Selection_Error);
		} else {
			inputCmp.setCustomValidity('');
		};
		inputCmp.reportValidity();
	}
	handleIndustryChange(event) {
		this.campaignFieldValue["Core_MDF_Industry_Nm__c"] = event.target.value;
		this.handlePicklistDependentValueChange(event);
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) {
			this.naValidate(event.target.name, event.target.value);
		}
	}
	handleProductTypeChange(event) {
		this.campaignFieldValue['Core_MDF_Product_Type__c'] = event.target.value;
		this.handlePicklistDependentValueChange(event);
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) {
			this.validatePickValuesBasedOnFocusArea(event);
		}
	}
	handleIPAPriorityChange(event) {
		this.campaignFieldValue["Core_MDF_IPA_Priority_nm__c"] = event.target.value;
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) {
			this.handlePicklistDependentValueChange(event); this.validatePickValuesBasedOnFocusArea(event);
		}
	}

	validatePickValuesBasedOnFocusArea(event, dependentFields) {
		let focusAreaDependentErrorWrapper;
		if (checkForUndefinedEmptyAndNull(dependentFields) && dependentFields.length > 0) {
			dependentFields.map(field => {
				focusAreaDependentErrorWrapper = validatePickListValuesBasedOnFC(this.campaignFieldValue[field], this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"], field, this.focusAreaDependentFieldValues, this.campaignPicValues["Core_MDF_Focus_Area_nm__c"]);
				this.throwFocusAreaDependentValuesError(field, focusAreaDependentErrorWrapper);
			})
		} else {
			focusAreaDependentErrorWrapper = validatePickListValuesBasedOnFC(event.target.value, this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"], event.target.name, this.focusAreaDependentFieldValues, this.campaignPicValues["Core_MDF_Focus_Area_nm__c"]);
			this.throwFocusAreaDependentValuesError(event.target.name, focusAreaDependentErrorWrapper);
		}
	}

	throwFocusAreaDependentValuesError(elementName, focusAreaDependentErrorWrapper) {
		let inputCmp = this.template.querySelector('[data-name="' + elementName + '"]');
		if (checkForUndefinedEmptyAndNull(focusAreaDependentErrorWrapper) && Object.keys(focusAreaDependentErrorWrapper).length > 0 && focusAreaDependentErrorWrapper.hasNoOnevalueSelectedFromEachFC)
			inputCmp.setCustomValidity(focusAreaDependentValueError + ' '+ focusAreaDependentErrorWrapper.noSingleValueSelectedFocusAreas);
		else
			inputCmp.setCustomValidity('');
		inputCmp.reportValidity();
	}
	handleTechnologyChange(event) {
		this.campaignFieldValue["Core_MDF_Technology__c"] = event.target.value;
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_Retail_Program_Name) {
			this.throwErrorOnNonevalueSelection(event, '.validateNoneForTechnology');
		}
	}
	handleUseCaseChange(event) { this.campaignFieldValue["Core_MDF_Use_Case_Nm__c"] = event.target.value; }
	handleMeasurementApproachChange(event) {
		const selectedValues = event.detail.value;
		this.campaignFieldValue["Core_MDF_Measurement_Approach_nm__c"] = selectedValues;
		const isOtherSelected = checkForUndefinedEmptyAndNull(selectedValues) && selectedValues.includes(Core_MDF_Other_Specify);
		this.campaignFieldVisibility["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherSelected;
		this.campaignRequiredFields["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherSelected;
		if (!isOtherSelected) {
			this.campaignFieldValue["Core_MDF_Other_Measurement_Approach_txt__c"] = null;
		}
	}
	// Re-applies "Other (Specify)" driven state; dynamic field reloads reset required/visibility maps.
	showOtherMeasurementApproachVisibility() {
		const selectedValues = this.campaignFieldValue["Core_MDF_Measurement_Approach_nm__c"];
		const isOtherSelected = checkForUndefinedEmptyAndNull(selectedValues) && selectedValues.includes(Core_MDF_Other_Specify);
		this.campaignFieldVisibility["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherSelected;
		this.campaignRequiredFields["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherSelected;
	}
	handleOtherMeasurementApproachChange(event) { this.campaignFieldValue["Core_MDF_Other_Measurement_Approach_txt__c"] = event.target.value; }
	handleAudienceChange(event) {
		this.campaignFieldValue["Core_MDF_Audience__c"] = event.target.value; this.handlePicklistDependentValueChange(event);
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) { this.validatePickValuesBasedOnFocusArea(event); }
	}
	setCCFDCFFields(budgetType) {
		try {
			this.finalDependentVal = [];
			let selectedVal;
			if (this.campaignFieldValue["Core_MDF_Integrated_Campaign__c"] == 'Yes') {
				this.campaignRequiredFields["Core_MDF_Integrated_Campaign_Details__c"] = true;
			}
			if (budgetType == 'CCF 1.0' || budgetType == 'DCF 1.0') {
				selectedVal = 'Yes';
				this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'Yes';
				this.showLegacyFields = true;
				this.showAvailableBudgets = false;
				this.showAvailableBudgetRequired = false;
				this.showCampaignBudgets = false;
				this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
				if (this.mode != 'edit' && this.mode != 'clone') {
					this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '50%';
				}
				this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
			}
			if (budgetType != undefined && budgetType != null && budgetType != '' && budgetType.length > 1 && (budgetType.includes('CCF 1.0') || budgetType.includes('DCF 1.0'))) {
				this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'Yes';
				this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
				this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
				this.showLegacyFields = false;
				this.showAvailableBudgets = false;
				this.showAvailableBudgetRequired = false;
				this.showCampaignBudgets = false;
			}
			if (budgetType != undefined && budgetType != null && budgetType != '' && !budgetType.includes('CCF 1.0') && !budgetType.includes('DCF 1.0')) {
				if (this.campaignFieldValue["Core_MDF_Program__c"] != Core_MDF_IPA_Program_Name) {
					this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '';
					this.campaignFieldValue["Core_MDF_First_Year_Budget_Amount__c"] = '';
					this.campaignFieldValue["Core_MDF_Second_Year_Budget_Amount__c"] = '';
				}
				this.showLegacyFields = false;
				this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
				this.campaignFieldValue["Core_MDF_Spending_Cap_Amt__c"] = '';
			}
			if ((this.campaignFieldValue["Core_MDF_Account__c"] != null && this.campaignFieldValue['Core_MDF_Account__c'] !== undefined && this.campaignFieldValue['Core_MDF_Account__c'] !== '') &&
				(this.campaignFieldValue['StartDate'] !== undefined && this.campaignFieldValue['StartDate'] != null && this.campaignFieldValue['StartDate'] !== '') &&
				(this.campaignFieldValue['EndDate'] !== '' && this.campaignFieldValue['EndDate'] !== undefined && this.campaignFieldValue['EndDate'] != null) &&
				(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] !== '' && this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] != undefined && this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] != null) &&
				(this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_CCF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_DCF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_EEF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_Co_GTM_Technical_program_name) &&
				(this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] == false)) {
				this.resetBudgetRelatedFlags();
				if (this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] != 'Yes') {
					let selAccount = this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType ? checkForUndefinedEmptyAndNull(this.virtualCorpAccId) ? this.virtualCorpAccId :this.campaignFieldValue["Core_MDF_Account__c"]   : this.campaignFieldValue["Core_MDF_Account__c"];
					this.getBudgetsForCampaign(selAccount, this.campaignFieldValue["StartDate"], this.campaignFieldValue["EndDate"], this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"]);
				}
			}
		} catch (e) { console.log(e); }
	}
	setSupportLegacyProgramField(budgetTypes, year, target) {
		try {
			let actCategoryTypeVals;
			let throwDateValidation = false;
			let startYear = year != undefined ? year : this.startYearOfCampaign;
			let actCatTypeValuesToRetain = [];
			if (checkForUndefinedEmptyAndNull(budgetTypes) && checkForUndefinedEmptyAndNull(startYear)) {
				if ((budgetTypes.includes('OEM CMP') || budgetTypes.includes('Service Provider CMP')) && (!budgetTypes.includes('MDF') && !budgetTypes.includes('MDF+'))) {
					this.supportsLegacy = startYear >= campaignStartYear ? 'New CMP only' : 'CMP only';
				} else {
					this.supportsLegacy = startYear >= campaignStartYear ? 'New MDF or both CMP & MDF' : 'MDF or both CMP & MDF';
				}
				this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = this.supportsLegacy;

				if (this.recordTypeDeveloperName != Core_MDF_IPA_RecordType && this.recordTypeDeveloperName != rmfRecTypeNm) {
					actCategoryTypeVals = fetchActivityCategoryTypeValues(this.supportsLegacy, this.activityCategoryTypeValuesFromCPObject, this.picValuesByRecType, this);
				}
				if (this.mode == 'edit' && (target == 'StartDate' || target == 'budgetType' || this.initalLoad)) {
					if (this.initalLoad) {
						//here 'before2025' means year of campaign start date is before 2025 and 'equalsOrAfter2025' means year of campaign start date is equals or after 2025
						this.campaignStartDateInitialPhase = startYear < 2025 ? 'before2025' : 'equalsOrAfter2025';
						this.campaignStartDatePrevPhase = startYear < 2025 ? 'before2025' : 'equalsOrAfter2025';
						this.campaignStartDateCurrPhase = startYear < 2025 ? 'before2025' : 'equalsOrAfter2025';
					} else {
						//THIS BLOCK: to handle activity category type values based on campaign start date change or budget type values change
						this.campaignStartDatePrevPhase = this.campaignStartDateCurrPhase;
						this.campaignStartDateCurrPhase = startYear < 2025 ? 'before2025' : 'equalsOrAfter2025';
						//to throw error when campaign start date is changed from before 2025 to equals or greater than 2025 or from 2025 to smaller than 2025
						if (this.activityListEdit?.length > 0 && checkForUndefinedEmptyAndNull(this.campaignStartDateInitialPhase)) {
							if (checkForUndefinedEmptyAndNull(this.campaignStartDateCurrPhase)) {
								throwDateValidation = (this.campaignStartDateInitialPhase != this.campaignStartDateCurrPhase) ? true : false;
							}
						}
						let selectedActCatTypeValues = []
						let selectedActCatTypeValuesSet;
						if (target == 'StartDate') {
							if (this.campaignStartDateCurrPhase == this.campaignStartDatePrevPhase) {
								//if start date is changed and it is of same phase => retain values
								selectedActCatTypeValues = [...this.campaignFieldValue['Core_MDF_Activity_Category_Type__c']];
							} else if (this.campaignStartDateCurrPhase != this.campaignStartDatePrevPhase) {
								//to store activity category type values for switching phase of start date year
								if (this.campaignStartDatePrevPhase == 'before2025' && this.campaignStartDateCurrPhase == 'equalsOrAfter2025') {
									this.campaignBefore2025ActCatTypeValues = [...this.campaignFieldValue['Core_MDF_Activity_Category_Type__c']];
								} else if (this.campaignStartDatePrevPhase == 'equalsOrAfter2025' && this.campaignStartDateCurrPhase == 'before2025') {
									this.campaignEqualsOrAfter2025ActCatTypeValues = [...this.campaignFieldValue['Core_MDF_Activity_Category_Type__c']];
								}
								//to retain values recently selected values when switching phase of start date year
								if (this.campaignStartDateCurrPhase == 'before2025') {
									//if budget is not changed once
									if (!this.isBudgetTypeChangedOnce) {
										selectedActCatTypeValues = [...this.campaignBefore2025ActCatTypeValues];
									} else {
										//filter before assigning
										this.campaignFieldValue['Core_MDF_Activity_Category_Type__c'] = [...this.campaignBefore2025ActCatTypeValues];
										actCatTypeValuesToRetain = this.retainActivityAssociatedActCatTypes();
										actCategoryTypeVals = [...actCategoryTypeVals, ...actCatTypeValuesToRetain];
										this.updateActCategoryTypeValues(actCategoryTypeVals);
									}
								} else if (this.campaignStartDateCurrPhase == 'equalsOrAfter2025') {
									if (!this.isBudgetTypeChangedOnce) {
										selectedActCatTypeValues = [...this.campaignEqualsOrAfter2025ActCatTypeValues];
									} else {
										//filter before assigning
										this.campaignFieldValue['Core_MDF_Activity_Category_Type__c'] = [...this.campaignEqualsOrAfter2025ActCatTypeValues];
										actCatTypeValuesToRetain = this.retainActivityAssociatedActCatTypes();
										actCategoryTypeVals = [...actCategoryTypeVals, ...actCatTypeValuesToRetain];
										this.updateActCategoryTypeValues(actCategoryTypeVals);
									}
								}
							}
							if (!this.isBudgetTypeChangedOnce) {
								let actCatType = { 'Core_MDF_Activity_Category_Type__c': actCategoryTypeVals }
								selectedActCatTypeValuesSet = new Set(selectedActCatTypeValues);
								this.campaignFieldValue['Core_MDF_Activity_Category_Type__c'] = [...selectedActCatTypeValuesSet];
								let validActCatTypeValues = lovValuesAddition(actCatType, this.campaignFieldValue, this.recordTypeDeveloperName, this.picklistApitoLabelReferenceMap, this, 'activityCategoryType');
								let finalActCatType = validActCatTypeValues['Core_MDF_Activity_Category_Type__c'];
								actCatTypeValuesToRetain = this.retainActivityAssociatedActCatTypes();
								finalActCatType = [...finalActCatType, ...actCatTypeValuesToRetain];
								actCategoryTypeVals = finalActCatType;
								this.updateActCategoryTypeValues(actCategoryTypeVals);
							}
						}
						if (target == 'budgetType') {
							this.isBudgetTypeChangedOnce = true;
							//filter before assigning
							actCatTypeValuesToRetain = this.retainActivityAssociatedActCatTypes();
							actCategoryTypeVals = [...actCategoryTypeVals, ...actCatTypeValuesToRetain];
							this.updateActCategoryTypeValues(actCategoryTypeVals);
						}
					}
					if (!throwDateValidation) {
						actCatTypeValuesToRetain = this.retainActivityAssociatedActCatTypes();
						actCategoryTypeVals = [...actCategoryTypeVals, ...actCatTypeValuesToRetain];
						this.campaignPicValues["Core_MDF_Activity_Category_Type__c"] = actCategoryTypeVals;
					} else {
						return throwDateValidation;
					}
				} else {
					this.updateActCategoryTypeValues(actCategoryTypeVals);
				}
			}		
		} catch (e) { console.log(e); }
	}

	updateActCategoryTypeValues(actCategoryTypeVals) {
		this.campaignPicValues["Core_MDF_Activity_Category_Type__c"] = actCategoryTypeVals;
		let fieldDetails = [
			{
				'fieldAPIName': "Core_MDF_Activity_Category_Type__c",
				'fieldLabel': "Activity Category ->Type",
				'fieldType': "PICKLIST",
			}
		]
		this.campaignFieldValue = validatePicklistvalues(this.campaignPicValues, this.campaignFieldValue, fieldDetails, this);
	}
	retainActivityAssociatedActCatTypes(){
		//add Activity_Category_Type values associated with activity which got removed on budget type change on campaign edit
		let valuesToRetain  = [];
		if(this.mode == 'edit' && checkForUndefinedEmptyAndNull(this.activityListEdit) && this.activityListEdit.length > 0){
			let activityAssociatedActCatTypes = [];
			activityAssociatedActCatTypes = getValuesRefOnActivities('Core_MDF_Activity_Category_Type__c', 'Activity_Category_Type', this);
			activityAssociatedActCatTypes.forEach(actCatTypeValue => {
				valuesToRetain.push(
					{class: 'optionClass', label: actCatTypeValue, value: actCatTypeValue}
				);
			});
		}
		return valuesToRetain;
	}

	clearValuesIfProposalCamp() {
		this.campaignFieldValue["Core_MDF_Total_Campaign_Cost_Amt__c"] = ''; this.finalRRrate = ''; this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = ''; calReimbursementAmt(this);
	}
	checkSelPicVal() {
		this.selectedActCatTypePicValues = this.campaignFieldValue?.['Core_MDF_Activity_Category_Type__c'];
		if (this.selectedActCatTypePicValues != undefined && this.selectedActCatTypePicValues != null && this.selectedActCatTypePicValues != '') {
			let allValues = this.finalDependentVal;
			if (allValues != null && allValues != undefined) {
				let index = 0;let arrLength = allValues.length;
				let missingValues = [];var allValueArray = [];
				for (index = 0; index < arrLength; index++) {
					allValueArray = [...allValueArray, allValues[index].value];
				}
				for (let index2 = 0; index2 < this.selectedActCatTypePicValues.length; index2++) {
					if (!allValueArray.includes(this.selectedActCatTypePicValues[index2])) {
						let obj = {label: this.selectedActCatTypePicValues[index2],value: this.selectedActCatTypePicValues[index2]};
						missingValues = [...missingValues, obj];
					}
				}
				if (this.mode == 'clone' || this.mode == 'edit') {
					let newValues = [];var missingValuesArr = [];
					for (let index2 = 0; index2 < missingValues.length; index2++) {
					if (!missingValuesArr.includes(missingValues[index2].value)) {
					missingValuesArr = [...missingValuesArr, missingValues[index2].value];}}
					if (missingValuesArr != null && missingValuesArr != undefined && missingValuesArr != '' && this.selectedActCatTypePicValues != undefined && this.selectedActCatTypePicValues != null && this.selectedActCatTypePicValues != '') {
					for (let index = 0; index < this.selectedActCatTypePicValues.length; index++) {
					if (!missingValuesArr.includes(this.selectedActCatTypePicValues[index])) {
					if (!newValues.includes(this.selectedActCatTypePicValues[index])) {
					newValues = [...newValues, this.selectedActCatTypePicValues[index]];}}}
		if (newValues != undefined && newValues != null && newValues.length > 0) {
		this.selectedActCatTypePicValues = newValues;}}}}}
	}
	handleStandardFields(event) {
		if (event.target.name == "Name") {
			const nameValue = event.target.value;
			const hasOnlySpaces = /^\s*$/.test(nameValue);
	
			if (hasOnlySpaces) {
				event.target.setCustomValidity(completeThisFieldErr);
				console.error('Complete this field.');
			} else {
				event.target.setCustomValidity('');
				this.campaignFieldValue[event.target.name] = nameValue;
			}
		} else if (event.target.name == "Description") {
			this.campaignFieldValue["Description"] = event.target.value;
		} else if (event.target.name == "StartDate") {
			this.campaignFieldValue["StartDate"] = event.target.value;
		} else if (event.target.name == "EndDate") {
			this.campaignFieldValue["EndDate"] = event.target.value;
		}
	}
	async populateDynamicfields(result) {
		var controllingFieldValue = [];
		controllingFieldValue.push(result["Core_MDF_Opal_Budget_Type_Txt__c"]);
		if(typeof result["Core_MDF_Focus_Area_nm__c"] != 'undefined' && typeof result["Core_MDF_Focus_Area_nm__c"] != null && typeof result["Core_MDF_Focus_Area_nm__c"] != ""){
			controllingFieldValue = controllingFieldValue.concat(result["Core_MDF_Focus_Area_nm__c"].split(';'));
		}
		this.handleDynamicfields(controllingFieldValue);
	}
	async handleDynamicfields(controllingFieldValue, context) {
		let updatedCFValue = [];
		updatedCFValue = JSON.parse(JSON.stringify(controllingFieldValue));
		updatedCFValue.push(this.campaignFieldValue['Core_MDF_Program__c']);
		this.ipacontrollingFieldValue = updatedCFValue; 
		this.isLoaded = true;
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
			this.getBudgetTypeValue(this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"], this.campaignFieldValue["Core_MDF_Program__c"]);
		} else {
			let wrapper = await fetchPicklist(this.recordTypeDeveloperName, this.campaignPicValues, updatedCFValue, this.picklistApitoLabelReferenceMap, 'loadAllfields', this); this.campaignPicValues = wrapper.campaignPicValues;
			if (this.mode == 'edit') { this.campaignPicValues = lovValuesAddition(this.campaignPicValues, this.campaignFieldValue, this.recordTypeDeveloperName, this.picklistApitoLabelReferenceMap, this); }
			this.getActcategoryTypeValues(context);		
			this.loadBudgetTypefields = true; this.isLoaded = false;
			getpicklistSize(this.multiSelectPickFlds, this);
		}
	}

	getActcategoryTypeValues(context) {
		let startYear = this.mode == 'edit' || this.mode == 'clone' ? (this.startYearOfCampaign != '' ? this.startYearOfCampaign : new Date(this.campaignRecord.StartDate).getUTCFullYear()) : this.startYearOfCampaign;
		if ((this.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName) || (this.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName) || (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType)) {
			this.setSupportLegacyProgramField(this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"], startYear, context);
		}
	}

	async callFetchPickValues(controllingFieldValue) {
		this.isLoaded = true;
		let wrapper = await fetchPicklist(this.campRecordTypeName, this.campaignPicValues, controllingFieldValue, this.picklistApitoLabelReferenceMap, 'loadAllFields', this);
		this.campaignPicValues = wrapper.campaignPicValues; this.focusAreaDependentFieldValues = wrapper.focusAreaDependentFieldValues;
		this.customPicklistValueDependency = wrapper.customPicklistValueDependency;
		
		//Calling prepActClassificationMapBasedOnActType to prepare Map for Activity Classification
		this.activityTypeToClassificationMap = prepActClassificationMapBasedOnActType(this.customPicklistValueDependency['Core_MDF_Activity_Classification_nm__c']);
		
		const pr = new Promise((resolve, reject) => {setTimeout(() => {resolve();}, 2000);});
		await Promise.allSettled([loadDynamicFields, fetchPicklist, getFieldSetName, pr]).then((val) => {
			if (checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) {
				this.setcustomRRValues();
				if(this.finalRRrate == null && this.finalRRrate == undefined && this.finalRRrate != '') {
					this.finalRRrate = '50%';} else {
					let rrIndex = this.customRRValues.findIndex(reimbursementRate => reimbursementRate.value == this.finalRRrate);
					this.finalRRrate = rrIndex == -1 ? '50%' : this.finalRRrate;}this.campaignFieldValue['Core_MDF_Reimbursement_Rate__c']= this.finalRRrate;}
			if (this.initalLoad) {
				this.getCampaignFields();this.initalLoad = false;}else {
				if (this.mode == 'edit') {
					let selFocusArea = this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"];
					let selectedContext;
					if(checkForUndefinedEmptyAndNull(selFocusArea) && selFocusArea.length == 1) {
						selectedContext = 'fieldsBasedOnProgram';
					}
					this.campaignPicValues = lovValuesAddition(this.campaignPicValues, this.campaignFieldValue, this.campRecordTypeName, this.picklistApitoLabelReferenceMap, this, selectedContext);
				}
				this.campaignFieldValue = validatePicklistvalues(this.campaignPicValues, this.campaignFieldValue, this.campaignFields, this);
				getpicklistSize(this.multiSelectPickFlds, this);
				this.filterOtherFromOutcomeMetric();
				this.isLoaded = false;
				}
			let ecoSystemValue = this.campaignFieldValue['Core_MDF_Ecosystem_Partner_Nm__c'];
			if(checkForUndefinedEmptyAndNull(ecoSystemValue) && ecoSystemValue.length>0){
				this.othersMandate('Core_MDF_Ecosystem_Partner_Nm__c',ecoSystemValue);
			}
			if (checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Initiative_nm__c"]) && this.campaignFieldValue["Core_MDF_Initiative_nm__c"].length > 0) { let inputCmp = this.template.querySelector('[data-name= Core_MDF_Initiative_nm__c]'); if (this.campaignFieldValue["Core_MDF_Initiative_nm__c"].includes('None') && this.campaignFieldValue["Core_MDF_Initiative_nm__c"].length > 1) { inputCmp.setCustomValidity(Core_MDF_IPA_Initiave_None_Selection_Error); inputCmp.reportValidity(); } }
		}).catch(e => { console.log(e); this.isLoaded = false; })
	}
	handleFocusAreaChange(event) {
		let selBudgetType = this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"];
		this.campaignFieldVisibility["Core_MDF_IPA_Priority_nm__c"] = true; let controllingFieldValue = []; this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"] = event.detail.value;
		controllingFieldValue.push(selBudgetType);
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) { this.handlePicklistDependentValueChange(event); }
		controllingFieldValue = controllingFieldValue.concat(Object.values(this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"]));
		this.handleDynamicfields(controllingFieldValue);
		if (this.dynamicload && this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) { let dependentFields = focusAreaDependentFields.split(','); this.validatePickValuesBasedOnFocusArea(event, dependentFields); }
	}
	handlePicklistDependentValueChange(event) {
		let pickListValuesOnChange = event.detail.value; let fieldAPIName = event.target.name;let labelValue = event.target.label;
		try {
			if(this.mode == 'clone' && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) {
				this.handlePicklistDependentValueChangeClone(pickListValuesOnChange, fieldAPIName, labelValue);
			} else if(this.mode == 'edit') {
				this.handlePicklistDependentValueChangeEdit(pickListValuesOnChange, fieldAPIName, labelValue);}
		} catch (error) {
			let applicationErrEvent = new CustomEvent('applicationerror', { detail: { errorLog: error?.stack } });
			this.dispatchEvent(applicationErrEvent);
		}
	}

	handlePicklistDependentValueChangeEdit(pickListValuesOnChange, campFieldAPIName, labelValue) {
		handlePicklistDependentValueChangeEdits(pickListValuesOnChange, campFieldAPIName, labelValue, this);
	}

	handleBudgetTypeChange(event) {
		let controllingFieldValue = []; this.campaignFieldValue[event.target.name] = event.detail.value;
		if (this.recordTypeDeveloperName == rmfRecTypeNm || this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) {
			controllingFieldValue.push(event.detail.value);
		} else {
			controllingFieldValue = event.detail.value;
		}
		this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = event.detail.value;
		this.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;

		let retrictBudgetTypeChange = false;

		if (this.mode == 'edit') {
			if (checkForUndefinedEmptyAndNull(this.activityListEdit) && this.activityListEdit.length > 0) {
				this.handlePicklistDependentValueChange(event);
				retrictBudgetTypeChange = (this.isActAssociatedBudgetTypeRemoved) ? true : false;
			}
		}

		if (!retrictBudgetTypeChange) {
			if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
				this.loadBudgetTypefields = true;
				this.isLoaded = true; this.onBudgetTypeChange = true;
				if (this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"] != "") {
					controllingFieldValue = controllingFieldValue.concat(Object.values(this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"]));
				} this.campaignFieldVisibility["Core_MDF_Focus_Area_nm__c"] = true;
			}
			this.handleDynamicfields(controllingFieldValue, 'budgetType');
			if (this.datevalid && this.recordTypeDeveloperName != Core_MDF_IPA_RecordType) {
				this.setCCFDCFFields(event.target.value);
			}
			this.showCampaignBudgets = false; this.campaignBudgets = [];
			if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.mode == 'clone') {
				this.getActivityCloneFields('Core_MDF_Custom_Picklist__c', event.target.value, this.recordTypeDeveloperName, this.proposalBasedIndicatorCamp, 'PartnerFundRequest');
			}
		}
		this.isActAssociatedBudgetTypeRemoved = false;
		
		this.validateIPAStartDateError();
	}

	async getBudgetTypeValue(budgettype, campProg) {
		if (budgettype !== undefined && budgettype !== null && budgettype !== '') {
			this.isLoaded = true;
			await getAccPropBasedValues({ campBudgetType: budgettype, program: campProg })
				.then((result) => {
					for (const key in result) {
						if (key == "Proposal Based") {
							this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] = true;this.accountBasedIndicatorCamp = false;
							this.proposalBasedIndicatorCamp = true;this.dynamicload = true;

							//Show Measurement Approach for IPA proposal based campaigns
							this.campaignFieldVisibility["Core_MDF_Measurement_Approach_nm__c"] = true;
							if(this.mode != 'edit') {
								this.clearValuesIfProposalCamp();
								if (this.mode == 'clone' && this.activityListClone.length > 0) {
									let selFA = this.campaignFieldValue['Core_MDF_Focus_Area_nm__c'];
									if (checkForUndefinedEmptyAndNull(selFA)) {
										this.checkIfClone = true;
									} else {
										this.checkIfClone = false;
									}
								}
							}
						} else if (key == "Account Based") {
							this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] = false;this.proposalBasedIndicatorCamp = false;
							this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'MDF or both CMP & MDF';
							this.accountBasedIndicatorCamp = true;this.dynamicload = true;
							this.campaignFieldVisibility["Core_MDF_Measurement_Approach_nm__c"] = false;
						}
					if (this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"] === "" && this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
					this.dynamicload = false;
				}
					this.campRecordTypeName = result[key];
					}
					this.getDynamicFields('Core_MDF_Custom_Picklist__c', this.ipacontrollingFieldValue, this.objectApiName);
					this.callFetchPickValues(this.ipacontrollingFieldValue);
					var today = new Date();this.memberVisibilityValid = false;
					this.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] = today.toISOString().split('T')[0];
					let visibilityDate = this.campaignFieldValue["Core_MDF_External_Visibility_Date__c"];
					let memberVisibilityDateCmp = this.template.querySelector(".memberVisibilityDate");
					if ((this.campaignFieldValue["StartDate"] != '' && this.campaignFieldValue["StartDate"] != undefined && this.campaignFieldValue["StartDate"] != null) &&
					(visibilityDate != '' && visibilityDate != undefined && visibilityDate != null) && memberVisibilityDateCmp == null) {
					if (visibilityDate > this.campaignFieldValue["StartDate"] && this.campaignFieldVisibility["Core_MDF_External_Visibility_Date__c"] == true) {
					this.memberVisibilityValid = true;}}})
		.catch(e => { console.log('error @@getBudgetTypeValue' + e) });
		}
	}

	async getDynamicFields(CustomPicklistObject, budgettype, currentObjAPIName) {
		this.isLoaded = true;
		await loadDynamicFields({pickListObj: CustomPicklistObject, budType: budgettype, objectName: currentObjAPIName})
			.then((result) => {
				this.campaignFields = result;
				if (this.oldCampFields != undefined || this.oldCampFields != null) {
					let oldFields = this.oldCampFields.values();
					for (const key of oldFields) {
						this.campaignFieldVisibility[key.fieldAPIName] = false;
					}
				}
				for (let i = 0; i < this.campaignFields.length; i++) {
					let fieldAPIName = this.campaignFields[i].fieldAPIName;
					if (fieldAPIName == 'StartDate__c' || fieldAPIName == 'EndDate__c' || fieldAPIName == 'Name__c' || fieldAPIName == 'Description__c') {
						fieldAPIName = fieldAPIName.replace('__c', '');
					}
					this.campaignRequiredFields[fieldAPIName] = this.campaignFields[i].isRequired;
					if(this.mode == 'edit'){
						if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes(fieldAPIName)) {
							this.campaignFieldDisabled[fieldAPIName] = false;
						} else {
							this.campaignFieldDisabled[fieldAPIName] = true;
						}
					}else{
						if(fieldAPIName !='Core_MDF_Proposal_Score_nbr__c' ){this.campaignFieldDisabled[fieldAPIName] = false;}
					}if(fieldAPIName != 'Core_MDF_Lead_Quantity_nbr__c' && fieldAPIName != 'Core_MDF_Deployment_Quantity_nbr__c' && fieldAPIName != 'Core_MDF_Other_Quantity_nbr__c'){
						this.campaignFieldVisibility[fieldAPIName] = true;}
					this.campaignFieldLabel[fieldAPIName] = this.campaignFields[i].fieldLabel;
					this.campaignFieldHelpText[fieldAPIName] = this.campaignFields[i].helpText;
					if(this.recordTypeDeveloperName === Core_MDF_IPA_RecordType &&  this.campaignFieldValue['Core_MDF_Proposal_Based_Ind__c'] && fieldAPIName == 'Core_MDF_Reimbursement_Amt__c') {
						this.campaignFieldHelpText[fieldAPIName] = '';	
					}
				}
				if ((this.campaignFieldVisibility.StartDate__c && this.campaignFieldVisibility.EndDate__c && this.campaignFieldVisibility.Name__c) && (this.mode == 'clone' || this.mode == 'edit')) {
					this.showFields = true;}
				if(this.mode != 'edit'){ this.campaignFieldDisabled["Core_MDF_Proposal_Score_nbr__c"] = true;}
				this.campaignFieldVisibility["Core_MDF_Campaign_Scoring_txt__c"] = false;this.oldCampFields = this.campaignFields;
				if(this.mode != 'edit' && this.recordTypeDeveloperName === Core_MDF_IPA_RecordType){
					updateOutcomeFieldVisibility(this.campaignFieldValue["StartDate"], this);
					this.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] ? false : true;
					this.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"] = this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] ? null : this.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"];
					this.showOtherOutcomeTextField();
				}
				 if (this.mode == 'edit' && this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
					if (!this.skipOutcomeFieldUpdate && checkForUndefinedEmptyAndNull(this.campaignFieldValue["StartDate"])) { updateOutcomeFieldVisibility(this.campaignFieldValue["StartDate"], this); }
					this.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = this.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] ? true : (checkForUndefinedEmptyAndNull(this.activityListEdit) && this.activityListEdit.length > 0);
					this.showOtherOutcomeTextField();
				}
				if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.proposalBasedIndicatorCamp) {
					this.showOtherMeasurementApproachVisibility();
				}
			})
	}
	getActivityCloneFields(pickListObject, budgettype, recordType, PropBased, objName) {
		getFieldSets({pickListObj: pickListObject,budType: budgettype,recType: recordType,isPropBased: PropBased,objectName: objName})
			.then((result) => {
				this.activityFields = result;
				this.mandatoryActFieldsError = false;
				if (this.oldActFields !== undefined || this.oldActFields != null) {
					let oldFields = this.oldActFields.values();
					for (const key of oldFields) {
						this.activityRequiredFields[key.fieldAPIName] = false;
					}}
				var isShowError = false;
				for (let i = 0; i < this.activityFields.length; i++) {
					this.activityRequiredFields[this.activityFields[i].fieldAPIName] = this.activityFields[i].isRequired;
				}
				let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]');this.recActList = [];
				for (let i = 0; i < checkboxes.length; i++) {
					if (checkboxes[i].checked == true) { this.recActList.push(checkboxes[i].name); }
				}
				let actListClone = JSON.parse(JSON.stringify(this.activityListClone));
				for (var i = 0; i < actListClone.length; i++) {
					if (this.recActList.includes(actListClone[i].Id)) {
						if (((actListClone[i].Core_MDF_Activity_SubType_nm__c == null || actListClone[i].Core_MDF_Activity_SubType_nm__c == [] || (actListClone[i].Core_MDF_Activity_SubType_nm__c != null && actListClone[i].Core_MDF_Activity_SubType_nm__c != undefined && actListClone[i].Core_MDF_Activity_SubType_nm__c.length == 0)) && this.activityRequiredFields["Core_MDF_Activity_SubType_nm__c"] == true && actListClone[i].activitySubTypeAvailable) || (actListClone[i].Core_MDF_ActivityCategory__c == null && this.activityRequiredFields["Core_MDF_ActivityCategory__c"] == true) || ((actListClone[i].Core_MDF_Activity_Types__c == null && this.activityRequiredFields["Core_MDF_Activity_Types__c"] == true))) {
							isShowError = true;this.mandatoryActFieldsError = true;this.hideGenericError = true;
							break;
						} else { this.mandatoryActFieldsError = false; }
					}
					if (actListClone[i].showKPIErrorClone == true && (actListClone[i].hasOwnProperty('isBlankMetrics') && !actListClone[i].isBlankMetrics)) {
						actListClone[i].showKPIErrorClone = false;
					}

					var proposalCloneOutComeBasedInd = (this.campaignFieldValue.hasOwnProperty('Core_MDF_CampOutcomeOpt_In_Ind__c') && this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]) ? this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] : false;
					if (!proposalCloneOutComeBasedInd || (proposalCloneOutComeBasedInd && actListClone[i].showTacticMetricsErrorClone && (actListClone[i].hasOwnProperty('tacticMetricEdited') && actListClone[i].tacticMetricEdited))) {
						actListClone[i].showTacticMetricsErrorClone = false;
					}
				}
				this.activityListClone = actListClone;
				this.oldActFields = this.activityFields;
			})
	}
	onBudgetSelection(event) {
		let campaignBudgetsArray = [];
		let cmpBudgetsTempMap = new Map();
		let arrayFromChild = [];
		this.arrayFromAvailableBudgets = event.detail.recordId;
		if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
			let data = event.target.value;
			if(this.mode == 'edit') {
				this.selectedCmpBudgets = data;
				this.handlePicklistDependentValueChange(event);
				if(this.budgetReferredOnActivity) {
					data = this.selectedCmpBudgets;
				}
			}
			let availableBudgets = this.availableBudgetValues;let selectedBudgets = [];
			if (data != null) {
				data.forEach(dt => {
					let selBud = availableBudgets.find(avlBdgt => avlBdgt.value === dt);
					if (selBud !== undefined) {
						selectedBudgets.push(selBud);
					}
				});
				arrayFromChild = selectedBudgets;
			}
		} else {
			arrayFromChild = event.detail.recordId;
		}
		if (this.campaignBudgetsForSave !== undefined && this.campaignBudgetsForSave !== null && this.campaignBudgetsForSave !== '') {
			for (let i = 0; i < this.campaignBudgetsForSave.length; i++) {
				cmpBudgetsTempMap.set(this.campaignBudgetsForSave[i].budgetId, this.campaignBudgetsForSave[i]);
			}}
		if (this.mode === 'edit' && this.allCmpBudgetsMap !== null) {
			let selectedBudgets = [];
			this.selectedCmpBudgets = [];
			let rrOptions;
			for (var i in arrayFromChild) {
				if (!selectedBudgets.includes(arrayFromChild[i].value)) {
					selectedBudgets = [selectedBudgets, arrayFromChild[i].value];
					this.selectedCmpBudgets = [...this.selectedCmpBudgets, arrayFromChild[i].value];
				}
				if (this.budgetIdTypeMap.has(arrayFromChild[i].value)) {
					const budgetType = this.budgetIdTypeMap.get(arrayFromChild[i].value);
					if (this.budgetTypeRrOptionMap.has(budgetType)) {
						rrOptions = this.budgetTypeRrOptionMap.get(budgetType);
					}}
				if (this.allCmpBudgetsMap.has(arrayFromChild[i].value)) {
					let res = this.allCmpBudgetsMap.get(arrayFromChild[i].value);
					let budgetNameString = getBudgetNameString(res.Core_MDF_Budget_Name_Id__r.Title,res.Core_MDF_Budget_Type_Nm__c ,res.Core_MDF_Start_Date_Dt__c, res.Core_MDF_End_Date_Dt__c,res.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c);

					let obj;
					if (res.Core_MDF_Active_ind__c) {
						if (this.budgetsOnActiveActivities.includes(res.Core_MDF_Budget_Name_Id__c)) {
							campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(res, true, true, rrOptions, budgetNameString, this.recordTypeDeveloperName)];
						} else {
							campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(res, true, false, rrOptions, budgetNameString, this.recordTypeDeveloperName)];
						}
					} else {
						if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
							obj = { campaignBudgetId: res.Id, isActive: true, budgetId: arrayFromChild[i].value, budgetName: arrayFromChild[i].label, budgetAmount: '0', budgetRR: '0%', budgetRAmount: '0', options: rrOptions };
						}
						else{
						obj = {campaignBudgetId: res.Id,isActive: true,budgetId: arrayFromChild[i].value,budgetName: arrayFromChild[i].label,budgetAmount: '',budgetRR: '50%',budgetRAmount: '',options: rrOptions};
						}
						campaignBudgetsArray = [...campaignBudgetsArray, obj];
					}
				} else {
					if (cmpBudgetsTempMap !== undefined && cmpBudgetsTempMap !== null && cmpBudgetsTempMap.has(arrayFromChild[i].value)) {
						let res = cmpBudgetsTempMap.get(arrayFromChild[i].value);
						campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(false, res, rrOptions,this.recordTypeDeveloperName)];
					} else {
						campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(true, arrayFromChild[i], rrOptions,this.recordTypeDeveloperName)];
					}
				}
			}
		} else {
			this.selectedCmpBudgets = [];
			for (var i in arrayFromChild) {
				let rrOptions;
				this.selectedCmpBudgets = [...this.selectedCmpBudgets, arrayFromChild[i].value];
				if (this.budgetIdTypeMap.has(arrayFromChild[i].value)) {
					const budgetType = this.budgetIdTypeMap.get(arrayFromChild[i].value);
					if (this.budgetTypeRrOptionMap.has(budgetType)) {
						rrOptions = this.budgetTypeRrOptionMap.get(budgetType);
					}
				}
				if (cmpBudgetsTempMap !== undefined && cmpBudgetsTempMap !== null && cmpBudgetsTempMap.has(arrayFromChild[i].value)) {
					let res = cmpBudgetsTempMap.get(arrayFromChild[i].value);
					campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(false, res, rrOptions,this.recordTypeDeveloperName)];
				} else {
					campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(true, arrayFromChild[i], rrOptions,this.recordTypeDeveloperName)];
				}
			}
			if (this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
				this.loadBudgetTypefields = true;
			}
		}
		this.campaignBudgets = campaignBudgetsArray;
		this.campaignBudgetsForSave = this.campaignBudgets;
		if (event.detail.recordId != '' && event.detail.recordId != undefined && event.detail.recordId != null) {
			this.showCampaignBudgets = true;this.availableBudgetSelected = true;
		} else {this.showCampaignBudgets = false;this.availableBudgetSelected = false;
		}
		retainAndUpdateCampaignBudgetsOldMap(this, true, true);
	}
	onCampaignBudgets(event) {
		this.campaignBudgetsForSave = event.detail.budgetData;
		this.cmpBudgetsErrorToRetainMap = new Map(event.detail.cmpBudgetsErrorToRetainMap);
		retainAndUpdateCampaignBudgetsOldMap(this, false, false);
		if(this.cmpBudgetsErrorToRetainMap.size == 0){
			this.isCmpBudgetsValidOnChangeOfFields = true;
		}else{
			this.isCmpBudgetsValidOnChangeOfFields = false;
		}
	}
	async getBudgetsForCampaign(accountid, startdate, enddate, budgettype) {
		this.showAvailableBudgets = false;
		if (accountid !== undefined && accountid !== null && accountid !== '' && startdate !== undefined && startdate !== null && startdate !== '' &&
			enddate !== undefined && enddate !== null && enddate !== '' && budgettype !== undefined && budgettype !== null && budgettype !== '') {
			await getBudgetsForCampaign({ campAccountId: accountid, campStartDate: startdate, campEndDate: enddate, campBudgetType: budgettype })
				.then((result) => {
					if (result) {
					this.isLoaded = true;
					let budgetTypePicValues = [];
					var budgetType = result;
					this.budgetIdTypeMap.clear();
					let cmpBudgetsTempMap = new Map();
					let budgetIdTypeMapTemp = new Map();
					let selectedBudgetIds = [];
					this.selectedCmpBudgets = [];
					let campaignBudgetsArray = [];
					if (this.campaignBudgetsForSave !== undefined && this.campaignBudgetsForSave !== null && this.campaignBudgetsForSave !== '') {
					for (let i = 0; i < this.campaignBudgetsForSave.length; i++) {
					if (this.mode === 'edit') {
					cmpBudgetsTempMap[this.campaignBudgetsForSave[i].budgetId] = this.campaignBudgetsForSave[i];} 
					else {
									cmpBudgetsTempMap.set(this.campaignBudgetsForSave[i].budgetId, this.campaignBudgetsForSave[i]);
								}
					selectedBudgetIds = [...selectedBudgetIds, this.campaignBudgetsForSave[i].budgetId];}
						}
					if (this.mode === 'edit') {
					if (this.budgetsOnActiveActivities !== undefined && this.budgetsOnActiveActivities !== null &&
					this.budgetsOnActiveActivities !== '') {
					for (let i = 0; i < this.budgetsOnActiveActivities.length; i++) {
						if (!selectedBudgetIds.includes(this.budgetsOnActiveActivities[i])) {
						selectedBudgetIds = [...selectedBudgetIds, this.budgetsOnActiveActivities[i]];}}}
						}
						this.selectedAvailableBudgets = selectedBudgetIds;
						for (const key in budgetType) {
						budgetIdTypeMapTemp.set(key, result[key].Core_MDF_Budget_Type_Txt__c);
						let obj;
						if (this.selectedAvailableBudgets.includes(key)) {
						if (this.budgetsOnActiveActivities.includes(key)) {
						obj = {
						label: getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate,result[key].Core_MDF_budget_ref_nbr__c),value: key,selected: true,disable: true,
						};
					} else {
						obj = {
						label: getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate,result[key].Core_MDF_budget_ref_nbr__c),value: key,selected: true,disable: false,
						};}
								this.selectedCmpBudgets = [...this.selectedCmpBudgets, key];
							} else {
								obj = {
									label: getBudgetNameString(result[key].Title, result[key].Core_MDF_Budget_Type_Txt__c, result[key].StartDate, result[key].EndDate, result[key].Core_MDF_budget_ref_nbr__c),
									value: key,
								};
							}
							budgetTypePicValues = [...budgetTypePicValues, obj];
							let rrOptions;
							if (this.budgetTypeRrOptionMap.has(result[key].Core_MDF_Budget_Type_Txt__c)) {
								rrOptions = this.budgetTypeRrOptionMap.get(result[key].Core_MDF_Budget_Type_Txt__c);
							}
							if (this.mode === 'edit' && this.allCmpBudgetsMap !== null) {
								if (this.selectedAvailableBudgets.includes(key) && this.allCmpBudgetsMap.has(key)) {
									let res = this.allCmpBudgetsMap.get(key);
								let budgetNameString = getBudgetNameString(res.Core_MDF_Budget_Name_Id__r.Title,res.Core_MDF_Budget_Type_Nm__c ,res.Core_MDF_Start_Date_Dt__c, res.Core_MDF_End_Date_Dt__c,res.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c);
									// new RR changes
									let finalRROptions = [];
									finalRROptions = addExistingReimbursementRate(res.Core_MDF_Reimbursement_Rate_Pct__c, rrOptions);

									let obj;
									if (res.Core_MDF_Active_ind__c) {
										if (this.budgetsOnActiveActivities.includes(res.Core_MDF_Budget_Name_Id__c)) {
											campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(res, true, true, finalRROptions, budgetNameString, this.recordTypeDeveloperName)];
										} else {
											campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapperMDF(res, true, false, finalRROptions, budgetNameString, this.recordTypeDeveloperName)];
										}
									}
								} else {
									if (this.selectedAvailableBudgets.includes(key)) {
										let res = cmpBudgetsTempMap[key];
										if (res !== undefined && res !== null) {
											campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(false, res, rrOptions, this.recordTypeDeveloperName)];
										}
									}
								}
							} else if (this.mode == 'clone') {
								if (this.selectedCmpBudgets.includes(key)) {
									let res = cmpBudgetsTempMap.get(key);
									if (res !== undefined && res !== null) {
										campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(false, res, rrOptions, this.recordTypeDeveloperName)];
									}
								}
							} else {
								let res = cmpBudgetsTempMap.get(key);
								if (res !== undefined && res !== null) {
									campaignBudgetsArray = [...campaignBudgetsArray, budgetDataWrapper(false, res, rrOptions, this.recordTypeDeveloperName)];
								}
							}
						}
						this.budgetIdTypeMap = budgetIdTypeMapTemp;
						this.availableBudgetValues = budgetTypePicValues;
						if (this.availableBudgetValues.length > 0) {
							let availableBudgetValuesSize = Object.entries(this.availableBudgetValues).length;
							//If only one budget is available, make it a default - EEF
							if (this.recordTypeDeveloperName === Core_MDF_EEF_RecordType || this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType) {
								this.isDefaultBudget = (availableBudgetValuesSize === 1) ? true : false;
								if (availableBudgetValuesSize <= 3) {
									this.picklistSize['availableBudgetValues'] = 3;
								} else {
									this.picklistSize['availableBudgetValues'] = 6;
								}
								if(this.isDefaultBudget){
									this.showAvailableBudgets = true;
									this.singleCampBudget = (this.availableBudgetValues[0].value);
									//Default Single budget selection on Campaign budgets on create screen
									if(this.selectedCmpBudgets == null){
										this.selectedCmpBudgets = [];
										this.selectedCmpBudgets.push(this.availableBudgetValues[0].value);
									}
									this.loadBudgetTypefields = true;
								}
										}
							if(this.mode == 'clone' && this.initalLoad) {
								this.initalLoad = false;
							}
							this.showAvailableBudgets = true;
							this.showAvailableBudgetRequired = true;
							this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
							this.campaignBudgets = campaignBudgetsArray;
							if (this.campaignBudgets !== undefined && this.campaignBudgets !== null && this.campaignBudgets.length > 0) {
								this.showCampaignBudgets = true;
								this.campaignBudgetsForSave = this.campaignBudgets;
							}
						} else {
							this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
							this.showAvailableBudgets = false;
							this.showAvailableBudgetRequired = false;
							this.showCampaignBudgets = false;
						}
					}
					if(!this.isCampaignBudgetsInitiallyLoaded){
						retainAndUpdateCampaignBudgetsOldMap(this, false, false);
						this.isCampaignBudgetsInitiallyLoaded = true;
					} else {
						retainAndUpdateCampaignBudgetsOldMap(this, true, true);
					}
					this.isLoaded = false;
				})
				.catch(e => {
					this.isLoaded = false;
					this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = '';
					this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
					this.scrollUp();
				});
		}
	}
	handleReimbursementRateChange(event) {
		this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = event.target.value;
		this.finalRRrate = event.target.value;
		calReimbursementAmt(this);

	}
		handleTotalCampaignCostChange(event) {
	let totalCmpCost = event.target.value;
		let amtComp;
		amtComp = this.template.querySelector('.Core_MDF_Total_Campaign_Cost_Amt__c');
		if(totalCmpCost<=0){
			amtComp.setCustomValidity(errorMsgForTotalCampCostAmt);
		}
		else{
			amtComp.setCustomValidity('');
		}
		amtComp.reportValidity(); 
		this.campaignFieldValue["Core_MDF_Total_Campaign_Cost_Amt__c"] = totalCmpCost; 
		if(this.recordTypeDeveloperName == Core_MDF_EEF_RecordType){
			this.finalRRrate = '100%'
		}
		calReimbursementAmt(this);
	}
	handleBudgetAmountChangeForRMF(event) { let val = event.target.value; this.campaignFieldValue['Core_MDF_Budget_Amount_amt__c'] = val; let inpCmp = this.template.querySelector('[data-name="' + event.target.name + '"]'); if (val <= 0) { inpCmp.setCustomValidity(negativeInpValErr); } else { inpCmp.setCustomValidity(''); } inpCmp.reportValidity(); }
	@api isFormValid() {
		var isValid = false;
		var allInputValid = false;
		var allComboValid = false;
		var allTextAreaValid = false;
		var allDualListValid = false;
		var allCustomLookupValid = true;
		var availableBudgetSelected = true;
		var campaignBudgetSelected = true;
		var campaignBudgetAmntNotDecreased = true;
		var isEndDateNotChanged = true;
		allInputValid = [...this.template.querySelectorAll('lightning-input')]
			.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true);
		allComboValid = [...this.template.querySelectorAll('lightning-combobox')]
			.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true);
		allTextAreaValid = [...this.template.querySelectorAll('lightning-textarea')]
			.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true);
		allDualListValid = [...this.template.querySelectorAll('lightning-dual-listbox')]
			.reduce((validSoFar, inputCmp) => {
				inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			}, true);
		var lookupComp = this.template.querySelector("c-core_-m-d-f_-custom-lookup");
		if (lookupComp) {
			allCustomLookupValid = lookupComp.isValid();
		}
		if (this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != 'No') {
			var availableBudgets = this.template.querySelector("c-core_-m-d-f_-campaign_-available_-budgets_-picklist");
			if (availableBudgets) {
				availableBudgetSelected = availableBudgets.isValid();
			}
			var campaignBudgets = this.template.querySelector("c-core_-m-d-f_-campaign-budgets");
			if (campaignBudgets) {
				campaignBudgetSelected = campaignBudgets.isValid();
				if (!campaignBudgetSelected) {
					this.noBudgetsWarning = true;
				} else {
					this.noBudgetsWarning = false;
				}
				if (this.mode === 'edit') {
					campaignBudgetAmntNotDecreased = campaignBudgets.isBudgetAmountDecreased();
					if (!campaignBudgetAmntNotDecreased) {
						this.isBudgetAmountDecreased = true;
					} else {
						this.isBudgetAmountDecreased = false;
					}
				}
			}
		}
		if (this.mode === 'edit' && this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true) {
			let oldEndDate = this.campaignRecord['EndDate'];
			let selectedEndDate;
			let inputElements = this.template.querySelectorAll("lightning-input");
			inputElements.forEach((element) => {
				if (element !== null && element.name === 'EndDate') {
					selectedEndDate = element.value;
				}
			});
			if (oldEndDate !== selectedEndDate && (this.status === 'In Progress' || this.status === 'Planned') && this.isClaimsAcssociated && oldEndDate > selectedEndDate) {
				this.error = Core_MDF_Proposal_EndDate_ErrMsg;
				isEndDateNotChanged = false;
				this.hideGenericError = true;
			} else {
				this.error = null;
				isEndDateNotChanged = true;
			}
		}
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType){
			this.focusAreaValid = (checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"]) && this.campaignFieldValue["Core_MDF_Focus_Area_nm__c"].length) > 1 ? false : true;
		}
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.mode == 'clone') {
			this.getActivityCloneFields('Core_MDF_Custom_Picklist__c', this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"], this.recordTypeDeveloperName, this.proposalBasedIndicatorCamp, 'PartnerFundRequest');
		}
		if (allInputValid && this.focusAreaValid && allComboValid && allTextAreaValid && allDualListValid && allCustomLookupValid && availableBudgetSelected && campaignBudgetSelected && (campaignBudgetAmntNotDecreased || this.validateCampaignBudgetsAmount) &&
			!this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] && !this.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] && !this.noAvailablePartnerAccounts &&
			!this.countryError && isEndDateNotChanged && this.isCustomRRValid && !this.multiGeoError && !this.industryError && this.isCmpBudgetsValidOnChangeOfFields) {
			isValid = true;
		}
		if (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType){
			isValid = isValid && (!this.intelOwnerError && !this.memberAcceptorError && !this.intelVerifierError);
		}
		return isValid;
	}
	 handleCSPIntelBasedRevenueChange(event) {
		let cspIntelBasedRevenue = event.target.value;
		let cspRevenue = this.template.querySelector('.Core_MDF_CSP_Intel_Based_Revenue_Amt__c');
		if(cspIntelBasedRevenue<=0){
			cspRevenue.setCustomValidity(errorMsgForTotalCampCostAmt);
		}
		else{
		cspRevenue.setCustomValidity('');
		this.campaignFieldValue["Core_MDF_CSP_Intel_Based_Revenue__c"] = cspIntelBasedRevenue;
		}
		cspRevenue.reportValidity();
	}
	setAttributeValues(element) {
		let eleValue = element.value; let eleName = element.name; let elechecked = element.checked;
		for (let key in this.campaignFieldValue) {
			if (key != null) {
				if (key === (eleName)) {
					this.campaignFieldValue[key] = eleValue;
					if (key == 'Core_MDF_Strategic_Marketing_Fund_Ind__c') {
						this.campaignFieldValue["Core_MDF_Strategic_Marketing_Fund_Ind__c"] = elechecked;
					}
					if (key == 'Core_MDF_Activity_Approval_Required_Ind__c') {
						this.campaignFieldValue["Core_MDF_Activity_Approval_Required_Ind__c"] = elechecked;
					}
					if (key == 'Core_MDF_Primary_Member_Acceptance_Ind__c') {
						this.campaignFieldValue["Core_MDF_Primary_Member_Acceptance_Ind__c"] = true;
					}
					if(key == 'Core_MDF_Priority_2_nm__c' || key == 'Core_MDF_Priority_3_nm__c'){
						resetOrRollbackPriority2Or3(this, 'reset');
					}
					if (key == "Core_MDF_Intel_Owner_id__c"){
						this.campaignFieldValue["Core_MDF_Intel_Owner_id__c"] = this.intelOwnerOptions.toString();
					}
					if (key == "Core_MDF_Member_Acceptor_id__c"){
						this.campaignFieldValue["Core_MDF_Member_Acceptor_id__c"] = this.memberAcceptorOptions.toString();
					}
					if (key == "Core_MDF_Intel_Verifier_id__c"){
						this.campaignFieldValue["Core_MDF_Intel_Verifier_id__c"] = this.intelVerifierOptions.toString();
					}
					if(key == "Core_MDF_CampOutcomeOpt_In_Ind__c"){
						this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = elechecked;
					}
					if (key == 'Core_MDF_IPA_Co_Engineering_Campaign_ind__c') {
						this.campaignFieldValue["Core_MDF_IPA_Co_Engineering_Campaign_ind__c"] = elechecked;
					}
				}
			}
		}
	}
	getCampaignFieldsValues() {
		try {
			let comboElements = this.template.querySelectorAll("lightning-combobox");
			comboElements.forEach(element => {if (element != null) {this.setAttributeValues(element);}
			});
			let inputElements = this.template.querySelectorAll("lightning-input");
			inputElements.forEach(element => {if (element != null) {this.setAttributeValues(element);}
			});
			let txtAreaElements = this.template.querySelectorAll("lightning-textarea");
			txtAreaElements.forEach(element => {if (element != null) {this.setAttributeValues(element);}
			});
			let dualListElements = this.template.querySelectorAll("lightning-dual-listbox");dualListElements.forEach(element => {if (element != null) {this.setAttributeValues(element);}
			});
			if (this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance") {
				this.campaignFieldValue["Core_MDF_Budget_Type_txt__c"] = this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"];
				if(this.mode == 'edit' && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true) {
					this.campAmountFields = {
						totalCampaignCost: this.campaignFieldValue['Core_MDF_Total_Campaign_Cost_Amt__c'],
						reimbursementAmount: this.campaignFieldValue['Core_MDF_Reimbursement_Amt__c'],
					}
				}
			}
			if (this.mode != undefined && this.mode != null && this.mode != '' && this.mode == 'edit' && this.selectedAccount != undefined && this.selectedAccount != null && this.selectedAccount.Id != null) {
				this.campaignFieldValue["Core_MDF_Account__c"] = this.selectedAccount.Id;
			}
			if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && (checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && (this.mode == 'edit' || this.mode == 'clone') && this.finalRRrate != undefined && this.finalRRrate != null && this.finalRRrate != "") {
				this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = this.finalRRrate;
			}
	  		if(this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_EEF_Program_Name){
				this.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '100%';
				let selActPartners = JSON.parse(JSON.stringify(this.campaignFieldValue['Core_MDF_Partner_Mapping_Txt__c']));
				this.selectedActPartners = selActPartners.join(';');
			}
			if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"])) {
				this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"] = this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"].endsWith(';') 
					? this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"].slice(0, -1).trim() 
					: this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"];
			}
		} catch (error) {
			this.error = true;
		}
		return this.campaignFieldValue;
	}
	async customSave() {
		if ((this.isDateChanged) && (this.recordTypeDeveloperName == this.ccfRecordType || this.recordTypeDeveloperName == this.dcfRecordType || this.recordTypeDeveloperName == Core_MDF_EEF_RecordType || this.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType)) {
			let accountIdForBudget = checkForUndefinedEmptyAndNull(this.virtualCorpAccId) ? this.virtualCorpAccId : this.campaignFieldValue["Core_MDF_Account__c"];
			await this.getBudgetsForCampaign(accountIdForBudget, this.campaignFieldValue["StartDate"], this.campaignFieldValue["EndDate"], this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"]);
		}
		this.error = null;
		if(this.mode !='Edit'){
			this.campaignFieldValue["Core_MDF_Terminal_Rejection_Ind__c"] = false;
		}
		if (this.mode === 'clone' && this.activityListClone.length > 0) {this.savePFRClonecampaign = true;if (this.pfrListPrepare()) {this.savePFRClonecampaign = false;}
		}
		this.btnDisabled['saveBtn'] = true;this.btnDisabled['cancelBtn'] = true;this.isLoaded = true;
		let ecoSystemPartnerValues = this.campaignFieldValue["Core_MDF_Ecosystem_Partner_Nm__c"];
		if (ecoSystemPartnerValues != undefined && ecoSystemPartnerValues != null && ecoSystemPartnerValues != "" && ecoSystemPartnerValues.length > 0) {
			if(!ecoSystemPartnerValues.includes('Other')) {
				this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] = "";}}
		if((this.mode !== 'edit') && this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == false) {
			let accBasedFieldsToBeBlanked = campaignAccBasedBlank.split(',');
			 accBasedFieldsToBeBlanked.forEach(field => {
				this.campaignFieldValue[field] = "";
			});
		}
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) {
			if (this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && (this.mode === 'clone')) {
				this.campaignFieldValue = validatePicklistvalues(this.campaignPicValues, this.campaignFieldValue, this.campaignFields, this);
				this.pfrListCloneInsert.forEach(act => {
					act.Core_MDF_IsCloned_Ind__c = true;
									act.Core_MDF_Metrics_txt__c = '' ;
					if(this.activityTypeToClassificationMap.has(act.Core_MDF_Activity_Types__c)){
						act.Core_MDF_Activity_Classification_nm__c = this.activityTypeToClassificationMap.get(act.Core_MDF_Activity_Types__c)
					};
			if (this.isCommunity == true) {
						act.Core_MDF_Opportunity_id__c = act.Core_MDF_Opportunity_id__c!=''?'':act.Core_MDF_Opportunity_id__c;
					}
				});
			}
			if (this.mode === 'clone') {
				this.validateIPAStartDateError();
			}
		}
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone' && this.isAnyPicklistValueChanged) {
			this.pfrListCloneInsert.forEach(act => {
				let changedPicklistArray = this.campPickListValuesChangedObj;
				if (changedPicklistArray.length > 0) {
					changedPicklistArray.map(pickList => {
					let availablePickListValues = [];
					let finalPickListValues = [];
					availablePickListValues = act[pickList.activityFieldAPIName]?.split(';');
					if (checkForUndefinedEmptyAndNull(availablePickListValues) && availablePickListValues.length > 0) {
					finalPickListValues = availablePickListValues.filter(val => pickList.picklistValuesOnCampaign.includes(val))
					act[pickList.activityFieldAPIName] = finalPickListValues.join(';');}});}});}
		if((this.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_CCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_DCF_Program_Name) && this.campaignSource === 'Target Setting'){
			this.priorityPecAbove100 = false;
			let totalOfPriorityPct = 0;
			if(this.priorityPer1){
				totalOfPriorityPct += this.priorityPer1;
			}
			if(this.priorityPer2){
				totalOfPriorityPct += this.priorityPer2;
			}
			if(this.priorityPer3){
				totalOfPriorityPct += this.priorityPer3;
			}
			if(100<totalOfPriorityPct){
				this.priorityPecAbove100 = true;
			}
		}
		if(this.validOutcomeMetricRecordTypeWithOutIPA.includes(this.recordTypeDeveloperName) && this.isDateChanged){
			this.validateActivityCategory();
		}
		if (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType){
			this.contractLineItemsListToSave = this.contractLineItemsList.filter(item => (item.type === 'new' && checkForUndefinedEmptyAndNull(item.value)) || item.isUpdated);
			let contractLineItems = JSON.parse(JSON.stringify(this.contractLineItemsListToSave));
			let contractLineItemsCopy = this.contractLineItemsOnLoad;
			if (checkForUndefinedEmptyAndNull(contractLineItems) && contractLineItems.length > 0 && checkForUndefinedEmptyAndNull(contractLineItemsCopy) && contractLineItemsCopy.length > 0) {
				contractLineItems.forEach(lineItem => {
					let index = contractLineItemsCopy.findIndex(exisitngLineItem => (lineItem.type == 'existing' && lineItem.Id == exisitngLineItem.Id));
					if(index != -1) {
						lineItem.isUpdated = (contractLineItemsCopy[index].value != lineItem.value) ? true : false;
					}
				});
			}

			this.contractLineItemsListToSave = [...contractLineItems];
			contractLineItems.map(cli => {
				let index = this.contractLineItemsListToSave.findIndex(lineIt => (lineIt.type == 'existing' && lineIt.isUpdated == false && lineIt.Id == cli.Id))
				if(index != -1) {
					this.contractLineItemsListToSave.splice(index, 1)
				}
			});
			

			if(this.mode == 'edit' && (this.status == 'Planned' || this.status == 'In Progress')) {
				this.campaignFieldValue['Core_MDF_ContractLineItem_Update_Ind__c'] = (checkForUndefinedEmptyAndNull(this.contractLineItemsListToSave) && this.contractLineItemsListToSave.length > 0) ? true : false;
			}
			//Added by VB
			if(checkForUndefinedEmptyAndNull(this.campaignBudgetsForSave) && this.campaignBudgetsForSave.length > 0) {
				let budgetIds = [];
				this.campaignBudgetsForSave.forEach(campBud => {
					budgetIds.push(campBud.budgetId);
				});
				this.campaignFieldValue['Core_MDF_Campaign_Budgets_Id__c'] = budgetIds.join(';');
				//Added by Alekhya for budget date issue fix
				if (this.mode === 'edit' && checkForUndefinedEmptyAndNull(this.activityListEdit) && this.activityListEdit.length > 0) {

					let pfrList = JSON.parse(JSON.stringify(this.activityListEdit));
					if (pfrList !== undefined && pfrList !== null) {
						for (let i = 0; i < pfrList.length; i++) {

							if (pfrList[i].Budget['StartDate'] > this.campaignFieldValue['StartDate'] || pfrList[i].Budget['EndDate'] < this.campaignFieldValue['StartDate']) {

								this.isStartDateValid = false;
							}
							else {
								this.isStartDateValid = true;
							}
						}
					}
				}
			}
		}
		//TWC3117-17805 Aditya
		this.validateCCFDCFStartDateError();
		let outcomeWrapperList = [];
		if (this.validOutcomeMetricProgram.includes(this.campaignFieldValue["Core_MDF_Program__c"])) {
			if(this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]){
				let outcomeDetailsEdited = false;
				if (this.recordId && this.mode === 'edit') {
					for (const row of this.rows) {
						const original = row;
						const edited = this.editedOutcomeData[row.outcome];
						if (!edited) {
							outcomeDetailsEdited = true; break;
						}
						const fieldsToCompare = ['baselineQuantity', 'goalQuantity', 'outcomeCriteria', 'baselinePeriod'];
						for (const field of fieldsToCompare) {
							const originalVal = original[field] ?? '';
							const editedVal = edited[field] ?? '';
							if (String(originalVal) !== String(editedVal)) {
								outcomeDetailsEdited = true; break;
							}
						}
						if (outcomeDetailsEdited) break;
					}
					// Check if any new outcomes were added
					const originalOutcomes = this.rows.map(r => r.outcome).sort();
					const currentOutcomes = Object.keys(this.editedOutcomeData).sort();
					if (JSON.stringify(originalOutcomes) !== JSON.stringify(currentOutcomes)) {
						outcomeDetailsEdited = true;
					}
				}
				// Set the outcome edited flag accordingly
				this.campaignFieldValue["Core_MDF_Outcome_Detail_Edited_Ind__c"] = outcomeDetailsEdited;
			}	
			if ( !this.editedOutcomeData) {
				this.isOutcomeValid = false; this.outcomeErrorMessages.push(emptyFieldError);
			}else if (this.validOutcomeMetricRecordType.includes(this.recordTypeDeveloperName) && this.outcomeBasedError ) { 
					this.isOutcomeValid = false;
					this.outcomeErrorMessages.push(emptyFieldError);
			} //Ealaya TWC3117-14432 Activity category changes
			else if ((this.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName || this.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName) && this.activityCategoryBasedError) {
					this.isvalidActCatType = false;
			}
			else if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.showIPAStartDateError === true) {
					this.isOutcomeValid = false;
					this.outcomeErrorMessages.push(emptyFieldError);
			}
			else if ( this.editedOutcomeData && Object.keys(this.editedOutcomeData).length > 1) {
				this.isOutcomeValid = false; this.outcomeErrorMessages.push(Core_MDF_Campaign_Outcome_Validation);
			} else if ( this.editedOutcomeData && Object.keys(this.editedOutcomeData).length > 0) {
				const tableCmp = this.template.querySelector('c-core_-m-d-f_-custom-data-table');
				if (tableCmp) {
					const validationResult = tableCmp.validate();
					this.isOutcomeValid = validationResult.isValid;
					if (!this.isOutcomeValid && !this.outcomeErrorMessages.includes(emptyFieldError) ) { this.outcomeErrorMessages.push(emptyFieldError); }
				}
				if (this.isOutcomeValid) {
					const statementMap = new Map(this.outcomeStatements.map(stmt => [stmt.id, stmt.text]));
					outcomeWrapperList = Object.values(this.editedOutcomeData).map(row => {
						const { outcome, baselineQuantity, goalQuantity, quantity, outcomeCriteria, baselinePeriod } = row;
						const campaignPurposeDescription = statementMap.get(row.id || row.outcome) || '';
						return { outcome, baselineQuantity, goalQuantity, quantity, outcomeCriteria, baselinePeriod, campaignPurposeDescription };
					});
				}
			}

		}
		if (this.isFormValid() && !this.priorityPecAbove100 && this.savePFRClonecampaign && !this.mandatoryActFieldsError && !this.multipleValuesSelected && this.isOutcomeValid && this.isStartDateValid && !this.isPastDatedCampaign && this.isvalidActCatType && this.isCCFDCFStartDateValid) {
			if (this.mode !== undefined && this.mode !== null && this.mode !== '' && this.mode === 'edit' && this.selectedAvailableBudgetsMap !== undefined && this.selectedAvailableBudgetsMap !== null && this.selectedAvailableBudgetsMap !== '') {
				if (this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] == 'Yes') {
					this.selectedCmpBudgets = [];}
				for (let budgetId of this.selectedAvailableBudgetsMap.keys()) {
					let selectedCmpBudgetsStr = this.selectedCmpBudgets.toString();
					if (!selectedCmpBudgetsStr.includes(budgetId)) {
						let res = this.allCmpBudgetsMap.get(budgetId);
						var isDuplicate = false;
						let budgetNameString = getBudgetNameString(res.Core_MDF_Budget_Name_Id__r.Title,res.Core_MDF_Budget_Type_Nm__c ,res.Core_MDF_Start_Date_Dt__c, res.Core_MDF_End_Date_Dt__c,res.Core_MDF_Budget_Name_Id__r.Core_MDF_budget_ref_nbr__c);
						let obj = {campaignBudgetId: res.Id,budgetId: res.Core_MDF_Budget_Name_Id__c,isActive: false,budgetName: budgetNameString,budgetAmount: res.Core_MDF_Budget_Amt__c,budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,budgetRAmount: res.Core_MDF_Reimbursement_Amt__c};
						this.campaignBudgetsForSave.forEach(element => {
							if (element.campaignBudgetId == obj.campaignBudgetId) { element.isActive = obj.isActive; isDuplicate = true; }
						});
						if (!isDuplicate) { this.campaignBudgetsForSave.push(obj); }
						if(!this.selectedCmpBudgets.includes(res.Id)) {
							this.campaignBudgets = this.campaignBudgets.filter(budgetItem => budgetItem.campaignBudgetId !== res.Id);
						}
					}
				}
			}
			if (this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] == 'Yes') {this.campaignBudgetsForSave = [];}
			saveCampaign({ 
				campaignObj: this.getCampaignFieldsValues(), 
				campaignBudgets: this.campaignBudgetsForSave, 
				pfrList: this.pfrListCloneInsert, 
				campAmountFields: JSON.stringify(this.campAmountFields), 
				selectedBudgets: this.selectedCmpBudgets, 
				selectedActPartners: this.selectedActPartners, 
				contractLineItemRecordsToSave: this.contractLineItemsListToSave, 
				outcomeWrapperList: outcomeWrapperList,
				activityToActivityAttrWrapperList : this.activityToAttributeList,
				hasTacticMetrics : this.campaignFieldValue.hasOwnProperty('Core_MDF_CampOutcomeOpt_In_Ind__c') ? this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] : false})
				.then(result => {
					this.isLoaded = false;
					if (result != null && !result.startsWith('Exception')) {
						this.navigateToRecordDetailPage(this.objectApiName, result);
						this.error = undefined;this.isLoaded = false;
						if (this.mode == 'edit') {setTimeout(function () {window.location.reload();}, 500);}
					} else if (result != null && result.startsWith('Exception')) {
						this.handleServerExceptions(result);this.isLoaded = false;this.btnDisabled["saveBtn"] = false;this.btnDisabled["cancelBtn"] = false;this.scrollUp();}
				}).catch(e => {
						if (e) {var errorMessage = e.body.message;
							if(errorMessage != null && errorMessage != undefined && errorMessage.includes(this.inValidOppError)){
								this.activityListClone = validateOpportunityId(errorMessage,this.activityListClone);
							}else{
							if(checkForUndefinedEmptyAndNull(e.body.message)){
								this.validateCampaignBudgetsAmount = (e.body.message).includes('Campaign Spending Limit (USD) entered should be Greater than or equal to') ? true : false;
							}							
							this.handleServerExceptions(e.body.message);
						}
						this.isLoaded = false;this.btnDisabled["saveBtn"] = false;this.btnDisabled["cancelBtn"] = false; resetOrRollbackPriority2Or3(this, 'rollback'); this.scrollUp();
					}
				})
		} else {
			if (!this.isStartDateValid) {
				this.showErrorToast(campStartDtBudgetStartDtValErrMessage, 'pester');
			}
			if (this.isPastDatedCampaign) {
				this.showErrorToast(coGTMCampaignStartDateValidation);
				this.hideGenericError = true
			}
			if (this.priorityPecAbove100) {
				this.showErrorToast('Total sum of Priority Weightages cannot be greater than 100%', 'pester');
			}else if (!this.focusAreaValid) {
				this.showErrorToast(singleFocusAreaSelectionTextMessage, 'pester');
			}else if (!this.isOutcomeValid) {
				console.log('isOutcomeValidationerror', this.outcomeErrorMessages);
				this.showErrorToast(this.outcomeErrorMessages.join('\n'), 'pester');
				this.outcomeErrorMessages = [];
			}else if(!this.isValid && !this.hideGenericError) {
				this.showErrorToast(emptyFieldError, 'pester');
			}
			if (!this.isvalidActCatType) {
				this.showErrorToast(emptyFieldError, 'pester');			
			}			
			if (this.mandatoryActFieldsError) {
				this.showErrorToast(Core_MDF_MandatoryFieldsCheckOnProposal, 'pester');
			}
			if (!this.isCCFDCFStartDateValid) {
				this.showErrorToast(emptyFieldError, 'pester');
			}
			this.isLoaded = false;this.btnDisabled["saveBtn"] = false;this.btnDisabled["cancelBtn"] = false;this.scrollUp();
		}
	}
	showErrorToast(errorMessage, mode) {
		const evt = new ShowToastEvent({ title: 'Error!', message: errorMessage, variant: 'error', mode: mode });this.dispatchEvent(evt);
	}
	scrollUp() {
		const scrollOptions = { left: 0, top: 0, behavior: 'smooth' };
		const bodyDiv = this.template.querySelector('[class=body]');
		if (bodyDiv) {bodyDiv.scrollTop = 0;
		} else {window.scrollTo(scrollOptions);}
	}
	async handleSelectedAccount(event) {
		this.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
		var selectedAccount = (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) ? (event.detail ? event.detail["Id"] : event.detail) : event.detail;
		this.virtualCorpAccId = (this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) ? (event.detail ? event.detail["Core_MDF_Virtual_Corp_Account_Id__c"] : '') : '';
		this.program = this.program == undefined ? this.campaignFieldValue["Core_MDF_Program__c"] : this.program;
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
			//let virtualCorpId;  // Roshan - Commented as part of TWC3117-18965
			if ((this.mode == 'edit' || this.mode == 'clone') && event.detail == undefined) {
				selectedAccount = event;
				//virtualCorpId = this.selectedAccount?.virtualCorpAcc || this.selectedAccount?.Id;  // Roshan - Commented as part of TWC3117-18965
			} else { 
				selectedAccount = event.detail?.Id || event.detail; 
				//virtualCorpId = event.detail?.virtualCorpId || event.detail?.Id || event.detail;  // Roshan - Commented as part of TWC3117-18965
			}		
			if (selectedAccount == null || (selectedAccount != null && selectedAccount.length != 18))
				this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] = null;this.loadBudgetTypefields = false;this.dynamicload = false;
			// Roshan - Commented as part of TWC3117-18965
			//this.availableDomains = [];	
			//this.domainsLoaded = false;
			this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"] = '';
			//this.fetchDomainsForAccount(virtualCorpId);  // Roshan - Commented as part of TWC3117-18965
			await getBudgetType({accId: selectedAccount,operation: this.mode,isProposalBased: this.isProposalCampaign,program: this.program})
				.then((result) => {
					var budgetTypes = result;var budgetTypePicValues = [];
					if (budgetTypes != undefined && budgetTypes != null) {
						for (const key in budgetTypes) {const obj = {label: budgetTypes[key],value: key,};budgetTypePicValues = [...budgetTypePicValues, obj];}
					}
					this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = budgetTypePicValues;
					this.budgetOptions = budgetTypePicValues;
				})
				.catch(e => { });
		} else if(this.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType){
			this.intelOwnerError = false;
			this.memberAcceptorError = false;
			this.intelVerifierError = false;
			this.intelOwnerOptions = [];
			this.memberAcceptorOptions = [];
			this.intelVerifierOptions = [];
			this.campaignFieldValue['Core_MDF_Intel_Verifier_id__c'] = [];
			this.campaignFieldValue['Core_MDF_Member_Acceptor_id__c'] = [];
			this.campaignFieldValue['Core_MDF_Intel_Owner_id__c'] = [];
			this.campaignPicValues['Core_MDF_Intel_Verifier_id__c'] = [];
			this.campaignPicValues['Core_MDF_Member_Acceptor_id__c'] = [];
			this.campaignPicValues['Core_MDF_Intel_Owner_id__c'] = [];
			let selectedAccParentFundAccId;
			let coGTMProgramId;	
			if((this.mode == 'edit' || this.mode == 'clone') && event.detail == undefined) {
				this.virtualCorpAccId = event['virtualCorpAcc'];
				this.selectedAccountId = event['Id'];
				selectedAccParentFundAccId = event['ultimateAcc'];
				coGTMProgramId = event['programId'];
			} else {
				this.selectedAccountId = event.detail ? event.detail["Id"] : event.detail;
				selectedAccParentFundAccId = event.detail ? event.detail["Core_MDF_CoMarketing_Ultimate_Account__c"] : event.detail;
				coGTMProgramId = event.detail ? event.detail["Core_MDF_Channel_Program__c"] : event.detail;
			}
			await getInternalAndExternalUsersByAccount({
				selectedAccountId: this.selectedAccountId, selectedAccParentFundAccId: selectedAccParentFundAccId,
				coGtmChannelProgramId: coGTMProgramId
			}).then(result => {
				if (result) {
					const keys = ['Core_MDF_Intel_Owner_id__c', 'Core_MDF_Member_Acceptor_id__c', 'Core_MDF_Intel_Verifier_id__c'];
					keys.forEach((key) => {
						const wrapper = result[key];
	
						// If data exists for that field, assign it to internalAndExternalUsersMap
						if (wrapper) {
							const userDetails = {
								defaultOptions: wrapper.defaultOptions,
								options: wrapper.options
							};
							
							if (key === 'Core_MDF_Intel_Owner_id__c') {
								this.intelOwnerOptions = (this.mode == 'edit' || this.mode == 'clone') ? this.campaignRecord['Core_MDF_Intel_Owner_id__c'].split(';') : wrapper.defaultOptions;
							}
							else if(key === 'Core_MDF_Member_Acceptor_id__c'){
								this.memberAcceptorOptions = (this.mode == 'edit' || this.mode == 'clone') ? this.campaignRecord['Core_MDF_Member_Acceptor_id__c'].split(';') : wrapper.defaultOptions;
							}
							
							else if (key === 'Core_MDF_Intel_Verifier_id__c') {
								this.intelVerifierOptions = (this.mode == 'edit' || this.mode == 'clone') ? this.campaignRecord['Core_MDF_Intel_Verifier_id__c'].split(';') : wrapper.defaultOptions;
							}
							this.internalAndExternalUsersMap.set(key, userDetails);
						} else {
							// If no data exists, assign an empty block (object)
							this.internalAndExternalUsersMap.set(key, {
								defaultOptions: [],
								options: []
							});
						}
					});				
					this.campaignPicValues['Core_MDF_Intel_Verifier_id__c'] = this.internalAndExternalUsersMap.get('Core_MDF_Intel_Verifier_id__c')['options'];
					this.campaignPicValues['Core_MDF_Member_Acceptor_id__c'] = this.internalAndExternalUsersMap.get('Core_MDF_Member_Acceptor_id__c')['options'];
					this.campaignPicValues['Core_MDF_Intel_Owner_id__c'] = this.internalAndExternalUsersMap.get('Core_MDF_Intel_Owner_id__c')['options'];
				}
			}).catch(error => {
				console.log(error);
				this.showErrorToast('Error fetching users', error, 'pester');
			})
		}
		this.campaignFieldDisabled['Core_MDF_Opal_Budget_Type_Txt__c'] = false;
		this.campaignFieldValue['Core_MDF_Account__c'] = selectedAccount;
		if((selectedAccount != null && selectedAccount != undefined) && this.recordTypeDeveloperName == Core_MDF_EEF_RecordType){
				this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] = 'MDF or both CMP & MDF';
				this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
				getSIOrISVAccounts(selectedAccount, this);
			}
		if (
			(selectedAccount != null && selectedAccount != undefined) &&
			(this.campaignFieldValue['StartDate'] !== undefined && this.campaignFieldValue['StartDate'] != null && this.campaignFieldValue['StartDate'] !== '') &&
			(this.campaignFieldValue['EndDate'] !== '' && this.campaignFieldValue['EndDate'] !== undefined && this.campaignFieldValue['EndDate'] != null) &&
			(this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] !== '' && this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] != undefined && this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'] != null) &&
			(this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_CCF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_DCF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_EEF_Program_Name || this.campaignFieldValue['Core_MDF_Program__c'] == Core_MDF_Co_GTM_Technical_program_name) &&
			(this.budgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] == false)) {
			this.resetBudgetRelatedFlags();
			if (this.campaignFieldValue["Core_MDF_Supports_legacy_program__c"] != 'Yes') {
				let accountIdForBudget = checkForUndefinedEmptyAndNull(this.virtualCorpAccId) ? this.virtualCorpAccId : this.campaignFieldValue["Core_MDF_Account__c"];
				this.getBudgetsForCampaign(accountIdForBudget, this.campaignFieldValue["StartDate"], this.campaignFieldValue["EndDate"], this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"]);
			}
		}
		if ((selectedAccount != undefined && selectedAccount != null && selectedAccount != '') &&
			(this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.mode != 'edit')) {
			this.isLoaded = true;this.campaignFieldValue["Core_MDF_Account__c"] = selectedAccount;this.getAccountSpecificBudgetTypes(String(selectedAccount));
		} else {
			this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
			if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name) {this.campaignFieldDisabled['Core_MDF_Opal_Budget_Type_Txt__c'] = true;}
		}
	}
	// Roshan - Commented as part of TWC3117-18965
	/*fetchDomainsForAccount(accountId) {
		if (!accountId) { this.availableDomains = [];  this.domainsLoaded = false; return; }

		getDomainsForAccount({ accountId: accountId })
			.then(result => {
				this.availableDomains = result || [];
				this.domainsLoaded = true;
			})
			.catch(error => {
				this.error = error;
				this.availableDomains = [];
				this.domainsLoaded = false;
			});
	}*/
	handlePartnerContactChange(event) {
		const emailString = event.target.value?.trim();
		const inputField = event.target; 
		this.campaignFieldValue["Core_MDF_Partner_Contact_txt__c"] = emailString;
		
		if (!emailString) {
			inputField.setCustomValidity('');
			inputField.reportValidity();
			return;
		}
		// Roshan - Validate email format only.
		inputField.setCustomValidity(this.validateEmails(emailString));
		inputField.reportValidity();
		
		// Roshan - Commented as part of TWC3117-18965
		/*if (this.domainsLoaded) {
			const approvedDomains = this.availableDomains
				.map(d => d.Name.toLowerCase().trim());

			if (approvedDomains.length === 0) {
				inputField.setCustomValidity(Core_MDF_No_Approved_Domains_Error);
			} else {
				inputField.setCustomValidity(
					this.validateEmails(emailString, approvedDomains)
				);
			}
			inputField.reportValidity();
			return;
		}
		const virtualCorpId = this.selectedAccount.virtualCorpAcc ? this.selectedAccount.virtualCorpAcc: this.selectedAccount.Id;
		if (!virtualCorpId) {
			return;
		}

		getDomainsForAccount({ accountId: virtualCorpId })
			.then(result => {
				this.availableDomains = result || [];
				this.domainsLoaded = true;

				const approvedDomains = this.availableDomains
					.map(d => d.Name.toLowerCase().trim());

				if (approvedDomains.length === 0) {
					inputField.setCustomValidity(Core_MDF_No_Approved_Domains_Error);
				} else {
					inputField.setCustomValidity(
						this.validateEmails(emailString, approvedDomains)
					);
				}
				inputField.reportValidity();
			})
			.catch(error => {
				this.error = error;
				inputField.setCustomValidity('');
				inputField.reportValidity();
			});
		*/
	}
	validateEmails(emailString, approvedDomains) {
		const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

		// Roshan - Commented as part of TWC3117-18965
		//if (approvedDomains.length === 0)
        	//return '';
		
		if (/;;|^;/.test(emailString)) {
        	return Core_MDF_InvalidEmailError;
    	}
		for (let email of emailString.split(';').map(e => e.trim()).filter(Boolean)) {
			
			// Validate email format
			if (!emailRegex.test(email)) 
				return Core_MDF_InvalidEmailError;

			// Roshan - Commented as part of TWC3117-18965
			/*const domain = email.split('@')[1].toLowerCase();

			if (domain === 'intel.com')
				return Core_MDF_IntelDomainError;

			if (!approvedDomains.includes(domain))
				return `${Core_MDF_UnsupportedDomain_Error} ${approvedDomains.join(', ')}`;
			*/
		}
		return '';
	}
	getAccountSpecificBudgetTypes(selectedAccount) {
		getAccSpecificBudgetTypes({accountId: String(selectedAccount),program: this.campaignFieldValue["Core_MDF_Program__c"]})
			.then(result => {
				if (result) {
					var budgetTypes = [];budgetTypes = result['accIdBudgetTypeMap'][selectedAccount];var budgetTypePicValues = [];
					if (budgetTypes != undefined && budgetTypes != null && budgetTypes != '') {
						for (const key in budgetTypes) {
							const obj = {label: budgetTypes[key],value: key,};budgetTypePicValues = [...budgetTypePicValues, obj];
						}
					}
					this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = budgetTypePicValues;
					this.budgetOptions = budgetTypePicValues;
					if (this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {
						if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes("Core_MDF_Opal_Budget_Type_Txt__c")) {
							this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
						} else {
							this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
						}
					} else {
						this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
					}
					if (this.isCommunity == true && this.recordId != undefined && this.recordId != null && this.recordId != '' && this.mode == 'edit') {

						if (this.fieldEditibilityList != null && this.fieldEditibilityList.includes("Core_MDF_Opal_Budget_Type_Txt__c")) {

							this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
						} else {
							this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
						}
					}
				}
				if (!this.initalLoad) this.isLoaded = false;
			})
			.catch(e => {
				this.isLoaded = false; this.campaignPicValues["Core_MDF_Opal_Budget_Type_Txt__c"] = ''; this.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true; this.scrollUp();
			})
	}
	resetBudgetRelatedFlags() {
		this.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
		this.showAvailableBudgets = false;this.showAvailableBudgetRequired = false;this.showCampaignBudgets = false;this.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
	}
	searchCountry(event) {
		var countrySearch = event.target.value; countrySearch = countrySearch.toUpperCase();
		let countryName = [...this.campaignPicValues.Core_MDF_Market__c]; var filterCountrySearch = []; var filterCountryNonSearch = [];
		countryName.sort((a, b) => a.label.localeCompare(b.label));
		for (var index = 0; index < countryName.length; index++) {
			if (countryName[index].value.toUpperCase().includes(countrySearch)) {
				filterCountrySearch.push(countryName[index]);
			} else {
				filterCountryNonSearch.push(countryName[index]);
			}
		}
		this.campaignPicValues.Core_MDF_Market__c = filterCountrySearch.concat(filterCountryNonSearch);
	}
	selectedCountry(event) {
		this.isCountryChanged = true; this.countryValue = event.target.value; this.tempCountrySelected = this.countryValue;
		this.program = this.program == undefined ? this.campaignFieldValue["Core_MDF_Program__c"] : this.program;
		this.countryError = this.countryValue.length > 100 ? true : false;
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_DCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_CCF_Program_Name || this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_EEF_Program_Name) {
			this.handlePicklistDependentValueChange(event);
		}
	}
	othersMandate(fieldApiName, fieldValue) {		
		if (fieldValue != null && fieldValue != undefined && fieldValue != '' && fieldValue.includes('Other') && !this.campaignFieldDisabled[fieldApiName]){
			this.othersHelpText[fieldApiName] = true;}
		else{this.othersHelpText[fieldApiName] = false;}
		if (fieldApiName == 'Core_MDF_Ecosystem_Partner_Nm__c') {
			if(this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] != '' && this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] != undefined){
				this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] = this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"].length>0 ? this.campaignFieldValue["Core_MDF_Other_Ecosystem_Partner_txt__c"] : '';
			}
			if (this.othersHelpText['Core_MDF_Ecosystem_Partner_Nm__c']){this.campaignRequiredFields["Core_MDF_Other_Ecosystem_Partner_txt__c"] = true;}
			else{this.campaignRequiredFields["Core_MDF_Other_Ecosystem_Partner_txt__c"] = false;}
		}
	}
	
	naValidate(fieldApiName, fieldValue) {
		if (fieldValue != null && fieldValue != undefined && fieldValue != '' && fieldValue.includes('NA') && fieldValue.length > 1) {
			if (fieldApiName === 'Core_MDF_Industry_Nm__c') {this.naHelpText["Core_MDF_Industry_Nm__c"] = true;this.industryError = true;}
		} else {this.naHelpText["Core_MDF_Industry_Nm__c"] = false;this.industryError = false;}
	}
	handleCancel() {
		if (this.mode == 'edit' || this.mode == 'clone') {
			this.navigateToRecordDetailPage(this.objectApiName, this.recordId);
			if (this.mode == 'edit') {setTimeout(function () {window.location.reload();}, 500);
			} else if (this.mode == 'clone') {eval("$A.get('e.force:refreshView').fire();");}
		} else {
			this.navigateToObjectPage(this.objectApiName);setTimeout(function () {window.location.reload();}, 500);
		}
	}
	navigateToRecordDetailPage(objectName, recordId) {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordPage',attributes: {recordId: recordId,objectApiName: objectName,actionName: 'view'}});
		if (this.mode === 'edit') {setTimeout(function () {window.location.reload();}, 1000);}}
	navigateToObjectPage(objectName) {
		this[NavigationMixin.Navigate]({type: 'standard__objectPage',attributes: {objectApiName: objectName,actionName: 'list'},state: {filterName: 'Recent'},});}
	handleServerExceptions(error) {
		this.error = handleServerExceptionsName(error, this.label.applicationErrorMsg);let doc = this.template.querySelector(".slds-card");doc.scrollTop = 0;}
	handleBudgetError() {
		if (this.isBudgetAmountDecreased === true) {this.isBudgetAmountDecreased = false;}}
	showCountryoOnBasisOfGeo(event, context) {
		this._selected = (context === 'initialLoad') ? this.campaignRecord['Core_MDF_Region_cd__c'] : event.detail.value;
		if (this.recordTypeDeveloperName == Core_MDF_IPA_RecordType) {
			let regions = []; regions = this._selected.split(';'); this._selected = regions;
			if (this._selected != undefined && this._selected != null && this._selected != '') {
				let geoToCountryMappingWrapper = {};
				geoToCountryMappingWrapper = callingGeoToCountryMappingValue(this._selected, this.tempCountrySelected, this.ConnectedCallbackGeoCountryValue, this);
				this.campaignPicValues.Core_MDF_Market__c = geoToCountryMappingWrapper.Core_MDF_Market__c;
				this.countryPicklist = geoToCountryMappingWrapper.countryPicklist;
			} else {
				this.campaignPicValues.Core_MDF_Market__c = [...this.validCountriesFromCPObject]; this.countryPicklist = this.allCountryDisplay;
			}
			if (this.mode === 'edit') { this.campaignPicValues = lovValuesAddition(this.campaignPicValues, this.campaignFieldValue, this.campRecordTypeName, this.picklistApitoLabelReferenceMap, this, "geoChange"); }
		}
	}
	fetchGeoCountryMappingValue() {
		geoToCountryMappingValueConnectedCallBack()
			.then(data => {
				for (var key in data) {
					if (data.hasOwnProperty(key)) {
						this.ConnectedCallbackGeoCountryValue.set(key, data[key]);
						if (key != 0 && key != undefined && key != null && key != '' && key != 'null') {this.CountryDisplay = this.CountryDisplay.concat(this.ConnectedCallbackGeoCountryValue.get(key));}}}
				let mapcountry = localizeCountrymap(this.picValuesByRecType.picklistFieldValues['Core_MDF_Market__c'].values);
				for (let z = 0; z < this.CountryDisplay.length; z++) {
					this.allCountryDisplay.push({
						label: mapcountry.get(this.CountryDisplay[z]) != undefined ? mapcountry.get(this.CountryDisplay[z]) : this.CountryDisplay[z],
						value: this.CountryDisplay[z]
					});}})
			.catch(error => { this.error = error;});}
	selectAll() {
		let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]')
		for (let i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = true;}}
	setcustomRRValues() {
		this.customRRValues = this.campaignPicValues?.["Core_MDF_Reimbursement_Rate__c"];
	}
	pfrListPrepare() {
		var valdCheck = false;this.recPFRList = [];this.pfrListCloneInsert = [];
		let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]')
		for (let i = 0; i < checkboxes.length; i++) {if (checkboxes[i].checked == true) {
		this.recPFRList.push(checkboxes[i].name);}}
		let activityCloneData = [];
		let selectedActivities = JSON.parse(JSON.stringify(this.activityListClone));
		selectedActivities.forEach(clPfr => {
			if (this.recPFRList.includes(clPfr.Id)) {
				activityCloneData.push(clPfr);
			}
		});
		let parsedActivityCloneList = JSON.parse(JSON.stringify(this.activityListClone));//10 act

		//Get the depenency and validate only depedencies
		this.getUpdatedDependencyAndValInputFlds(activityCloneData);
		this.validateMandateActivityFlds(activityCloneData, 'save');
		this.getCampaignFieldsValues();
		var campaignbudVal = this.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c'];
		var accountSel = this.campaignFieldValue["Core_MDF_Account__c"];
		let pfrLs = JSON.parse(JSON.stringify(this.activityListClone));
		if (pfrLs !== undefined && pfrLs !== null) {		
		let dateValidationError = this.validateCampaignDateRangeError('save', pfrLs);
		if(dateValidationError === true)
		{
			valdCheck = true;
		}
		
			for (let i = 0; i < pfrLs.length; i++) {
		//Non Outcome based Activities
				pfrLs[i].Core_MDF_Budget_Type_nm__c = campaignbudVal;
				pfrLs[i].ChannelPartnerId = accountSel;
				if (this.recPFRList.includes(pfrLs[i].Id)) {
					if (pfrLs[i].act60daysValidation == true && this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance"
						&& this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone' && this.isCommunity == true) {
						valdCheck = true;
					}
					if (pfrLs[i].areMandateFieldsEmpty && this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance"
						&& this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone') {
						valdCheck = true;
					}
					if (pfrLs[i].initiativeNoneValidation == true && this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance"
						&& this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone') {
						valdCheck = true;
					}

					if ((!pfrLs[i].hasOwnProperty('kpiMetricEdited') || !pfrLs[i].kpiMetricEdited)  && this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance"
						&& this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone' && !this.campaignFieldValue['Core_MDF_CampOutcomeOpt_In_Ind__c']) {
						valdCheck = true;
					}

					if ((!pfrLs[i].hasOwnProperty('tacticMetricEdited') || !pfrLs[i].tacticMetricEdited) && this.campaignFieldValue["Core_MDF_Program__c"] == "Intel Partner Alliance"
						&& this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.campaignFieldValue['Core_MDF_CampOutcomeOpt_In_Ind__c'] && this.mode === 'clone') {
						valdCheck = true;
					}
				if (valdCheck !== true) {
				let errrId = '[data-id="' + pfrLs[i].Id + '"]';
				let styling = 'slds-box';
				this.showBorderAlert(errrId, styling);
				errrId = '[title="' + pfrLs[i].Id + '"]';
				styling = 'slds-hide';
				this.showBorderAlert(errrId, styling);
				this.pfrListCloneInsert.push(pfrLs[i]);
				valdCheck = false;
				}
				} else {
				let errrId = '[data-id="' + pfrLs[i].Id + '"]';
				let styling = 'slds-box';
				this.showBorderAlert(errrId, styling);
				errrId = '[title="' + pfrLs[i].Id + '"]';
				styling = 'slds-hide';
				this.showBorderAlert(errrId, styling);
				}}
			//Update the Budget type and Account in the IPA Outcome based instance to update the detail from Campaign.
			var outcomeBased = this.campaignFieldValue.hasOwnProperty('Core_MDF_CampOutcomeOpt_In_Ind__c') && this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"];
			if(outcomeBased && Array.isArray(this.activityToAttributeList) && this.activityToAttributeList.length > 0){
				this.activityToAttributeList = this.activityToAttributeList.map(item => {
				const clonedActivity = { ...item.activity };
				clonedActivity.Core_MDF_Budget_Type_nm__c = campaignbudVal;
				clonedActivity.ChannelPartnerId = accountSel;

				return {
					...item,
					activity: clonedActivity
				};
				});
			}	
		}
		return valdCheck
	}
	validateCampaignDateRangeError(context, activityList) {
		let pfrLs;
		var valdCheck = false; this.recPFRList = [];
		let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]')
		this.campaignDateRangeError = false;
		for (let i = 0; i < checkboxes.length; i++) {
			if (checkboxes[i].checked == true) {
				this.recPFRList.push(checkboxes[i].name);
			}
		}
		if (context == 'dateChange') {
			let updatedList = this.activityListClone.map(activity => {
				return { ...activity, showKPIErrorClone: (activity["kpiMetricEdited"] == true ? false : activity["showKPIErrorClone"])};
			});
			this.activityListClone = [...updatedList];
			
			let activityCloneData = [];
			let selectedActivities = JSON.parse(JSON.stringify(this.activityListClone));
			selectedActivities.forEach(clPfr => {
				if (this.recPFRList.includes(clPfr.Id)) {
					activityCloneData.push(clPfr);
				}
			});
			pfrLs = JSON.parse(JSON.stringify(this.activityListClone));

		}
		else {
			pfrLs = activityList;
		}

		if (pfrLs !== undefined && pfrLs !== null) {
			for (let i = 0; i < pfrLs.length; i++) {
				if (this.recPFRList.includes(pfrLs[i].Id)) {
					if ((this.campaignFieldValue['StartDate'] > pfrLs[i].Core_MDF_Start_Date__c) || (pfrLs[i].Core_MDF_End_Date__c > this.campaignFieldValue['EndDate'])) {
						let errorId = '[data-id="' + pfrLs[i].Id + '"]';
						let styling = 'outerbox';
						this.showBorderAlert(errorId, styling);
						errorId = '[title="' + pfrLs[i].Id + '"]';
						styling = 'slds-show';
						this.campaignDateRangeError = true;
						this.showBorderAlert(errorId, styling);
						valdCheck = true;
					}

					if (valdCheck !== true) {
						let errrId = '[data-id="' + pfrLs[i].Id + '"]';
						let styling = 'slds-box';
						this.showBorderAlert(errrId, styling);
						errrId = '[title="' + pfrLs[i].Id + '"]';
						styling = 'slds-hide';
						this.showBorderAlert(errrId, styling);
						valdCheck = false;
						this.campaignDateRangeError = false;
					}
				} else {
					let errrId = '[data-id="' + pfrLs[i].Id + '"]';
					let styling = 'slds-box';
					this.showBorderAlert(errrId, styling);
					errrId = '[title="' + pfrLs[i].Id + '"]';
					styling = 'slds-hide';
					this.showBorderAlert(errrId, styling);
				}
			}
		}
	return valdCheck 
	}
	showBorderAlert(errorId, styling) {
		let validatCheck = this.template.querySelector(errorId);
		if (validatCheck !== undefined && validatCheck != null) {validatCheck.setAttribute('class', styling);}
	}
	@api
	callChildMethodCampaign(pfrLisst, updatedActivityID) {
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.mode == 'clone') {
			this.getActivityCloneFields('Core_MDF_Custom_Picklist__c', this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"], this.recordTypeDeveloperName, this.proposalBasedIndicatorCamp, 'PartnerFundRequest');
			this.validateCampaignDateRangeError('dateChange');
			}
		this.template.querySelectorAll('c-core_-m-d-f_-activity_-view').forEach(element => {
			if (element.title === updatedActivityID) {
				element.updatePFRRecord(pfrLisst);}});}
	showBudgetErrorToast(ErrorMessage) {
		const evt1 = new ShowToastEvent({ title: 'Warning!', message: ErrorMessage, mode: 'pester', variant: 'warning',});
		this.dispatchEvent(evt1);
	}
	handlePicklistDependentValueChangeClone(picklistOnChange, campFieldAPIName, labelValue) {
		this.isAnyPicklistValueChanged = true;let showPickListRemovalError = false;let existingValuesList = [];let activityRecIdList = [];
		let existingValues;let removedPicklistValue = [];let previousValueObj;
		if (checkForUndefinedEmptyAndNull(this.activityListClone) && this.activityListClone.length && checkForUndefinedEmptyAndNull(this.campaignRecord[campFieldAPIName])) {
			let pfrFieldAPIName = this.cmpFieldAPINametoPFRFieldAPIName[campFieldAPIName];
			existingValues = this.campaignRecord[campFieldAPIName] && this.campaignRecord[campFieldAPIName];
			existingValuesList = existingValues?.split(';');
			let checkBoxesForActivityRecords = this.template.querySelectorAll('[data-id="actsinglerecord"]')
			for (let i = 0; i < checkBoxesForActivityRecords.length; i++) {
				if (checkBoxesForActivityRecords[i].checked == true) {
					activityRecIdList.push(checkBoxesForActivityRecords[i].name);}}
			let actCloneList = JSON.parse(JSON.stringify(this.activityListClone));
			actCloneList && actCloneList.forEach(activity => {
				if (activityRecIdList.find(actRec => actRec == activity.Id)) {
					activity['activityReferred'] = false;
					if (checkForUndefinedEmptyAndNull(activity[pfrFieldAPIName]) && activity[pfrFieldAPIName].length > 0) {
					let picklistValuesFromActivity = activity[pfrFieldAPIName]?.split(';');
					if (checkForUndefinedEmptyAndNull(picklistValuesFromActivity) && picklistValuesFromActivity.length) {
						let campaignPicklistValues = picklistOnChange?.filter(pickVal => picklistValuesFromActivity?.includes(pickVal));
						if (campaignPicklistValues.length == 0) {
							const bottomDiv = this.template.querySelector('[data-id="' + activity.Id + '"]');
							bottomDiv.scrollIntoView({ behavior: "smooth", block: "center", inline: "nearest" });
							showPickListRemovalError = true;
							activity['activityReferred'] = true; activity['picklistName'] = labelValue;
							}
						}
					}
				}
			});
			picklistOnChange.forEach(coun => {
				previousValueObj = JSON.parse(JSON.stringify(this.campaignRecord));
				if (checkForUndefinedEmptyAndNull(existingValuesList) && existingValuesList.length > 0 && !existingValuesList?.includes(coun)) {
					existingValuesList.push(coun);
					this.campaignRecord[campFieldAPIName] = this.campaignRecord[campFieldAPIName]?.concat(';' + coun);
				}});
			if (showPickListRemovalError) {
				this.showToastErrorForPicklistValueDependency();
				removedPicklistValue = existingValuesList?.filter(val => !picklistOnChange?.includes(val));
				actCloneList.map(activity => {
					if (activity['activityReferred']) {
					let picklistValuesFromActivity = activity[pfrFieldAPIName]?.split(';');
					let rp = removedPicklistValue?.filter(pickVal => picklistValuesFromActivity?.includes(pickVal));
					if(checkForUndefinedEmptyAndNull(rp) && rp.length > 0) {
							let availableOptions = this.campaignPicValues[campFieldAPIName];
					activity['activityFieldAPIName'] = pfrFieldAPIName;
							let removedPicklistValueArr = [];
					rp.forEach(pickVal => {
								let removedVal;
								if(checkForUndefinedEmptyAndNull(availableOptions) && Array.isArray(availableOptions) 
									&& availableOptions.length>0){
										removedVal = availableOptions.find(opt => opt.value == pickVal);
										removedVal = (checkForUndefinedEmptyAndNull(removedVal) && Object.keys(removedVal).length>0) ? removedVal.label : pickVal;
										removedPicklistValueArr.push(removedVal);
								}
					if (campFieldAPIName == 'Core_MDF_Market__c') {
					if (!this.countryValue?.includes(pickVal)) {
					this.countryValue.push(pickVal);}
					} else {
					if (!this.campaignFieldValue[campFieldAPIName]?.includes(pickVal)) {
					this.campaignFieldValue[campFieldAPIName].push(pickVal);}}
							});
							activity['removedPicklistValues'] = removedPicklistValueArr;
						}
					}
				});
			} else {
				let previousValues = existingValuesList?.filter(val => picklistOnChange?.includes(val));
				this.campaignRecord[campFieldAPIName] = previousValues?.join(';');}
			this.activityListClone = actCloneList;
			let campaignRecordCopy = previousValueObj;
			let countryPicklistValue = JSON.parse(JSON.stringify(this.countryValue));
			let campFieldValueCopy = JSON.parse(JSON.stringify(this.campaignFieldValue));
			let campFieldIndex = this.campPickListValuesChangedObj.findIndex(field => field.campFieldAPIName == campFieldAPIName);
			if (campFieldIndex == -1) {
			let obj = {}
			let oldCampaignValues = campaignRecordCopy[campFieldAPIName].split(';').sort((a, b) => (a > b) ? 1 : -1);
			let newCampaignValues = campFieldAPIName == 'Core_MDF_Market__c' ? countryPicklistValue.sort((a, b) => (a > b) ? 1 : -1) : campFieldValueCopy[campFieldAPIName].sort((a, b) => (a > b) ? 1 : -1);
			obj.campFieldAPIName = campFieldAPIName;
			obj.activityFieldAPIName = pfrFieldAPIName;
			obj.isPicklistValueChanged = oldCampaignValues.join(';') != newCampaignValues.join(';') ? true : false;
			obj.picklistValuesOnCampaign = obj.isPicklistValueChanged ? newCampaignValues : oldCampaignValues;
			this.campPickListValuesChangedObj.push(obj);
			} else {
				let oldCampaignValues = campaignRecordCopy[campFieldAPIName].split(';').sort((a, b) => (a > b) ? 1 : -1);
				let newCampaignValues = campFieldAPIName == 'Core_MDF_Market__c' ? countryPicklistValue.sort((a, b) => (a > b) ? 1 : -1) : campFieldValueCopy[campFieldAPIName].sort((a, b) => (a > b) ? 1 : -1);
				this.campPickListValuesChangedObj[campFieldIndex].isPicklistValueChanged = oldCampaignValues.join(';') != newCampaignValues.join(';') ? true : false;
				this.campPickListValuesChangedObj[campFieldIndex].picklistValuesOnCampaign = this.campPickListValuesChangedObj[campFieldIndex].isPicklistValueChanged ? newCampaignValues : oldCampaignValues;
			}
			let selectedEvent = new CustomEvent('picklistValueChangeEvent', { detail: { picklistWrapper: { campPickListValuesChangedObj: this.campPickListValuesChangedObj,}}});
			this.dispatchEvent(selectedEvent);
		}
	}
	showToastErrorForPicklistValueDependency() {
		this.showErrorToast(picklistValueRemovalErrorOnClone, 'sticky');
		this.activityErrorMessage = picklistValueRemovalErrorOnCloneActivity;
	}
	handleCheckbox(event) {
		var actId = event.target.name; var blankPFRFieldsAPINames = [];
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.mode == 'clone') {
			this.getActivityCloneFields('Core_MDF_Custom_Picklist__c', this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"], this.recordTypeDeveloperName, this.proposalBasedIndicatorCamp, 'PartnerFundRequest');
		}
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone' && this.isAnyPicklistValueChanged) {
			var pfrList = []; pfrList = this.activityListClone.filter(val => val.Id == actId);
			pfrList.forEach(element => {
				let changedPicklistArray = this.campPickListValuesChangedObj.filter(field => field.isPicklistValueChanged == true);
				if (changedPicklistArray != undefined && changedPicklistArray != null && changedPicklistArray != '') {
					if (changedPicklistArray.length > 0) {
					changedPicklistArray.map(pickList => {
					let availablePickListValuesonActivity = []; let commonValues = [];
					if (checkForUndefinedEmptyAndNull(element[pickList.activityFieldAPIName])) {
					availablePickListValuesonActivity = element[pickList.activityFieldAPIName].split(';');}
					commonValues = pickList.picklistValuesOnCampaign.filter(val => availablePickListValuesonActivity.includes(val));
					if (commonValues != undefined) {
					if (commonValues.length == 0 && ((pickList.activityFieldAPIName == 'Core_MDF_EcosystemPartner_nm__c' && checkForUndefinedEmptyAndNull(availablePickListValuesonActivity) && availablePickListValuesonActivity.length > 0) || pickList.activityFieldAPIName !== 'Core_MDF_EcosystemPartner_nm__c')) {
					blankPFRFieldsAPINames.push(pickList.activityFieldAPIName);
					let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]');
					for (let i = 0; i < checkboxes.length; i++) {
					if (checkboxes[i].name == actId && checkboxes[i].checked == true) {
					checkboxes[i].checked = false;}}}}});
					}}});
			var selectedEvent = new CustomEvent('activityBlankFieldsCheckoxValidation', { detail: { blankPFRFieldsAPINames: blankPFRFieldsAPINames } }); this.dispatchEvent(selectedEvent);
		}
		let actCloneList = JSON.parse(JSON.stringify(this.activityListClone));
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true && this.mode === 'clone') {
			var pfrToUpdate = [];
			actCloneList.forEach(element => {
				if (element.Id == actId) {
					let checkboxes = this.template.querySelectorAll('[data-id="actsinglerecord"]')
					for (let index = 0; index < checkboxes.length; index++) {
						if (checkboxes[index].name == actId) {
							element.ischecked = checkboxes[index].checked;
							element.act60daysValidation = (checkboxes[index].checked == true && this.isCommunity == true && checkActivityEventValidation(element)) ? true : false;
							element.initiativeNoneValidation = (checkboxes[index].checked == true && checkActivityInitiativeValidation(element)) ? true : false;
							var outcomeBased = this.campaignFieldValue.hasOwnProperty('Core_MDF_CampOutcomeOpt_In_Ind__c') && this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"];
							element.showKPIErrorClone = (checkboxes[index].checked == true && !element.hasOwnProperty('isBlankMetrics') && !outcomeBased) ? true : (checkboxes[index].checked == true && (element.hasOwnProperty('isBlankMetrics') && element.isBlankMetrics && !outcomeBased)) ? true : false;
							element.showTacticMetricsErrorClone = (checkboxes[index].checked && outcomeBased && !element.hasOwnProperty('tacticMetricEdited')) ? true : (checkboxes[index].checked && outcomeBased && (element.hasOwnProperty('tacticMetricEdited') && !element.tacticMetricEdited)) ? true : false;
							element['activityReferred'] = false; element.isInvalidOppId = false; pfrToUpdate.push(element);
							//Mandate Field value validation
							if (checkboxes[index].checked) {
								//To get the updated dependency for category and type
								let actList = new Array(element);
								this.getUpdatedDependencyAndValInputFlds(actList);
								this.validateMandateActivityFlds(actList, 'activitySelection');
								//individual activity
								let activityRec;
								let sctIndex = this.activityListClone.findIndex(pfrClone => pfrClone.Id == element.Id);
								if (sctIndex !== -1) {
									activityRec = this.activityListClone[sctIndex];
								}
								element.areMandateFieldsEmpty = activityRec.areMandateFieldsEmpty ? true : false;
							} else {
								element.areMandateFieldsEmpty = false;
							}
						}
					}
				}
			});
			if(pfrToUpdate.length>0){
				var selectedEvent = new CustomEvent('activityValidationEvent', { detail: {pfrToUpdate: pfrToUpdate} });this.dispatchEvent(selectedEvent);
			}
			this.activityListClone = actCloneList;
		}
	}
	getUpdatedDependencyAndValInputFlds(activityList) {
		let cntrlVal = [];
		cntrlVal.push(this.campaignFieldValue['Core_MDF_Focus_Area_nm__c']);
		cntrlVal.push(this.campaignFieldValue['Core_MDF_Program__c']);
		this.pfrDependencyBasedOnFocusArea = getPFRFieldsDependency(this.customPicklistValueDependency, this.pfrIPALovFields,  cntrlVal, this.pfrIPAActCatAndTypeDepFlds);
		let oldActivityCatAndTypeDep = this.pfrDependencyBasedOnActCatAndType;
		let activityCatAndTypeDep = getPFRActCategoryAndTypeDependency(activityList, this.customPicklistValueDependency);
		if (checkForUndefinedEmptyAndNull(activityCatAndTypeDep) && activityCatAndTypeDep.length > 0 && checkForUndefinedEmptyAndNull(oldActivityCatAndTypeDep) && oldActivityCatAndTypeDep.length > 0) {
				activityCatAndTypeDep.forEach(actDep => {
					if(Object.keys(actDep).length > 0) {
						let activityIdFromNewDepMap = Object.keys(actDep)[0];
						let index = oldActivityCatAndTypeDep.findIndex(act => Object.keys(act)[0] === activityIdFromNewDepMap);
						if (index != -1) {
							oldActivityCatAndTypeDep[index] = actDep;
						}	
					}
				});
				this.pfrDependencyBasedOnActCatAndType = oldActivityCatAndTypeDep;
			}
	}

	validateMandateActivityFlds(activityList, context) {
		//load - all activities ,handlecheckbox - single activity, save - all selected activities
		let parsedActivityCloneList = JSON.parse(JSON.stringify(this.activityListClone));
		let updatedActivityList = valMandateInpFldsOnActivity(activityList, context, this);
		updatedActivityList.forEach(actClone => {
			//global list
			let index = parsedActivityCloneList.findIndex(pfrClone => pfrClone.Id == actClone.Id);
			if (index !== -1) {
				parsedActivityCloneList[index] = { ...actClone };
			}
		});
		this.activityListClone = parsedActivityCloneList;
	}
	// Method to clear field values on clone of a proposal
	clearFieldValuesOnClone(){
		let actfield = JSON.parse(JSON.stringify(this.activityListClone));
		if (actfield !== undefined && actfield !== null) {
			for (let index = 0; index < actfield.length; index++) {
				// Make Attribution Fields as null on clone
				if (actfield[index].Core_MDF_Attribution_Variance_Pos_txt__c !== undefined && actfield[index].Core_MDF_Attribution_Variance_Pos_txt__c !== null && actfield[index].Core_MDF_Attribution_Variance_Pos_txt__c !==''){
					actfield[index].Core_MDF_Attribution_Variance_Pos_txt__c = null;
				}
				 if (actfield[index].Core_MDF_Attribution_Variance_Neg_txt__c !== undefined && actfield[index].Core_MDF_Attribution_Variance_Neg_txt__c !== null && actfield[index].Core_MDF_Attribution_Variance_Neg_txt__c !==''){
					actfield[index].Core_MDF_Attribution_Variance_Neg_txt__c = null;
				}
			}
		this.activityListClone=actfield;
		}
	}
	clearKPIfieldsClone() { //to clear the KPI fields on load of proposal clone scenario
		var actCloneList = JSON.parse(JSON.stringify(this.activityListClone));
		actCloneList.forEach(act => {
			if(act.Core_MDF_Key_Marketing_Indicator_nm__c != null && act.Core_MDF_Key_Marketing_Indicator_nm__c != undefined && act.Core_MDF_Key_Marketing_Indicator_nm__c != ''){
				act.Core_MDF_Key_Marketing_Indicator_nm__c = null;
			}
			if(act.Core_MDF_Lead_Quantity_nbr__c != null && act.Core_MDF_Lead_Quantity_nbr__c != undefined && act.Core_MDF_Lead_Quantity_nbr__c != ''){
				act.Core_MDF_Lead_Quantity_nbr__c = null;
			}
			if(act.Core_MDF_Deployment_Quantity_nbr__c != null && act.Core_MDF_Deployment_Quantity_nbr__c != undefined && act.Core_MDF_Deployment_Quantity_nbr__c != ''){
				act.Core_MDF_Deployment_Quantity_nbr__c = null;
			}
			if(act.Core_MDF_Other_Quantity_nbr__c != null && act.Core_MDF_Other_Quantity_nbr__c != undefined && act.Core_MDF_Other_Quantity_nbr__c != ''){
				act.Core_MDF_Other_Quantity_nbr__c = null;
			}
		});
		this.activityListClone = actCloneList;
	}

	handleMarketSegmentChange(event) {
		this.campaignFieldValue[event.target.name] = event.target.value;
	}

	handleReasonForBackDatingChange(event) {
		this.campaignFieldValue[event.target.name] = event.target.value;
		if (event.target.value === 'Other') {
			this.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = true;
			this.campaignFieldValue["Core_MDF_Other_Reason_Name_txt__c"] = '';
		} else {
			this.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = false;
			this.campaignFieldValue["Core_MDF_Other_Reason_Name_txt__c"] = '';
		}
	}

	handleOtherReasonNameChange(event) {
		let value = event.target.value;
		if (value.trim() === '') {
			event.target.setCustomValidity('Complete this field.');
		} else {            
			this.campaignFieldValue[event.target.name] = value;
			event.target.setCustomValidity('');
		}
		event.target.reportValidity();
	}
	handleOtherOutcomeChange(event) {
		let value = event.target.value;
		if (value.trim() === '') {
			event.target.setCustomValidity('Complete this field.');
		} else {
			this.campaignFieldValue[event.target.name] = value;
			event.target.setCustomValidity('');
		}
		event.target.reportValidity();
	}
	validateOutcomeError(){
		const isOptIn = this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true;
		const outcomevalue = this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] ;
		this.outcomeBasedError = isOptIn && checkForUndefinedEmptyAndNull(outcomevalue) && outcomevalue.includes('Other');
	} 
	 showOtherOutcomeTextField(){ 
		this.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = checkForUndefinedEmptyAndNull(this.campaignFieldValue["Core_MDF_Outcomes_nm__c"]) && (this.campaignFieldValue["Core_MDF_Outcomes_nm__c"].includes("Other"));
		this.campaignRequiredFields["Core_MDF_Other_Outcome_txt__c"] = this.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"];
	}
	shouldHideOther(){
		return ( this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && this.campaignFieldValue?.Core_MDF_Proposal_Based_Ind__c === true && this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true);
	}
	filterOtherFromOutcomeMetric(){
		//Roshan - defect fix
		const hideOther = this.shouldHideOther();
		this.campaignPicValues["Core_MDF_Outcomes_nm__c"] = this.originalOutcomesOptions.filter(opt => !hideOther || opt.value !== 'Other');
		if (hideOther) {
			this.removeOtherFromSelectedOutcomes();
		}
		
		this.showOtherOutcomeTextField(); 
		this.validateOutcomeError(); 
	}
	removeOtherFromSelectedOutcomes() {
		if (this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] && this.campaignFieldValue["Core_MDF_Outcomes_nm__c"].includes("Other")) {
			this.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = this.campaignFieldValue["Core_MDF_Outcomes_nm__c"].filter(value => value !== "Other");
			this.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
			this.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = false;
			this.campaignRequiredFields["Core_MDF_Other_Outcome_txt__c"] = false;
		}
		if (this.selectedOutcomes && this.selectedOutcomes.includes("Other")) {
			this.selectedOutcomes = this.selectedOutcomes.filter(outcome => outcome !== "Other");
		}
		if (this.editedOutcomeData && this.editedOutcomeData["Other"]) {
			delete this.editedOutcomeData["Other"];
			this.rows = Object.values(this.editedOutcomeData);
		}
		this.multipleValuesSelected = this.selectedOutcomes ? this.selectedOutcomes.length > 1 : false;
	}
	get hasSelectedOutcomes() {
		const values = this.campaignFieldValue["Core_MDF_Outcomes_nm__c"];
		return Array.isArray(values) && values.length > 0;
	}
	 // Ealaya TWC3117-14432 Activity Category changes
	validateActivityCategory() {
		const isOptIn = this.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true;
		const activityCategoryValue = this.campaignFieldValue["Core_MDF_Activity_Category_Type__c"];
		if (isOptIn) {
			if (checkForUndefinedEmptyAndNull(activityCategoryValue) && activityCategoryValue.length > 0 && (!activityCategoryValue.includes('Outcome-Based->Outcome-Based') || activityCategoryValue.length !== 1)) {//TWC3117-14681
				this.activityCategoryBasedError = true;
			} else {
				this.activityCategoryBasedError = false;
				this.isvalidActCatType = true;
			}
		}else{
			if (checkForUndefinedEmptyAndNull(activityCategoryValue) && activityCategoryValue.includes('Outcome-Based->Outcome-Based')){
				this.activityCategoryBasedError = true;
			} else {
				this.activityCategoryBasedError = false;
				this.isvalidActCatType = true;
			}
		}
	}
	// Ealaya TWC3117-14432 Activity Category changes
	validateIPAStartDateError() {
		const budgetTypeValue = this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"];
		if (this.recordTypeDeveloperName === Core_MDF_IPA_RecordType && budgetTypeValue.includes('Account Plan') && this.campaignFieldValue["StartDate"] >= Core_MDF_IPA_AccountBased_StartDate) {
			this.showIPAStartDateError = true;
		}
		else{
			this.showIPAStartDateError = false;
		}
	}
	//TWC3117-17805 - Aditya 
	validateCCFDCFStartDateError() {
		const isCCFOrDCF = (this.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName || this.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName );
		if (isCCFOrDCF && this.campaignFieldValue["StartDate"] >= Core_MDF_CCF_DCF_BlockCampaign_StartDate) {
			this.showCCFDCFStartDateError  = true;
			this.isCCFDCFStartDateValid = false;
		} else {
			this.showCCFDCFStartDateError = false;
			this.isCCFDCFStartDateValid = true;
		}
	}
	formatDate(dateString) {
		const dateObj = new Date(dateString);
		const locale = userLocale || 'en-GB';
		const formattedDate = dateObj.toLocaleDateString(locale, { day: 'numeric', month: 'short', year: 'numeric' });
		return formattedDate;
	}
	get formattedCampaignOutcomeVisibilityDate() {
    	return this.formatDate(Core_MDF_IPA_AccountBased_StartDate);
	}
	get beforeDateText() {
		return this.label.Core_MDF_AccountPlan_StartDate_Error.split('{0}')[0];
	}
	get afterDateText() {
		return this.label.Core_MDF_AccountPlan_StartDate_Error.split('{0}')[1];
	}
	get beforeCCFDCFDateText() {
		return 'Campaigns unavailable from ';
	}
	
	get afterCCFDCFDateText() {
		return ' Create an Outcome-Based campaign instead.'
	}
	
	get formattedCCFDCFBlockDate() {
    	return this.formatDate(Core_MDF_CCF_DCF_BlockCampaign_StartDate);
	}
	navigateToActivityComponent() {
	this[NavigationMixin.Navigate]({
		type: 'standard__navItemPage',
		attributes: {
			apiName: 'Core_MDF_Outcome_Based_Campaigns'
		}
	});
	}
	get showApprovalCheckbox() {
		try {
			const selectedBudgetTypes = this.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"];
			const hasCMPBudgetType =  selectedBudgetTypes && Array.isArray(selectedBudgetTypes) && selectedBudgetTypes.some(value => CMP_BUDGET_TYPES.includes(value));
			if (!hasCMPBudgetType && this.campaignFieldValue?.Core_MDF_Activity_Approval_Required_Ind__c) {
				this.campaignFieldValue.Core_MDF_Activity_Approval_Required_Ind__c = false;
			}
        	return hasCMPBudgetType;
		} catch (e) {
			console.error(e);
			return false;
		}
	}
	get isApprovalRequired() {		
		if (this.mode === 'clone') {
			return false;
		}
		return this.campaignFieldValue ?.Core_MDF_Activity_Approval_Required_Ind__c === true;
	}
	get isApprovalCheckboxDisabled() {
		try {
			const activityList = this.activityListEdit || [];
			const existingDisabled = this.campaignFieldDisabled	?.Core_MDF_Activity_Approval_Required_Ind__c;
			const hasCMPActivity = activityList.some(activity =>
					activity.Core_MDF_Budget_Type_nm__c &&	CMP_BUDGET_TYPES.includes(activity.Core_MDF_Budget_Type_nm__c));
			return existingDisabled || hasCMPActivity;
		} catch (e) {
			console.error(e);
			return false;
		}
	}
	get isIPAProposalBasedProgram() {		
		if (this.campaignFieldValue["Core_MDF_Program__c"] == Core_MDF_IPA_Program_Name && this.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"] == true) {
			return true;
		}
		return false;
	}
	get campaignPurposeIPAHeader() {		
		if (this.isIPAProposalBasedProgram) {
			return this.campaignPurposeDescriptiveHeader;
		}
		return this.title;
	}

	// Outcome statement(s) shown below the grid for IPA proposal-based campaigns
	get outcomeStatements() {
		if (!this.isIPAProposalBasedProgram) {
			return [];
		}
		const brands = this.getSelectedPicklistLabels('Core_MDF_Brand__c');
		const technologies = this.getSelectedPicklistLabels('Core_MDF_Technology__c');
		const baselinePeriodMap = this.outcomePicklistValues["Core_MDF_Baseline_Period_nm__c"] || {};
		const dataRows = Object.values(this.editedOutcomeData || {});
		return dataRows
			.map(row => {
				if (!checkForUndefinedEmptyAndNull(row.baselineQuantity) || !checkForUndefinedEmptyAndNull(row.goalQuantity) || !checkForUndefinedEmptyAndNull(row.baselinePeriod)) {
					return null;
				}
				const baseValue = parseFloat(row.baselineQuantity);
				const goalValue = parseFloat(row.goalQuantity);
				if (isNaN(baseValue) || isNaN(goalValue)) {
					return null;
				}
				// AC9: (|Goal - Baseline| / Baseline) * 100 when Baseline > 0
				const percentChange = baseValue === 0 ? goalValue * 100 : ((goalValue - baseValue) / baseValue) * 100;
				const formatted = Number.isInteger(percentChange) ? Math.abs(percentChange) : Math.abs(percentChange).toFixed(2);
				// AC6/AC7/AC8: Increase when goal >= baseline (equal => Increase by 0%), Decrease when goal < baseline
				const direction = percentChange >= 0 ? this.increaseByLabel : this.decreaseByLabel;
				const baselinePeriodLabel = baselinePeriodMap[row.baselinePeriod] || row.baselinePeriod || '';
				// Format: "Increase by 150% (from 2 to 5) <Baseline Period> for <Brands> and <Technologies>"
				const technologySuffix = checkForUndefinedEmptyAndNull(technologies) ? ` ${this.outcomeStmtAnd} ${technologies}` : '';
				const text = `${direction} ${formatted}${this.outcomeStmtFrom} ${baseValue} ${this.outcomeStmtTo} ${goalValue}${this.outcomeStmtClosedBracket} ${baselinePeriodLabel} ${this.outcomeStmtFor} ${brands}${technologySuffix}`;
				return { id: row.id || row.outcome, text };
			})
			.filter(Boolean);
	}

	getSelectedPicklistLabels(fieldApiName) {
		const selected = this.campaignFieldValue[fieldApiName];
		if (!checkForUndefinedEmptyAndNull(selected)) {
			return '';
		}
		const selectedValues = Array.isArray(selected) ? selected : String(selected).split(';');
		const options = this.campaignPicValues[fieldApiName] || [];
		const valueToLabel = new Map(options.map(opt => [opt.value, opt.label]));
		return selectedValues.map(val => valueToLabel.get(val) || val).join(', ');
	}
}