import { LightningElement, track, wire, api } from 'lwc';
import Core_MDF_PFR_None_Translation from '@salesforce/label/c.Core_MDF_PFR_None_Translation';
import Core_MDF_Intel_MDF_Fields from '@salesforce/label/c.Core_MDF_Intel_MDF_Fields';
import PicklistFetcher from '@salesforce/apex/Core_MDF_CampaignCreatePage.PicklistFetcher';
import picklistValueRemovalErrorOnEdit from '@salesforce/label/c.Core_MDF_IPA_Edit_PicklistValue_Removal_Error';
import focusAreaPicklistValues from '@salesforce/label/c.Core_MDF_Campaign_FocusArea_PicklistValues';
import focusAreaDependentFields from '@salesforce/label/c.Core_MDF_Campaign_FocusArea_DependentFields';
import Core_MDF_IPA_RecordType from '@salesforce/label/c.Core_MDF_IPA_RecordType';
import Core_MDF_Picklists_IPA from '@salesforce/label/c.Core_MDF_Picklists_IPA';
import rmfPicklistFields from '@salesforce/label/c.Core_MDF_RMF_Campaign_Picklist_Fields';
import Core_MDF_Picklists_CCF_DCF from '@salesforce/label/c.Core_MDF_Picklists_CCF_DCF';
import Core_MDF_EEF_Campaign_Picklist_Fields from '@salesforce/label/c.Core_MDF_EEF_Campaign_Picklist_Fields';
import Core_MDF_CCF_RecordTypeName from "@salesforce/label/c.Core_MDF_CCF_RecordTypeName";
import Core_MDF_DCF_RecordTypeName from "@salesforce/label/c.Core_MDF_DCF_RecordTypeName";
import rmfRecTypeName from "@salesforce/label/c.Core_MDF_RetailProgram";
import reviewErrOnPage_ErrMsg from '@salesforce/label/c.Core_MDF_Empty_Field_Error';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivityFields from '@salesforce/apex/Core_MDF_CampaignCreatePage.getActivityFields';
import Core_MDF_LegacyRestricBudgetTypes from '@salesforce/label/c.Core_MDF_LegacyRestricBudgetTypes';
import Core_MDF_OPAL_BudgetTypes from "@salesforce/label/c.Core_MDF_OPAL_BudgetTypes";
import Core_MDF_IPA_Program_Name from '@salesforce/label/c.Core_MDF_IPA_Program_Name';
import technicalProgramNames from '@salesforce/label/c.Core_MDF_TechnicalProgramName';
import Core_MDF_SPIF_Activity_Types from '@salesforce/label/c.Core_MDF_SPIF_Activity_Types';
import campaignEndDateValidation from '@salesforce/label/c.Core_MDF_Campaign_EndDate_Validation';
import campaignSpanYearsValidation from '@salesforce/label/c.Core_MDF_Campaign_SpanOfYears_Validation';
import Core_MDF_EEF_RecordType from '@salesforce/label/c.Core_MDF_EEF_RecordType';
import getSIOrISVAccount from '@salesforce/apex/Core_MDF_CampaignCreatePage.getSIOrISVAccounts';
import fetchCampToActPartnerRecord from '@salesforce/apex/Core_MDF_CampaignCreatePage.fetchCampToActPartnerData';
import Core_MDF_CCF_Program_Name from '@salesforce/label/c.Core_MDF_NonTranslateCCFRecordType';
import Core_MDF_DCF_Program_Name from '@salesforce/label/c.Core_MDF_NonTranslateDCFRecordType';
import Core_MDF_EEF_Program_Name from '@salesforce/label/c.Core_MDF_EEF_Program_Name';
import restrictStartDateUpdate from '@salesforce/label/c.Core_MDF_RestrictStartDateEdit_Campaign';
import Core_MDF_Co_GTM_RecordType from '@salesforce/label/c.Core_MDF_Co_GTM_RecordType';
import Core_MDF_Co_GTM_Program_Name from '@salesforce/label/c.Core_MDF_Co_GTM_Technical_program_name';
import Core_MDF_Picklists_Co_GTM from '@salesforce/label/c.Core_MDF_Picklists_Co_GTM';
import Core_MDF_EVENT_CATEGORY from '@salesforce/label/c.Core_MDF_Event_Activity_Category';
import campaignOutcomeVisibilityDate from '@salesforce/label/c.Core_MDF_CampaignOutcomeVisibilityDate';
import startDateErrorForOutcome from '@salesforce/label/c.Core_MDF_StartDateErrorForOutcome';
import coGTMCampaignSpanYearsValidation from '@salesforce/label/c.Core_MDF_CoGTMCampaign_SpanOfYears_Validation';
import coGTMCampaignStartDateValidation from '@salesforce/label/c.Core_MDF_CoGTM_Campaign_External_StartDate_Validation';
import campaignOutcomeVisibilityDateCCF_DCF_RMF from '@salesforce/label/c.Core_MDF_CCF_DCF_RMF_CampaignOutcomeVisibilityDate';//Ealay
import campaignIPAOutcomeConfigureDate from '@salesforce/label/c.Core_MDF_IPA_Outcome_Configure_Date';//Ealay
import Core_MDF_Campaign_OEM_Platform_End_Date_Validation from '@salesforce/label/c.Core_MDF_Campaign_OEM_Platform_End_Date_Validation';//Swati
import blockStartDateChangeForNonOutcome from '@salesforce/label/c.Core_MDF_BlockDateChangeOnOutcomeBsdCmp';
import campaignOutcomeVisibilityDate_RMF from '@salesforce/label/c.Core_MDF_RMF_CampaignOutcomeVisibilityDate';//16406
import Core_MDF_Other_Specify from '@salesforce/label/c.Core_MDF_Other_Specify';

const outcomePrefix = 'Core_MDF_Campaign_Outcomes__c.';
const outcomeList = ["Core_MDF_Initial_Baseline_Quantity_nbr__c", "Core_MDF_Goal_Quantity_nbr__c", "Core_MDF_Quantity_nbr__c", "Core_MDF_Baseline_Period_nm__c", "Core_MDF_Outcome_Criteria_txt__c"];
const validOutcomeMetricRecordTypeWithOutIPA = [
	Core_MDF_CCF_RecordTypeName,
	Core_MDF_DCF_RecordTypeName,
	rmfRecTypeName
];//Ealay

const dateJune2025 = '2025-06-29';
const dateOct2025 ='2025-10-01';

function getRecordTypeDependentFields(recordType) {
	let pickListFields = [];
	if (recordType == 'Core_MDF_Intel_Partner_Alliance_Account_Based' || recordType == 'Core_MDF_Intel_Partner_Alliance_Proposal_Based') {
		pickListFields = Core_MDF_Picklists_IPA.split(',');
	}
	else if (recordType === rmfRecTypeName) {
		pickListFields = rmfPicklistFields.split(',');
	}
	else if (recordType == Core_MDF_CCF_RecordTypeName || recordType == Core_MDF_DCF_RecordTypeName) {
		pickListFields = Core_MDF_Picklists_CCF_DCF.split(',');
	}
	else if (recordType == Core_MDF_EEF_RecordType) {
		pickListFields = Core_MDF_EEF_Campaign_Picklist_Fields.split(',');
	} else if (recordType == Core_MDF_Co_GTM_RecordType) {
		pickListFields = Core_MDF_Picklists_Co_GTM.split(',');
	}
	return pickListFields;
}

export default async function fetchPicklist(campRecordTypeName, campaignPicValues, budgettype, picklistApitoLabelReferenceMap, dependency, compRef) {
	var displayNone = false;
	let focusAreaDependentFieldValues = [];
	var pickListFields;
	let customPicklistValueDependency = [];
	let fieldsBasedOnProgram = ['Core_MDF_Outcomes_nm__c', 'Core_MDF_Opal_Budget_Type_Txt__c', 'Core_MDF_Budget_Type_txt__c', 'Core_MDF_Focus_Area_nm__c', 'Core_MDF_Market_Segment_nm__c'];
	fieldsBasedOnProgram = (compRef.recordTypeDeveloperName === Core_MDF_EEF_RecordType) ? [...fieldsBasedOnProgram, 'Core_MDF_Market__c'] : fieldsBasedOnProgram;
	await PicklistFetcher({ recordTypeName: campRecordTypeName })
		.then((result) => {
			if (campRecordTypeName == 'Core_MDF_Intel_Partner_Alliance_Account_Based' || campRecordTypeName == 'Core_MDF_Intel_Partner_Alliance_Proposal_Based') {
				focusAreaDependentFieldValues = getFocusAreaDependentValues(result);
				customPicklistValueDependency = result?.picklistFieldValues;
			}
			if (dependency == 'loadFieldsBasedOnProgram') {
				pickListFields = fieldsBasedOnProgram;
			} else {
				pickListFields = getRecordTypeDependentFields(campRecordTypeName);
			}
			displayNone = true;
			//Preserve the original controlling values. On clone+initalLoad, validateControllingFieldValues trims the
			//shared 'budgettype' (e.g. removes the Budget Type value) for fieldsBasedOnProgram fields. Any field that
			//does NOT go through that trimming must use the original controlling values, otherwise it can lose its
			//controlling value (e.g. Measurement Approach, controlled by Budget Type, loses its options on clone load).
			let originalControllingValues = Array.isArray(budgettype) ? [...budgettype] : budgettype;
			for (let i = 0; i < pickListFields.length; i++) {
				let sControllingFieldValues = result.picklistFieldValues[pickListFields[i]].controllerValues;
				let sFieldValues = result.picklistFieldValues[pickListFields[i]].values;
				let isControllingValueValidatedField = fieldsBasedOnProgram.includes(pickListFields[i]) && compRef.mode == 'clone' && compRef.initalLoad;
				if (isControllingValueValidatedField) {
					budgettype = validateControllingFieldValues(sControllingFieldValues, sFieldValues, budgettype, pickListFields[i]);
				}

				if (compRef.bypassBudgetTypeLoad && pickListFields[i] == 'Core_MDF_Opal_Budget_Type_Txt__c' && compRef.mode == 'edit'
					&& (campRecordTypeName == 'Core_MDF_Intel_Partner_Alliance_Account_Based' || campRecordTypeName == 'Core_MDF_Intel_Partner_Alliance_Proposal_Based')) {
					compRef.bypassBudgetTypeLoad = false;
					continue;
				}
				//Fields that went through validateControllingFieldValues use the trimmed 'budgettype'; all other fields use the original (untrimmed) controlling values.
				let controllingValuesForField = isControllingValueValidatedField ? budgettype : originalControllingValues;
				fetchPicklistFields(pickListFields[i], sControllingFieldValues, sFieldValues, campaignPicValues, displayNone, controllingValuesForField, picklistApitoLabelReferenceMap, compRef);
			}
		})////at this place we are loosing the available list values from our picklist
	let result = {
		campaignPicValues: campaignPicValues,
		focusAreaDependentFieldValues: focusAreaDependentFieldValues,
		customPicklistValueDependency: customPicklistValueDependency,
	}
	return result;
}

function validateControllingFieldValues(controllerValues, picklistValues, selControllingValues, fieldAPIName) {
	//let finalControllingValues = JSON.parse(JSON.stringify(selControllingValues));
	let programList = technicalProgramNames.split(';');
	let focusAreaList = focusAreaPicklistValues.split(',');
	let validbudgetTypes = [];
	let finalSelectedCtrlVal = [];
	if (picklistValues.length > 0 && selControllingValues.length > 0) {
		selControllingValues.forEach(selVal => {//CCF, MDF, MDF+
			const controllingValue = controllerValues[selVal];//only CCF
			controllingValue && picklistValues.forEach(pVal => { //
				if (pVal.value.includes('&amp;')) {
					pVal.value = pVal.value.replaceAll('&amp;', '&');
				}
				if (selControllingValues.includes(pVal.value) && pVal.validFor?.includes(controllingValue)) {
					validbudgetTypes.push(pVal.value);// OEM CMP
				}
			})
		});
		selControllingValues.forEach(contrlVal => {///CCF, MDF, MDF+
			if (!programList.includes(contrlVal) && !validbudgetTypes.includes(contrlVal) && ((fieldAPIName === 'Core_MDF_Focus_Area_nm__c' && focusAreaList.includes(contrlVal)) || (fieldAPIName !== 'Core_MDF_Focus_Area_nm__c' && !focusAreaList.includes(contrlVal)))) {
				let selIndex = selControllingValues.findIndex(sel => sel == contrlVal);
				if (selIndex == -1) {
					finalSelectedCtrlVal.push(contrlVal);
				}
			} else {
				finalSelectedCtrlVal.push(contrlVal);
			}
		})
	}
	return finalSelectedCtrlVal;
}
function getFocusAreaDependentValues(result) {
	let focusAreaNames = focusAreaPicklistValues.split(',');
	let fieldsDependentOnFocusArea = focusAreaDependentFields.split(',');
	let focusAreaDependentFieldValues = [];
	focusAreaNames.map(fc => {
		let obj = {}
		fieldsDependentOnFocusArea && fieldsDependentOnFocusArea.map(field => {
			let picklistValuesBasedOnFocusArea = [];
			let referenceValueCode;
			let controllerValues = result.picklistFieldValues[field].controllerValues;
			let pickListValuesFromObject = result.picklistFieldValues[field].values;
			if (Object.keys(controllerValues).length) {
				referenceValueCode = controllerValues[fc];
			}
			pickListValuesFromObject && pickListValuesFromObject.map(pickval => {
				if (pickval.validFor.length && pickval.validFor.includes(referenceValueCode)) {
					if (pickval.value.includes('&amp;')) {
						pickval.value = pickval.value.replaceAll('&amp;', '&');
					}
					picklistValuesBasedOnFocusArea.push(pickval.value);
				}
			});
			obj[field] = picklistValuesBasedOnFocusArea;
		});
		focusAreaDependentFieldValues.push({ [fc]: obj });
	});
	return focusAreaDependentFieldValues;
}

function fetchPicklistFields(fldname, scontrolvalues, sfieldcompletevalues, campaignPicValues, displayNone, budgettype, picklistApitoLabelReferenceMap, compRef) {
	try {
		var ParPickField = [];
		var checkDuplicate = [];
		campaignPicValues[fldname] = [];
		let activityCategoryValuesofCmp = [];
		let controllingfields = {};
		let pickValsFromCmpObject = [];
		var filteredActivityCategoryTypeValuesSet;
		for (var i = 0; i < budgettype.length; i++) {
			var controllingValue = scontrolvalues[budgettype[i]];
			sfieldcompletevalues.forEach(item => {
				if ((item?.validFor.includes(controllingValue) || (fldname == 'Core_MDF_Ecosystem_Partner_Nm__c')) && !checkDuplicate.includes(item.value)) {
					if (item.value.includes('&amp;') && item.label.includes('&amp;')) {
						item.label = item.label.replaceAll('&amp;', '&');
						item.value = item.value.replaceAll('&amp;', '&');
					}
					ParPickField.push({
						class: "optionClass", label: (picklistApitoLabelReferenceMap.get(item.value + '-' + fldname) != undefined ? picklistApitoLabelReferenceMap.get(item.value + '-' + fldname) : item.value), value: item.value
					});
					checkDuplicate.push(item.value);
				}
			})

			if (ParPickField.length > 0) {
				if (fldname == "Core_MDF_Activity_Category_Type__c") {
					ParPickField.forEach(item => {
						item.label = item.label.replaceAll('&gt;', '>');
						item.value = item.value.replaceAll('&gt;', '>');
					})
					compRef.activityCategoryTypeValuesFromCPObject = ParPickField;
					console.log('Ealay1----. ParPickField picklist value -->' + JSON.stringify(ParPickField));
					console.log('Ealay2----. Activity picklist value -->' + JSON.stringify(compRef.activityCategoryTypeValuesFromCPObject));
				} else {
					campaignPicValues[fldname] = ParPickField;
				}
			}
		}
		if (fldname != 'Core_MDF_Reimbursement_Rate__c' && fldname != 'Core_MDF_Proposal_Score_nbr__c' && fldname != 'Core_MDF_Measurement_Approach_nm__c') {
			campaignPicValues[fldname].sort((a, b) => a.label.localeCompare(b.label));
		}
		//Roshan - defect fix
		if (fldname === 'Core_MDF_Outcomes_nm__c') {
			compRef.originalOutcomesOptions = [...campaignPicValues[fldname]];
			compRef.filterOtherFromOutcomeMetric();
		}
		if (fldname == 'Core_MDF_Ecosystem_Partner_Nm__c' && campaignPicValues[fldname] != undefined)
			campaignPicValues[fldname] = picklistValueAtTop(campaignPicValues[fldname], 'None', picklistApitoLabelReferenceMap, fldname);
		if (fldname == 'Core_MDF_Market__c') {
			compRef.validCountriesFromCPObject = [...campaignPicValues["Core_MDF_Market__c"]];
		}
		if ((fldname == 'Core_MDF_Priority_2_nm__c' || fldname == 'Core_MDF_Priority_3_nm__c') && campaignPicValues[fldname] != undefined) {
			campaignPicValues[fldname] = picklistValueAtTop(campaignPicValues[fldname], 'None', picklistApitoLabelReferenceMap, fldname);
		}

		if (compRef.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType && (fldname == 'Core_MDF_Brand__c' || fldname == 'Core_MDF_Technology__c') && campaignPicValues[fldname] != undefined) {
			campaignPicValues[fldname] = picklistValueAtBottom(campaignPicValues[fldname], 'Other', picklistApitoLabelReferenceMap, fldname);
		}
	} catch (error) {
		console.error('Error in fetchPicklistFields' + error);
	}
}
export function fetchActivityCategoryTypeValues(supportsLegacyValue, activityCategoryTypeValuesofCP, picValuesByRecType, compRef) {
	let controllingfields = {};
	let pickValsFromCmpObject = [];
	let supportLegacyArray = [];
	var filteredActivityCategoryTypeValuesSet;
	let finalActCatType = [];
	if (checkForUndefinedEmptyAndNull(supportsLegacyValue) && checkForUndefinedEmptyAndNull(activityCategoryTypeValuesofCP) && activityCategoryTypeValuesofCP.length > 0 && checkForUndefinedEmptyAndNull(picValuesByRecType)) {
		controllingfields = picValuesByRecType.picklistFieldValues.Core_MDF_Activity_Category_Type__c.controllerValues;
		pickValsFromCmpObject = picValuesByRecType.picklistFieldValues.Core_MDF_Activity_Category_Type__c.values;
		supportLegacyArray.push(supportsLegacyValue);
		const activityCategoryValuesofCmp = fetchPFRPicklistFields('Core_MDF_Activity_Category_Type__c', controllingfields, pickValsFromCmpObject, supportLegacyArray).Core_MDF_Activity_Category_Type__c;
		const fileteredPickValsSet = new Set(activityCategoryValuesofCmp.map(item => item.value));
		filteredActivityCategoryTypeValuesSet = activityCategoryTypeValuesofCP.filter(item => fileteredPickValsSet.has(item.value));
		/*if(compRef.mode == 'edit') { 
			let actCatType = {'Core_MDF_Activity_Category_Type__c': filteredActivityCategoryTypeValuesSet}
			let validActCatTypeValues = lovValuesAddition(actCatType, compRef.campaignFieldValue, compRef.recordTypeDeveloperName,compRef.picklistApitoLabelReferenceMap, compRef, 'activityCategoryType');
			finalActCatType = validActCatTypeValues['Core_MDF_Activity_Category_Type__c'];
			filteredActivityCategoryTypeValuesSet = finalActCatType;
		}*/
		filteredActivityCategoryTypeValuesSet.sort((a, b) => a.label.localeCompare(b.label));
	}
	return filteredActivityCategoryTypeValuesSet;
}

function picklistValueAtTop(picklisValues, valueAtTop, picklistApitoLabelReferenceMap, fldname) {
	picklisValues = picklisValues.filter(item => item.value !== valueAtTop);
	picklisValues.unshift({
		class: "optionClass", label: (picklistApitoLabelReferenceMap.get(valueAtTop + '-' + fldname) != undefined ? picklistApitoLabelReferenceMap.get(valueAtTop + '-' + fldname) : valueAtTop), value: valueAtTop
	});
	return picklisValues;

}

function picklistValueAtBottom(picklisValues, valueAtBottom, picklistApitoLabelReferenceMap, fldname) {
	picklisValues = picklisValues.filter(item => item.value !== valueAtBottom);//will get other picklist values except 'Other'.
	picklisValues.push({
		class: "optionClass", label: (picklistApitoLabelReferenceMap.get(valueAtBottom + '-' + fldname) != undefined ? picklistApitoLabelReferenceMap.get(valueAtBottom + '-' + fldname) : valueAtBottom), value: valueAtBottom
	});
	return picklisValues;
}

export function validateOpportunityId(errorMessage, activityList) {
	//Throws error messages for proposals with invalid opportunity IDs				
	let errData = errorMessage.replace("Exception: ", "");
	var oppIdErrorArr = (errData != null) ? JSON.parse(errData) : []; //{006Dz00000NnnBtIAM: 'Please enter a valid Opportunity Id.'} 
	var errOppIds = [];
	if (oppIdErrorArr) {
		for (let oppId in oppIdErrorArr) {
			errOppIds.push(oppId);
		}
		var actList = [];
		actList = JSON.parse(JSON.stringify(activityList));
		actList.forEach(activity => {
			if (activity.ischecked != false) {
				activity.isInvalidOppId = errOppIds.includes(activity.Core_MDF_Opportunity_id__c) ? true : false;
			}
		});
		activityList = JSON.parse(JSON.stringify(actList));
		showErrorToast(reviewErrOnPage_ErrMsg, 'pester');
	}
	return activityList;
}
export function validatePicklistvalues(campaignPicValues, campaignFieldValue, campaignFields, compRef) {
	compRef.campaignFieldValue['Core_MDF_Market__c'] = compRef.countryValue;
	for (let i = 0; i < campaignFields.length; i++) {
		let campaignPicValuesCopy = JSON.parse(JSON.stringify(campaignPicValues));
		if (((campaignFields[i].fieldType === 'PICKLIST' && checkForUndefinedEmptyAndNull(campaignFieldValue[campaignFields[i].fieldAPIName]))
			|| (campaignFields[i].fieldType === 'MULTIPICKLIST' && Array.isArray(campaignFieldValue[campaignFields[i].fieldAPIName])))
			&& checkForUndefinedEmptyAndNull(campaignPicValuesCopy[campaignFields[i].fieldAPIName])) {
			let oldValuesSelected = JSON.parse(JSON.stringify(campaignFieldValue[campaignFields[i].fieldAPIName]));
			let tempOptionsNewValues = campaignPicValuesCopy[campaignFields[i].fieldAPIName].map(a => a.value);
			let ParPickField = [];
			if ((typeof oldValuesSelected == 'string') || (oldValuesSelected.length == 0 && campaignFields[i].fieldType === 'PICKLIST')) {
				if (oldValuesSelected == []) {
					ParPickField = "";
				} else {
					if (tempOptionsNewValues.includes(oldValuesSelected)) {
						ParPickField = oldValuesSelected;
					} else {
						ParPickField = "";
					}

				}
			} else {
				oldValuesSelected.forEach(item => {
					if (tempOptionsNewValues.includes(item)) {
						ParPickField.push(item);
					}
				})
			}
			if (campaignFields[i].fieldAPIName == 'Core_MDF_Market__c') {
				compRef.countryValue = ParPickField;
			} else {
				campaignFieldValue[campaignFields[i].fieldAPIName] = ParPickField;
			}
		}
	}
	return campaignFieldValue;
}

export function handleServerExceptionsName(error, applicationErrorMsg) {
	let exceptionerrors = error;
	let errorname = '';
	if (exceptionerrors != null && exceptionerrors.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 1);
		var err = '';
		if (splittedMessage != null) {
			if (splittedMessage != null) {
				if (splittedMessage.includes(picklistValueRemovalErrorOnEdit)) {
					let completeError = splittedMessage.substring(splittedMessage.indexOf(',') + 1, splittedMessage.lastIndexOf("#"));
					errorname = completeError;
				} else {
					err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
					if (err != '' && err != null) {
						errorname = err.substring(err.indexOf(',') + 1);
					}
				}
			}
		}
	} else if (exceptionerrors != null && exceptionerrors.includes('FIELD_INTEGRITY_EXCEPTION')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('FIELD_INTEGRITY_EXCEPTION,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
			if (err != '' && err != null) {
				errorname = err.substring(err.lastIndexOf(',') + 1);
			}
		}
	} else if (exceptionerrors != null && exceptionerrors.includes('ENTITY_IS_LOCKED')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('ENTITY_IS_LOCKED,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
			if (err != '' && err != null) {
				errorname = err.substring(err.indexOf(',') + 1);
			}
		}
	} else if (exceptionerrors != null && exceptionerrors.includes('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.indexOf(":"));
			if (err != '' && err != null) {
				errorname = err.substring(err.lastIndexOf(',') + 1);
			}
		}
	} else if (exceptionerrors != null && exceptionerrors.includes('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.lastIndexOf("]") + 1);
			if (err != '' && err != null) {
				errorname = err.substring(err.lastIndexOf(',') + 1);
			}
		}
	} else if (exceptionerrors != null && exceptionerrors.includes('INVALID_TYPE_ON_FIELD_IN_RECORD')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('INVALID_TYPE_ON_FIELD_IN_RECORD,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.lastIndexOf("]") + 1);
			if (err != '' && err != null) {
				errorname = err.substring(err.lastIndexOf(',') + 1);
			}
		}
	} else if (exceptionerrors.includes('INSUFFICIENT_ACCESS_OR_READONLY')) {
		const splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('INSUFFICIENT_ACCESS_OR_READONLY,') + 1);
		let err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(0, splittedMessage.lastIndexOf(']') + 1);
			if (err != null && err !== '') {
				errorname = err.substring(err.lastIndexOf(',') + 1);
			}
		}
	} else if (exceptionerrors.includes('Exception')) {
		var splittedMessage = exceptionerrors.substring(exceptionerrors.lastIndexOf('Exception,') + 1);
		var err = '';
		if (splittedMessage != null) {
			err = splittedMessage.substring(splittedMessage.lastIndexOf(":") + 1);
			if (err != '' && err != null) {
				errorname = err;
			}
		}
	} else {
		errorname = applicationErrorMsg;
	}

	return errorname;
}

export function budgetDataWrapperMDF(res, isActive, disable, rrOptions, budgetNameString, recordTypeDevName) {
	let obj;
	if (recordTypeDevName == Core_MDF_EEF_RecordType) {
		obj = {
			campaignBudgetId: res.Id,
			budgetId: res.Core_MDF_Budget_Name_Id__c,
			isActive: isActive,
			disable: disable,
			budgetName: budgetNameString,
			budgetAmount: '0',
			budgetRR: '0%',
			budgetRAmount: '0',
			options: rrOptions
		}
	}
	else {
		obj = {
			campaignBudgetId: res.Id,
			budgetId: res.Core_MDF_Budget_Name_Id__c,
			isActive: isActive,
			disable: disable,
			budgetName: budgetNameString,
			budgetAmount: res.Core_MDF_Budget_Amt__c,
			budgetRR: res.Core_MDF_Reimbursement_Rate_Pct__c,
			budgetRAmount: res.Core_MDF_Reimbursement_Amt__c,
			options: rrOptions,
			budgetType: res.Core_MDF_Budget_Type_Nm__c
		}
	}
	return obj;
}

export function budgetDataWrapper(childOrRes, res, rrOptions, recordTypeDevName) {
	let obj;
	if (recordTypeDevName == Core_MDF_EEF_RecordType) {
		obj = {
			budgetId: childOrRes ? res.value : res.budgetId,
			budgetName: childOrRes ? res.label : res.budgetName,
			budgetAmount: 0,
			budgetRR: '0%',
			budgetRAmount: 0,
			options: rrOptions
		}
	} else if (recordTypeDevName == Core_MDF_Co_GTM_RecordType) {
		obj = {
			budgetId: childOrRes ? res.value : res.budgetId,
			budgetName: childOrRes ? res.label : res.budgetName,
			budgetAmount: 0,
			budgetRR: '0%',
			budgetRAmount: 0,
		}
	}
	else {
		obj = {
			budgetId: childOrRes ? res.value : res.budgetId,
			budgetName: childOrRes ? res.label : res.budgetName,
			budgetAmount: childOrRes ? '' : res.budgetAmount,
			budgetRR: childOrRes ? '50%' : res.budgetRR,
			budgetRAmount: childOrRes ? '' : res.budgetRAmount,
			options: rrOptions,
			budgetType: res.budgetType
		}
	}
	return obj;
}

export function localizeCountrymap(countryVal) {
	let countrymap = new Map();
	for (let i = 0; i < countryVal.length; i++) {
		countrymap.set(countryVal[i].value, countryVal[i].label)
	}

	return countrymap;
}

export function checkSelPicValHelper(selectedActCatTypePicValues, finalDependentVal) {
	let allValues = finalDependentVal;
	if (allValues != null && allValues != undefined) {
		let index = 0;
		let arrLength = allValues.length;
		let missingValues = [];
		var allValueArray = [];
		for (index = 0; index < arrLength; index++) {
			allValueArray = [...allValueArray, allValues[index].value];
		}
		for (let index2 = 0; index2 < selectedActCatTypePicValues.length; index2++) {
			if (!allValueArray.includes(selectedActCatTypePicValues[index2])) {
				let obj = {
					label: selectedActCatTypePicValues[index2],
					value: selectedActCatTypePicValues[index2]
				};
				missingValues = [...missingValues, obj];
			}
		}
		if (this.mode == 'clone' || this.mode == 'edit') {
			let newValues = [];
			var missingValuesArr = [];
			for (let index2 = 0; index2 < missingValues.length; index2++) {
				if (!missingValuesArr.includes(missingValues[index2].value)) {
					missingValuesArr = [...missingValuesArr, missingValues[index2].value];
				}
			}
			if (missingValuesArr != null && missingValuesArr != undefined && missingValuesArr != '' && selectedActCatTypePicValues != undefined && selectedActCatTypePicValues != null && selectedActCatTypePicValues != '') {
				for (let index = 0; index < selectedActCatTypePicValues.length; index++) {
					if (!missingValuesArr.includes(selectedActCatTypePicValues[index])) {
						if (!newValues.includes(selectedActCatTypePicValues[index])) {
							newValues = [...newValues, selectedActCatTypePicValues[index]];
						}
					}
				}
				if (newValues != undefined && newValues != null && newValues.length > 0) {
					selectedActCatTypePicValues = newValues;
				}
			}
		}
	}
	return selectedActCatTypePicValues
}

export function campFieldAPINametoPFRFieldAPIName(recordTypeDevelperName) {
	let obj;
	if (recordTypeDevelperName == Core_MDF_IPA_RecordType) {
		obj = {
			'Core_MDF_Audience__c': 'Core_MDF_TargetAudience_nm__c',
			'Core_MDF_Market__c': 'Core_MDF_Country_nm__c',
			'Core_MDF_IPA_Priority_nm__c': 'Core_MDF_Priority_nm__c',
			'Core_MDF_Industry_Nm__c': 'Core_MDF_Industry_Multi_nm__c',
			'Core_MDF_Initiative_nm__c': 'Core_MDF_Initiative_nm__c',
			'Core_MDF_Focus_Area_nm__c': 'Core_MDF_Focus_Area_nm__c',
			'Core_MDF_Brand__c': 'Core_MDF_Brand_nm__c',
			'Core_MDF_Product_Type__c': 'Core_MDF_ProductType__c',
			'Core_MDF_Ecosystem_Partner_Nm__c': 'Core_MDF_EcosystemPartner_nm__c',
			'Core_MDF_Opal_Budget_Type_Txt__c': 'Core_MDF_Budget_Type_nm__c'
		}
	}
	else if (recordTypeDevelperName == 'Core_MDF_Client_CoMarketing_Fund' || recordTypeDevelperName == 'Core_MDF_Data_Center_CoMarketing_Fund') {
		obj = {
			'Core_MDF_Priority__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_2_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_3_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Market__c': 'Core_MDF_Country_nm__c',
			'Core_MDF_Audience__c': 'Core_MDF_TargetAudience__c',
			'Core_MDF_Product_Type__c': 'Core_MDF_ProductType__c',
			'Core_MDF_Brand__c': 'Core_MDF_Brand_nm__c',
			'Core_MDF_Industry_Nm__c': 'Core_MDF_Industry_Multi_nm__c',
			'Core_MDF_Activity_Category_Type__c': 'Activity_Category_Type',
			'Core_MDF_Opal_Budget_Type_Txt__c': 'Core_MDF_Budget_Type_nm__c'
		}
	} else if (recordTypeDevelperName == Core_MDF_EEF_RecordType) {
		obj = {
			'Core_MDF_Priority__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_2_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_3_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Market__c': 'Core_MDF_Country_nm__c',
			'Core_MDF_Audience__c': 'Core_MDF_TargetAudience__c',
			'Core_MDF_Product_Type__c': 'Core_MDF_ProductType__c',
			'Core_MDF_Brand__c': 'Core_MDF_Brand_nm__c',
			'Core_MDF_Industry_Nm__c': 'Core_MDF_Industry_Multi_nm__c',
			'Core_MDF_Activity_Category_Type__c': 'Activity_Category_Type',
			'Core_MDF_Partner_Mapping_Txt__c': 'ChannelPartnerId',
			'availableBudgetValues': 'BudgetId',
			'Core_MDF_Opal_Budget_Type_Txt__c': 'Core_MDF_Budget_Type_nm__c'
		}
	} else if (recordTypeDevelperName == Core_MDF_Co_GTM_RecordType) {
		obj = {
			'availableBudgetValues': 'BudgetId',
		}
	}
	else {
		obj = {
			'Core_MDF_Priority__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_2_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Priority_3_nm__c': 'Core_MDF_Priorities__c',
			'Core_MDF_Audience__c': 'Core_MDF_TargetAudience__c',
			'Core_MDF_Product_Type__c': 'Core_MDF_ProductType__c',
			'Core_MDF_Brand__c': 'Core_MDF_Brand_nm__c',
			'Core_MDF_Initiative_nm__c': 'Core_MDF_Initiative_nm__c',
			'Core_MDF_Budget_Type_txt__c': 'Core_MDF_Budget_Type_nm__c'
		}
	}

	return obj;
}

export function validatePickListValuesBasedOnFC(selectedPickValue, selectedFocusArea, campFieldAPIName, focusAreadependentPicklists, availableFocusArea) {
	let availableFocusAreaArray = availableFocusArea;
	let selectedPickListValues = selectedPickValue;
	let selectedFocusAreaArray = selectedFocusArea;
	let hasNoOnevalueSelectedFromEachFC = false;
	let selectedPicklistValueBasedOnFC = [];
	let noSingleValueSelectedFocusAreas = [];
	let focusAreaDependentErrorWrapper = {};
	if (selectedFocusAreaArray.length > 1) {
		selectedFocusAreaArray.map(fc => {
			let allPickListValuesBasedOnFC = focusAreadependentPicklists.filter(focusArea => Object.keys(focusArea) == fc).map(focusArea => focusArea[fc]);
			let dependentValueArray = allPickListValuesBasedOnFC[0];
			let dependentPickListValues = dependentValueArray[campFieldAPIName];
			if (checkForUndefinedEmptyAndNull(dependentPickListValues) && dependentPickListValues.length > 0) {
				selectedPickListValues && selectedPickListValues.map(selectedPickval => { //: Commercial​ - Large enterprise, Consumer - Mainstream/Essential"
					if (dependentPickListValues.includes(selectedPickval)) {
						let index = selectedPicklistValueBasedOnFC.findIndex(ele => Object.keys(ele) == fc);
						if (index == -1) {
							let obj = {};
							obj[fc] = [selectedPickval];
							selectedPicklistValueBasedOnFC.push(obj);
						} else {
							selectedPicklistValueBasedOnFC[index][fc].push(selectedPickval);
						}//{client computing : [1, 2]}
					}
				});
			}
		});
		if (selectedPicklistValueBasedOnFC.length != selectedFocusAreaArray.length) {
			selectedFocusAreaArray.map(fc => {
				let fcValue;
				let index = selectedPicklistValueBasedOnFC.findIndex(selectedPickval => Object.keys(selectedPickval) == fc);
				if (index == -1) {
					if (checkForUndefinedEmptyAndNull(availableFocusAreaArray) && Array.isArray(availableFocusAreaArray)
						&& availableFocusAreaArray.length > 0) {
						fcValue = availableFocusAreaArray.find(opt => opt.value == fc);
					}
					fcValue = (checkForUndefinedEmptyAndNull(fcValue) && Object.keys(fcValue).length > 0) ? fcValue.label : fc;
					noSingleValueSelectedFocusAreas.push(fcValue);
				}
			});
			hasNoOnevalueSelectedFromEachFC = true;
		} else {
			hasNoOnevalueSelectedFromEachFC = false;
		}
	}
	focusAreaDependentErrorWrapper.hasNoOnevalueSelectedFromEachFC = hasNoOnevalueSelectedFromEachFC;
	focusAreaDependentErrorWrapper.noSingleValueSelectedFocusAreas = noSingleValueSelectedFocusAreas;
	return focusAreaDependentErrorWrapper;

}
export function checkForUndefinedEmptyAndNull(input) {
	if (input !== undefined && input !== null && input !== "") {
		return true;
	} else {
		return false;
	}

}
function showErrorToast(errorMessage, mode) {
	const evt = new ShowToastEvent({ title: 'Error!', message: errorMessage, variant: 'error', mode: mode });
	dispatchEvent(evt);
}
export function checkActivityEventValidation(activityElement) {
	const activityCategories = Core_MDF_EVENT_CATEGORY.split(';').map(val => val.trim());
	var isValidation = false; let todaysDate = new Date(); todaysDate.setMinutes(new Date().getMinutes() - new Date().getTimezoneOffset());
	let todaysDatewithLocale = todaysDate.toISOString().slice(0, 10); var actStartDate = activityElement.Core_MDF_Start_Date__c; var daysDifference = (Date.parse(actStartDate) - Date.parse(todaysDatewithLocale)) / (3600 * 24 * 1000);
	if (activityCategories.includes(activityElement.Core_MDF_ActivityCategory__c) && activityElement.Core_MDF_Activity_Reimbursement_Amt_nbr__c >= this.amount50K && daysDifference < this.threshold60Days) {
		isValidation = true;
	} return isValidation;
}

export function checkActivityInitiativeValidation(activityElement) {
	var isValidation = false; var splitActivityInitiative = [];
	if (activityElement.Core_MDF_Initiative_nm__c !== undefined && activityElement.Core_MDF_Initiative_nm__c !== null && activityElement.Core_MDF_Initiative_nm__c !== '') {
		splitActivityInitiative = activityElement.Core_MDF_Initiative_nm__c.split(';');
		if (splitActivityInitiative !== undefined && splitActivityInitiative !== null && splitActivityInitiative !== '') {
			if (splitActivityInitiative.includes('None') && splitActivityInitiative.length > 1) { isValidation = true; }
		}
	}
	return isValidation;
}

export function callingGeoToCountryMappingValue(selectedRegions, tempCountrySelected, ConnectedCallbackGeoCountryValue, compRef) {
	let geoToCountryMappingWrapper = {};
	let connectedCallbackcusts = [];
	let geoMapping = [];
	let allCountriesRelatedToSelectedRegions = [];
	let validCountriesValues = [];
	if (selectedRegions != undefined && selectedRegions != null && selectedRegions != '') {
		validCountriesValues = compRef.validCountriesFromCPObject.map(country => country.value);
		for (let index = 0; index < selectedRegions.length; index++) {
			allCountriesRelatedToSelectedRegions = allCountriesRelatedToSelectedRegions.concat(ConnectedCallbackGeoCountryValue.get(selectedRegions[index]));
		}
		for (let index = 0; index < allCountriesRelatedToSelectedRegions.length; index++) {
			if (validCountriesValues.includes(allCountriesRelatedToSelectedRegions[index])) {
				geoMapping.push(allCountriesRelatedToSelectedRegions[index]);
			}
		}
		if (tempCountrySelected != undefined && tempCountrySelected != null && tempCountrySelected != '') {
			for (let k = 0; k < tempCountrySelected.length; k++) {
				if (!geoMapping.includes(tempCountrySelected[k]) && validCountriesValues.includes(tempCountrySelected[k])) {
					geoMapping.push(tempCountrySelected[k]);
				}
			}
		}
		for (let z = 0; z < geoMapping.length; z++) {
			connectedCallbackcusts.push({
				label: (compRef.picklistApitoLabelReferenceMap.get(geoMapping[z] + '-' + "Core_MDF_Market__c") != undefined ? compRef.picklistApitoLabelReferenceMap.get(geoMapping[z] + '-' + "Core_MDF_Market__c") : geoMapping[z]),
				value: geoMapping[z]
			});
		}
		geoToCountryMappingWrapper.Core_MDF_Market__c = connectedCallbackcusts;
		geoToCountryMappingWrapper.countryPicklist = connectedCallbackcusts;
	}
	return geoToCountryMappingWrapper;
}

export function lovValueAdditionforEEF(campaignPickValues, campaignFieldValue, actPartOptions) {
	let campaignFieldSelectedValues = JSON.parse(JSON.stringify(campaignFieldValue));
	let campaignPicOptions = JSON.parse(JSON.stringify(campaignPickValues));
	let selectedValuesOnCampaignRecord = campaignFieldSelectedValues;
	//if (checkForUndefinedEmptyAndNull(selectedValuesOnCampaignRecord) && selectedValuesOnCampaignRecord !== []) {
	if (checkForUndefinedEmptyAndNull(selectedValuesOnCampaignRecord) && selectedValuesOnCampaignRecord.length > 0) {
		for (let j = 0; j < selectedValuesOnCampaignRecord.length; j++) {
			let plVal = selectedValuesOnCampaignRecord[j];
			let campaignPicValuesIndex = campaignPickValues.findIndex(pl => pl.value == plVal);
			if (campaignPicValuesIndex == -1) {
				if (checkForUndefinedEmptyAndNull(actPartOptions) && actPartOptions.length > 0) {
					const labelval = actPartOptions.find(act => act.value == plVal).label;
					campaignPicOptions.push({
						class: "optionClass", label: labelval, value: plVal
					});
				}
			}
		}
	}
	return campaignPicOptions;
}

export function lovValuesAddition(campaignPicValues, campaignFieldValue, recordType, picklistApitoLabelReferenceMap, compRef, context) {
	let pickListFields = [];
	let fieldsBasedOnProgram = ['Core_MDF_Opal_Budget_Type_Txt__c', 'Core_MDF_Budget_Type_txt__c', 'Core_MDF_Focus_Area_nm__c', 'Core_MDF_Market__c'];
	let singleSelectPickListFields = ['Core_MDF_Priority__c', 'Core_MDF_Priority_2_nm__c', 'Core_MDF_Priority_3_nm__c'];
	pickListFields = (checkForUndefinedEmptyAndNull(context) && context == "geoChange") ? ['Core_MDF_Market__c'] : (checkForUndefinedEmptyAndNull(context) && context == 'fieldsBasedOnProgram') ? fieldsBasedOnProgram : (checkForUndefinedEmptyAndNull(context) && context == 'activityCategoryType') ? ['Core_MDF_Activity_Category_Type__c'] : getRecordTypeDependentFields(recordType);
	let campaignPicOptions = JSON.parse(JSON.stringify(campaignPicValues));
	let campaignFieldSelectedValues = JSON.parse(JSON.stringify(campaignFieldValue));
	for (let i = 0; i < pickListFields.length; i++) {
		let fldname = pickListFields[i];
		let selectedValuesOnCampaignRecord = [];
		let selectedOldValuesOnCamp = [];
		//if (checkForUndefinedEmptyAndNull(campaignFieldSelectedValues[fldname]) && campaignFieldSelectedValues[fldname] !== []) {
		if (checkForUndefinedEmptyAndNull(campaignFieldSelectedValues[fldname]) && campaignFieldSelectedValues[fldname].length > 0) {
			selectedValuesOnCampaignRecord = getSelectedValuesOnCampaign(campaignFieldSelectedValues[fldname]);
			//if (fieldsBasedOnProgram.includes(fldname) && checkForUndefinedEmptyAndNull(compRef.campaignRecord[fldname]) && compRef.campaignRecord[fldname] !== []) {
			if ((fieldsBasedOnProgram.includes(fldname) || singleSelectPickListFields.includes(fldname)) && checkForUndefinedEmptyAndNull(compRef.campaignRecord[fldname]) && compRef.campaignRecord[fldname].length > 0) {
				selectedOldValuesOnCamp = getSelectedValuesOnCampaign(compRef.campaignRecord[fldname]);
				selectedOldValuesOnCamp.forEach(oldVal => {
					if (!selectedValuesOnCampaignRecord.includes(oldVal)) {
						selectedValuesOnCampaignRecord.push(oldVal);
					}
				});
			}

			for (let j = 0; j < selectedValuesOnCampaignRecord.length; j++) {
				let plVal = selectedValuesOnCampaignRecord[j];
				let campaignPicValuesIndex = campaignPicValues[fldname].findIndex(pl => pl.value == plVal);
				if (campaignPicValuesIndex == -1) {
					campaignPicOptions[fldname].push({
						class: "optionClass", label: picklistApitoLabelReferenceMap.get(plVal + '-' + fldname) != undefined ? picklistApitoLabelReferenceMap.get(plVal + '-' + fldname) : plVal, value: plVal
					});
				}
			}
		}
	}

	return campaignPicOptions;
}

function getSelectedValuesOnCampaign(selValues) {
	let selectedValuesOnCampaignRecord = [];
	if (typeof selValues == 'string') {
		selectedValuesOnCampaignRecord = selValues.split(';');
	} else {
		selectedValuesOnCampaignRecord = selValues;
	}
	return selectedValuesOnCampaignRecord;
}

export function getBudgetNameString(budgetTitle, budgetType, startDate, endDate, budgetRefNumber) {

	if (checkForUndefinedEmptyAndNull(startDate) && checkForUndefinedEmptyAndNull(endDate)) {
		startDate = startDate.replaceAll('-', '/');
		endDate = endDate.replaceAll('-', '/');
	}
	return budgetRefNumber + ': ' + budgetTitle + ': ' + budgetType + ': ' + startDate + ' - ' + endDate;
}

export function getObjectFieldDetails(compRef) {
	if (compRef.campaignFields != undefined && compRef.campaignFields != null) {
		compRef.campaignFieldValue['RecordTypeId'] = compRef.recordTypeId;

		if (compRef.mode == 'edit') {
			outcomeList.forEach(field => {
				compRef.campaignFieldDisabled[field] = true;
			});
		}
		for (let i = 0; i < compRef.campaignFields.length; i++) {
			let fieldAPIName = compRef.campaignFields[i].fieldAPIName;
			if (fieldAPIName == 'StartDate__c' || fieldAPIName == 'EndDate__c' || fieldAPIName == 'Name__c' || fieldAPIName == 'Description__c') {
				fieldAPIName = fieldAPIName.replace('__c', '');
			}
			if (fieldAPIName != 'Core_MDF_Other_Ecosystem_Partner_txt__c' && fieldAPIName != 'Core_MDF_CampOutcomeOpt_In_Ind__c' && fieldAPIName != 'Core_MDF_Outcomes_nm__c' && fieldAPIName != 'Core_MDF_Other_Outcome_txt__c' && fieldAPIName != 'Core_MDF_Other_Measurement_Approach_txt__c') {
				compRef.campaignRequiredFields[fieldAPIName] = compRef.campaignFields[i].isRequired; compRef.campaignFieldVisibility[fieldAPIName] = true; compRef.campaignFieldDisabled[fieldAPIName] = false;
			}
			compRef.campaignFieldLabel[fieldAPIName] = compRef.campaignFields[i].fieldLabel; compRef.campaignFieldHelpText[fieldAPIName] = compRef.campaignFields[i].helpText;
			//aditya
			compRef.campaignFieldVisibility["Core_MDF_MyDeals_txt__c"] = compRef.isCommunity ? false : true;
			// if(compRef.isCommunity){
			// 	compRef.campaignFieldVisibility["Core_MDF_MyDeals_txt__c"] = false;
			// 	compRef.campaignFieldVisibility["Core_MDF_MyDeals_txt__c"] = compRef.isCommunity? false: true;
			// }
			// if(fieldAPIName == 'Core_MDF_Outcomes_nm__c'){
			// 	compRef.campaignRequiredFields[fieldAPIName] = compRef.campaignFields[i].isRequired;
			// }
			if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && (compRef.mode == 'edit' || compRef.mode == 'clone')) {
				if (compRef.mode == 'edit') {

					/*compRef.fieldEditibilityList.forEach(field => {
						if (field.startsWith(outcomePrefix)) {
							const outcomeFieldName = field.split('.')[1];
							compRef.campaignFieldDisabled[outcomeFieldName] = false;
						}
					});*/

					const editableFields = Array.isArray(compRef.fieldEditibilityList) ? compRef.fieldEditibilityList : [];
					editableFields.forEach(field => {
						if (field.startsWith(outcomePrefix)) {
							const outcomeFieldName = field.split('.')[1];
							compRef.campaignFieldDisabled[outcomeFieldName] = false;
						}
					});

					if (editableFields.includes(fieldAPIName)) {
						compRef.campaignFieldDisabled[fieldAPIName] = false;
					} else { compRef.campaignFieldDisabled[fieldAPIName] = true; }
				}
				if (compRef.campaignRecord[fieldAPIName] != null && compRef.campaignRecord[fieldAPIName] != undefined) {
					compRef.campaignFieldValue[fieldAPIName] = compRef.campaignRecord[fieldAPIName];
				} else { compRef.campaignFieldValue[fieldAPIName] = ''; }
			} else {
				compRef.campaignFieldValue[fieldAPIName] = '';
			}
			if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) && (compRef.mode == 'edit' || compRef.mode == 'clone')) {
				//clone/edit - set empty string for Reimbursement amount's help text - applicable for IPA proposal based
				if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.campaignFieldValue['Core_MDF_Proposal_Based_Ind__c'] && fieldAPIName == 'Core_MDF_Reimbursement_Amt__c') {
					compRef.campaignFieldHelpText[fieldAPIName] = '';
				}							
				const editableFields = Array.isArray(compRef.fieldEditibilityList) ? compRef.fieldEditibilityList : [];
				if ((compRef.isL2Approver || (compRef.status == 'Pending Review' && compRef.isL1Approver) || compRef.status != 'Pending Review') && editableFields.includes('Core_MDF_Proposal_Score_nbr__c')) {
					compRef.campaignFieldDisabled["Core_MDF_Proposal_Score_nbr__c"] = false;
				}
				else {
					compRef.campaignFieldDisabled["Core_MDF_Proposal_Score_nbr__c"] = true;
				}
				if (checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) {
					if (fieldAPIName == 'Core_MDF_ReimbursementRate_pct__c') {
						compRef.finalRRrate = compRef.campaignFieldValue[fieldAPIName]; compRef.initialRRValue = compRef.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"];
					} compRef.initialRRValue = '50%';
				}
				if (editableFields.includes('Core_MDF_Campaign_Scoring_txt__c')) {
					compRef.campaignFieldVisibility['Core_MDF_Campaign_Scoring_txt__c'] = true;
				} else { compRef.campaignFieldVisibility['Core_MDF_Campaign_Scoring_txt__c'] = false; }
			}
			if (compRef.campaignFields[i].fieldType == 'PICKLIST' || compRef.campaignFields[i].fieldType == 'MULTIPICKLIST') {
				if (compRef.picValuesByRecType !== undefined && compRef.picValuesByRecType !== null) {
					let tempOptions = []; let temp2Options = compRef.picValuesByRecType.picklistFieldValues[fieldAPIName].values;
					console.log('@@fieldAPIName:', fieldAPIName);
					console.log('@@temp2Options++', temp2Options);

					temp2Options.forEach(opt => tempOptions.push(opt));
					console.log('@@tempOptions++', tempOptions);
					if (fieldAPIName == 'Core_MDF_Region_cd__c') {
						if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
							tempOptions = [{ label: '', value: '', selected: true }, ...tempOptions];
						}
						compRef.campaignPicValues[fieldAPIName] = tempOptions;
					}
					if (fieldAPIName == 'Core_MDF_Market__c') { compRef.campaignPicValues[fieldAPIName] = tempOptions; }
					if (fieldAPIName == 'Core_MDF_Program__c') { compRef.campaignPicValues[fieldAPIName] = tempOptions; }
					if (compRef.recordTypeDeveloperName != Core_MDF_IPA_RecordType) {
						if (fieldAPIName == 'Core_MDF_Opal_Budget_Type_Txt__c') {
							let nonLegacyBudgetTypes = [];
							for (let i = 0; i < tempOptions.length; i++) {
								if (!Core_MDF_LegacyRestricBudgetTypes.includes(tempOptions[i].label)) { nonLegacyBudgetTypes.push(tempOptions[i]); }
							} compRef.campaignPicValues[fieldAPIName] = nonLegacyBudgetTypes;
						}
						else {
							compRef.campaignPicValues[fieldAPIName] = tempOptions;
						}
					}
					if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && (compRef.mode == 'edit' || compRef.mode == 'clone')) {
						let selectedPicValues = compRef.campaignRecord[fieldAPIName];
						if (selectedPicValues != undefined && selectedPicValues != null && selectedPicValues != '') {
							selectedPicValues = selectedPicValues.split(';');
							let allValues = compRef.campaignPicValues[fieldAPIName];
							if (allValues != null && allValues != undefined) {
								let index = 0; let arrLength = allValues.length; let missingValues = []; var allValueArray = [];
								for (index = 0; index < arrLength; index++) {
									allValueArray = [...allValueArray, allValues[index].value];
								}
								for (let index2 = 0; index2 < selectedPicValues.length; index2++) {
									if (!allValueArray.includes(selectedPicValues[index2])) {
										let obj = {
											label: selectedPicValues[index2],
											value: selectedPicValues[index2]
										};
										missingValues = [...missingValues, obj];
									}
								}
								if (compRef.mode == 'edit' && compRef.recordTypeDeveloperName != Core_MDF_IPA_RecordType) {
									var missingValuesArr = [];
									for (index = 0; index < missingValues.length; index++) {
										if (!missingValuesArr.includes(missingValues[index].value)) {
											allValues = [...allValues, missingValues[index]];
											missingValuesArr = [...missingValuesArr, missingValues[index].value];
										}
									}
									compRef.campaignPicValues[fieldAPIName] = allValues;
								}
								if (compRef.mode == 'clone') {
									let newValues = [];
									var missingValuesArr = [];
									for (let index2 = 0; index2 < missingValues.length; index2++) {
										if (!missingValuesArr.includes(missingValues[index2].value)) {
											missingValuesArr = [...missingValuesArr, missingValues[index2].value];
										}
									}
									if (missingValuesArr != null && missingValuesArr != undefined && missingValuesArr != '' && selectedPicValues != undefined && selectedPicValues != null && selectedPicValues != '') {
										for (let index = 0; index < selectedPicValues.length; index++) {
											if (!missingValuesArr.includes(selectedPicValues[index])) {
												if (!newValues.includes(selectedPicValues[index])) {
													newValues = [...newValues, selectedPicValues[index]];
												}
											}
										}
										if (newValues != undefined && newValues != null && newValues.length > 0) {
											selectedPicValues = newValues;
										} else {
											selectedPicValues = [];
											compRef.campaignFieldValue[fieldAPIName] = [];
										}
									}
								}
								if ((compRef.mode == 'edit' || compRef.mode == 'clone') && fieldAPIName == 'Core_MDF_Reimbursement_Rate__c' &&
									(compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && (checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"])) && compRef.customRRValues != undefined) {
									compRef.customRRValues = compRef.campaignPicValues["Core_MDF_Reimbursement_Rate__c"];
								}
								if (compRef.recordTypeDeveloperName === Core_MDF_EEF_RecordType) {
									compRef.finalRRrate = '100%';
								}
							}
						}
						if (selectedPicValues != undefined && selectedPicValues != null && selectedPicValues != '') {
							if (fieldAPIName == 'Core_MDF_Market__c' && compRef.recordTypeDeveloperName !== rmfRecTypeName && compRef.recordTypeDeveloperName !== Core_MDF_Co_GTM_RecordType) {
								compRef.countryValue = selectedPicValues;
								compRef.tempCountrySelected = selectedPicValues;
								compRef.program = compRef.program == undefined ? compRef.campaignFieldValue["Core_MDF_Program__c"] : compRef.program;
							}
							else if (fieldAPIName == 'Core_MDF_Region_cd__c') {
								if (compRef.recordTypeDeveloperName === 'Core_MDF_Retail_Marketing_Funds') { compRef.campaignFieldValue[fieldAPIName] = selectedPicValues; }
								if (compRef.recordTypeDeveloperName != rmfRecTypeName) {
									compRef.showCountryoOnBasisOfGeo(null, 'initialLoad');
								}
							}

							else if (fieldAPIName == 'Core_MDF_Reimbursement_Rate__c' || fieldAPIName == 'Core_MDF_Program__c' || fieldAPIName == 'Core_MDF_Priority__c' || fieldAPIName == 'Core_MDF_Priority_2_nm__c' || fieldAPIName == 'Core_MDF_Priority_3_nm__c' || fieldAPIName == 'Core_MDF_Integrated_Campaign__c' ||
								fieldAPIName == 'Core_MDF_Supports_legacy_program__c' || fieldAPIName == 'Core_MDF_Market_Segment_nm__c' || fieldAPIName == 'Core_MDF_Reason_for_Back_Dating_Nm__c') {
								if (compRef.campaignRecord[fieldAPIName] != null && compRef.campaignRecord[fieldAPIName] != undefined && selectedPicValues != '') {
									compRef.campaignFieldValue[fieldAPIName] = compRef.campaignRecord[fieldAPIName];
								}
								else {
									compRef.campaignFieldValue[fieldAPIName] = '';
								}
							} else if ((fieldAPIName == 'Core_MDF_Opal_Budget_Type_Txt__c' || fieldAPIName == 'Core_MDF_Budget_Type_txt__c') && (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType || compRef.recordTypeDeveloperName === rmfRecTypeName)) {
								compRef.storeBudgetType = compRef.campaignFieldValue[fieldAPIName];
								if (compRef.campaignRecord[fieldAPIName] != null && compRef.campaignRecord[fieldAPIName] != undefined && selectedPicValues != '') {
									compRef.campaignFieldValue[fieldAPIName] = compRef.campaignRecord[fieldAPIName];
								} else {
									compRef.campaignFieldValue[fieldAPIName] = '';
								}
							} else {
								compRef.campaignFieldValue[fieldAPIName] = selectedPicValues;

							}
							if ((compRef.mode == 'edit') && (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType)
								&& (fieldAPIName == 'Core_MDF_Proposal_Score_nbr__c')) {
								if (compRef.campaignRecord[fieldAPIName] != null && compRef.campaignRecord[fieldAPIName] != undefined && selectedPicValues != '') {
									compRef.campaignFieldValue[fieldAPIName] = compRef.campaignRecord[fieldAPIName];
								} else {
									compRef.campaignFieldValue[fieldAPIName] = '';
								}
							}
							if (compRef.campaignFieldValue["Core_MDF_Program__c"] == 'Intel Partner Alliance' && fieldAPIName == 'Core_MDF_Ecosystem_Partner_Nm__c') {
								compRef.othersMandate(fieldAPIName, compRef.campaignFieldValue[fieldAPIName]);
							}
							if (fieldAPIName == 'Core_MDF_Measurement_Approach_nm__c') {
								let measurementApproachVal = compRef.campaignFieldValue[fieldAPIName];
								let isOtherMeasurementApproach = checkForUndefinedEmptyAndNull(measurementApproachVal) && measurementApproachVal.includes(Core_MDF_Other_Specify);
								compRef.campaignFieldVisibility["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherMeasurementApproach;
								compRef.campaignRequiredFields["Core_MDF_Other_Measurement_Approach_txt__c"] = isOtherMeasurementApproach;
							}
						}
					}
				}
			}
			if (checkForUndefinedEmptyAndNull(compRef.campaignPicValues) && checkForUndefinedEmptyAndNull(compRef.campaignPicValues.Core_MDF_Market__c)) {
				compRef.countryPicklist = compRef.campaignPicValues.Core_MDF_Market__c;
			}
			if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && compRef.mode == 'edit') {
				compRef.campaignFieldValue["Id"] = compRef.recordId;
				compRef.pageHeaderTxt = compRef.editText + ' ' + compRef.campaignFieldValue["Name"];
			}
		}
		if (compRef.campaignFieldValue["Core_MDF_Priority__c"] === "") {
			compRef.campaignFieldDisabled["Core_MDF_Priority_Percentage__c"] = true;
		}
		if (compRef.campaignFieldValue["Core_MDF_Priority_2_nm__c"] === "") {
			compRef.campaignFieldDisabled["Core_MDF_Priority_Percentage_2__c"] = true;
		}
		if (compRef.campaignFieldValue["Core_MDF_Priority_3_nm__c"] === "") {
			compRef.campaignFieldDisabled["Core_MDF_Priority_Percentage_3__c"] = true;
		}
		if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && (compRef.mode == 'edit' || compRef.mode == 'clone')) {
			if ((checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) || compRef.recordTypeDeveloperName === Core_MDF_EEF_RecordType) { calReimbursementAmt(compRef); }
		}
		if (compRef.isCommunity) {
			compRef.campaignFieldVisibility["Core_MDF_Comments_Internal_Only__c"] = false;
		}
		if (compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType) {
			compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] = 'Cloud';
		}
		if (compRef.mode === 'edit' && (compRef.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName) && compRef.status === 'Draft' && compRef.campaignRecord.Core_MDF_Campaign_Source_nm__c === 'Target Setting') {
			var today = new Date();
			compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] = today.toISOString().split('T')[0];
		}
		if (compRef.recordId == null || compRef.recordId == undefined || compRef.recordId == '') {
			compRef.campaignFieldValue["Core_MDF_Program__c"] = (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) ? Core_MDF_IPA_Program_Name :
				compRef.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName ? Core_MDF_CCF_Program_Name :
					compRef.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName ? Core_MDF_DCF_Program_Name :
						compRef.recordTypeDeveloperName === Core_MDF_EEF_RecordType ? Core_MDF_EEF_Program_Name : compRef.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType ? Core_MDF_Co_GTM_Program_Name : compRef.recordTypeName;
			if (compRef.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName || compRef.recordTypeDeveloperName === Core_MDF_EEF_RecordType) {
				var today = new Date();
				compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] = today.toISOString().split('T')[0];
			}
			if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
				compRef.campaignFieldDisabled["Core_MDF_Opal_Budget_Type_Txt__c"] = true;
				compRef.campaignFieldVisibility["Core_MDF_Focus_Area_nm__c"] = false;
				if (checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) {
					compRef.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"] = '50%'; compRef.initialRRValue = compRef.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"];
					compRef.finalRRrate = compRef.initialRRValue; compRef.customRRValues = compRef.campaignPicValues["Core_MDF_Reimbursement_Rate__c"];
				}
			}
			compRef.campaignFieldValue["Core_MDF_Strategic_Marketing_Fund_Ind__c"] = false;
			if (compRef.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
				compRef.campaignFieldDisabled["Core_MDF_IPA_Co_Engineering_Campaign_ind__c"] = false;
			    compRef.campaignRequiredFields["Core_MDF_IPA_Co_Engineering_Campaign_ind__c"] = false;
				compRef.campaignFieldValue["Core_MDF_IPA_Co_Engineering_Campaign_ind__c"] = false;
			}
		}
		if (compRef.recordId != undefined && compRef.recordId != null && compRef.recordId != '' && (compRef.mode == 'edit' || compRef.mode == 'clone') && compRef.recordTypeDeveloperName != rmfRecTypeName) {
			compRef.setCCFDCFFields(compRef.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']);
		}
		if (compRef.isCommunity) {
			compRef.campaignFieldVisibility["Core_MDF_Campaign_Scoring_txt__c"] = false;
		}
		if (compRef.mode === 'clone' && compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp) {
			if (compRef.activityListClone.length > 0) {
				var pfrLsst = compRef.activityListClone;
				for (let i = 0; i < pfrLsst.length; i++) {
					if (pfrLsst[i].Core_MDF_Activity_Types__c != null && pfrLsst[i].Core_MDF_Activity_Types__c != '' && Core_MDF_SPIF_Activity_Types.includes(pfrLsst[i].Core_MDF_Activity_Types__c)) {
						compRef.showSPIFRestrictError = true;
					}

				} getActivityFields({ fieldSetName: 'Core_MDF_IPA_Clone_Fieldset' })
					.then((result) => {
						if (result) {
							if (compRef.isCommunity) {
								for (let i = 0; i < result.length; i++) {
									let fieldAPIName = result[i].fieldAPIName;
									if (fieldAPIName != 'Core_MDF_Opportunity_id__c' && fieldAPIName != 'Core_MDF_Attribution_Variance_Pos_txt__c' && fieldAPIName != 'Core_MDF_Attribution_Variance_Neg_txt__c') {
										compRef.viewActivityFieldList.push(result[i]);
									}
								}
							} else {
								compRef.viewActivityFieldList = result;
							}
							let selFA = compRef.campaignFieldValue['Core_MDF_Focus_Area_nm__c'];
							if (checkForUndefinedEmptyAndNull(selFA)) {
								compRef.checkIfClone = true;
							}
						}
					})
					.catch((error) => { console.log(error); });
			}
			compRef.clearValuesIfProposalCamp();
		} if (compRef.mode == 'clone') {
			if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp) {
				compRef.clearValuesIfProposalCamp();
			} if (checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) && !compRef.campaignFieldValue["Core_MDF_Proposal_Based_Ind__c"]) {
				compRef.finalRRrate = '50%';
				calReimbursementAmt(compRef);
			} /*if(compRef.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType) {
				compRef.campaignFieldValue['Core_MDF_Total_Campaign_Cost_Amt__c'] = '';
				compRef.campaignFieldValue['Core_MDF_Reason_for_Back_Dating_Nm__c']='';
				compRef.campaignFieldValue['Core_MDF_Other_Reason_Name_txt__c'] = ''
			}*/
		} if (compRef.mode == 'edit') {
			if (compRef.recordTypeDeveloperName === Core_MDF_DCF_RecordTypeName || compRef.recordTypeDeveloperName === Core_MDF_CCF_RecordTypeName) {
				if (compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != undefined && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != null && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != '') {
					var opalList = Core_MDF_OPAL_BudgetTypes.split(';'); if (opalList != undefined && opalList != null && opalList != '') {
						for (let index = 0; index < opalList.length; index++) {
							if (compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"].includes(opalList[index])) {
								compRef.campaignFieldDisabled["Core_MDF_Account__c"] = true; break;
							}
						}
					}
				}
			}
		}
		compRef.campaignFieldDisabled["Core_MDF_Program__c"] = true;
		compRef.showForm = true; 

		//compRef.isLoaded = false;
		//Spinner fix to avoid race condition between fieldEditibilityList and getObjectFieldDetails
		if (compRef.mode !== 'edit' || Array.isArray(compRef.fieldEditibilityList)) { compRef.isLoaded = false; }
		
		compRef.btnDisabled["saveBtn"] = false;
		compRef.campaignPicValues.Core_MDF_Market__c = compRef.countryPicklist;
		let activityRecordList = compRef.activityListEdit; let valuesReferencedOnActivities = new Set();
		let pfrFieldAPIName = 'Core_MDF_Priorities__c';
		activityRecordList && activityRecordList.map(activity => {
			let valuesOnIndividualActivity = activity[pfrFieldAPIName]?.split(';');
			valuesOnIndividualActivity?.map(val => { valuesReferencedOnActivities.add(val); });
		});
		if (valuesReferencedOnActivities.size) {
			valuesReferencedOnActivities.forEach(val => {
				if (compRef.campaignFieldValue['Core_MDF_Priority_2_nm__c'] == val) { compRef.campaignFieldDisabled['Core_MDF_Priority_2_nm__c'] = true; }
				if (compRef.campaignFieldValue['Core_MDF_Priority_3_nm__c'] == val) { compRef.campaignFieldDisabled['Core_MDF_Priority_3_nm__c'] = true; }
			});
		}

	}
}
export function getPFRFieldsDependency(picklistFieldValues, pfrIPALovFields, selectedFocusArea, pfrIPAActCatAndTypeDepFlds) {
	let pfrDependencyBasedOnFocusArea = [];
	let actDependentFields = pfrIPAActCatAndTypeDepFlds.split(',');
	let controllingFieldValues = [];
	controllingFieldValues = JSON.parse(JSON.stringify(selectedFocusArea));
	try {
		//fields dependent on Focus Area
		pfrIPALovFields.split(',').forEach(pfrFld => {//dependent fields from custom label
			if (!actDependentFields.includes(pfrFld)) {
				pfrDependencyBasedOnFocusArea.push(fetchPFRPicklistFields(pfrFld, picklistFieldValues[pfrFld].controllerValues, picklistFieldValues[pfrFld].values, controllingFieldValues));

			}
		});
	} catch (exception) {
		console.log('Error occurred in getPFRFieldsDependency', exception);
	}
	return pfrDependencyBasedOnFocusArea;
}

export function activityCategoryAndTypeMap() {
	let obj = {
		'Core_MDF_ActivityCategory__c': 'Core_MDF_Activity_Types__c',
		'Core_MDF_Activity_Types__c': 'Core_MDF_Event_Name_nm__c,Core_MDF_Activity_SubType_nm__c',
	};
	return obj;
}

export function getPFRActCategoryAndTypeDependency(activityList, picklistFieldValues) {
	let pfrDependencyBasedOnActCatAndType = [];
	const activityCatAndTypeMap = activityCategoryAndTypeMap();
	activityList && activityList.forEach(activity => {
		let actCatAndActTypeDep = [];
		for (const [key, value] of Object.entries(activityCatAndTypeMap)) {
			let dependentFields = value.split(',');
			dependentFields.forEach(depFld => {
				let actCatOrTypeDep = fetchPFRPicklistFields(depFld, picklistFieldValues[depFld].controllerValues, picklistFieldValues[depFld].values, activity[key].split(','));
				if (checkForUndefinedEmptyAndNull(actCatOrTypeDep) && Object.keys(actCatOrTypeDep).length) {
					actCatAndActTypeDep.push(actCatOrTypeDep);
				}
			});
		}

		let obj = { [activity.Id]: actCatAndActTypeDep };
		pfrDependencyBasedOnActCatAndType.push(obj);
	});
	return pfrDependencyBasedOnActCatAndType;
}
function fetchPFRPicklistFields(fldname, scontrolvalues, sfieldcompletevalues, controllingFieldvalue) {
	let checkDuplicate = [];
	let activityPickListValues = {};
	try {
		for (let i = 0; i < controllingFieldvalue.length; i++) {
			let ParPickField = [];
			let controllingValue = scontrolvalues[controllingFieldvalue[i]];//binary value
			sfieldcompletevalues.forEach(item => {
				if (item?.validFor.includes(controllingValue) && !checkDuplicate.includes(item.value)) {
					if (item.value.includes('&amp;') && item.label.includes('&amp;')) {
						item.label = item.label.replaceAll('&amp;', '&');
						item.value = item.value.replaceAll('&amp;', '&');
					}
					ParPickField.push({
						class: "optionClass", label: item.label, value: item.value
					});
					checkDuplicate.push(item.value);
				}
			})

			if (ParPickField.length > 0) {
				if (fldname == "Core_MDF_Activity_Category_Type__c") {
					ParPickField.forEach(item => {
						item.label = item.label.replaceAll('&gt;', '>');
						item.value = item.value.replaceAll('&gt;', '>');
					})
					activityPickListValues["Core_MDF_Activity_Category_Type__c"] = ParPickField;
				} else {
					activityPickListValues[fldname] = ParPickField;
				}
			}
		}

	} catch (error) {
		console.error('Error in fetchPicklistFields' + error);
	}
	return activityPickListValues;
}
export function valMandateInpFldsOnActivity(activityRecords, context, compRef) {
	let activityTypedependentFields = compRef.pfrIPAActCatAndTypeDepFlds.split(',');
	let dynamicDependentFields = ['Core_MDF_Activity_SubType_nm__c', 'Core_MDF_Event_Name_nm__c'];
	const activityList = JSON.parse(JSON.stringify(activityRecords));
	let dependentValues = [];
	activityList && activityList.forEach(activity => {
		let areMandateFieldsEmpty = false;
		activity.areMandateFieldsEmpty = areMandateFieldsEmpty;
		let fieldListWithEmptyValue = [];
		compRef.pfrIPALovFields.split(',').forEach(pfrFld => {
			let selectedValues = [];
			if (checkForUndefinedEmptyAndNull(activity[pfrFld]) && !Array.isArray(activity[pfrFld])) {
				if (activityTypedependentFields.includes(pfrFld)) {
					let index = compRef.pfrDependencyBasedOnActCatAndType.findIndex(act => Object.keys(act)[0] === activity.Id);
					dependentValues = Object.values(compRef.pfrDependencyBasedOnActCatAndType[index])[0];
				} else {
					dependentValues = compRef.pfrDependencyBasedOnFocusArea;
				}
				selectedValues = activity[pfrFld].split(';');//brand
				const dupSelectedVaues = checkForUndefinedEmptyAndNull(selectedValues) && selectedValues != [] && selectedValues.length > 0 ? [...selectedValues] : '';
				selectedValues && selectedValues.forEach(selVal => {//A, B, C
					let availableOptObj = dependentValues.find(depVal => checkForUndefinedEmptyAndNull(depVal) && depVal != [] && depVal != {} && Object.keys(depVal)[0] == pfrFld);//key value pair - {key : fld name, value : array of picklist values}
					if (checkForUndefinedEmptyAndNull(availableOptObj) && Object.keys(availableOptObj).length > 0) {
						let availableOptions = availableOptObj[pfrFld];//26 brand values
						let availData = checkForUndefinedEmptyAndNull(availableOptions) && availableOptions?.filter(availOpt => availOpt.value == selVal);//if A is present in those 26 brand values
						if (availData.length == 0) {
							let selIndex = dupSelectedVaues?.findIndex(sel => sel == selVal);
							dupSelectedVaues?.splice(selIndex, 1); //a, b, c 1. a => b,c
							if (checkForUndefinedEmptyAndNull(dupSelectedVaues) && dupSelectedVaues.length == 0) {
								activity[pfrFld] = '';
							} else {
								let currentSelValues = dupSelectedVaues.join(';');
								activity[pfrFld] = currentSelValues;
							}
							if ((activity[pfrFld].length == 0 || !checkForUndefinedEmptyAndNull(activity[pfrFld]))
								&& pfrFld != 'Core_MDF_EcosystemPartner_nm__c') {
								areMandateFieldsEmpty = true;
								fieldListWithEmptyValue.push(pfrFld);
							}
						}

					}
				});
			} else {
				if (pfrFld !== 'Core_MDF_EcosystemPartner_nm__c' && (((context === 'activitySelection' || context === 'save')
					&& activity['fieldListWithEmptyValue']?.includes(pfrFld)) ||
					(context === 'load' && !dynamicDependentFields?.includes(pfrFld)))) {
					areMandateFieldsEmpty = true;
					fieldListWithEmptyValue.push(pfrFld);
				}
			}
		});
		activity.areMandateFieldsEmpty = areMandateFieldsEmpty;
		activity.fieldListWithEmptyValue = fieldListWithEmptyValue;
	});
	return activityList;
}
export function prepActClassificationMapBasedOnActType(customPicValDepForActClassification) {
	let actTypeToClassificationMap = new Map();
	try {
		let activityClassificationDep = customPicValDepForActClassification;
		if (checkForUndefinedEmptyAndNull(activityClassificationDep) && activityClassificationDep != {}
			&& Object.keys(activityClassificationDep).length) {
			let contValues = activityClassificationDep.controllerValues;
			if (checkForUndefinedEmptyAndNull(contValues) && contValues != {} && Object.keys(contValues).length) {
				Object.keys(contValues).forEach(function (key) {
					let actClassifiDepvalues = activityClassificationDep.values;
					if (checkForUndefinedEmptyAndNull(actClassifiDepvalues) && actClassifiDepvalues.length) {
						for (let index = 0; index < actClassifiDepvalues.length; index++) {
							if (actClassifiDepvalues[index].validFor.includes(contValues[key])) {
								actTypeToClassificationMap.set(key, actClassifiDepvalues[index].value);
								break;
							}
						}
					}
				});
			}
		}
	} catch (exception) {
		console.log('Error occured in prepActClassificationMapBasedOnActType:Core_MDF_Create_Campaign_helper ', exception);
	}
	return actTypeToClassificationMap;
}
export function handleDateChange(event, compRef) {
	compRef.selectPartnerBudgetTypeWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
	let endDateCmp = compRef.template.querySelector(".dateValidation");
	let startDateCmp = compRef.template.querySelector(".startDateValidation");
	let memberVisibilityDateCmp = compRef.template.querySelector(".memberVisibilityDate");
	if (memberVisibilityDateCmp != null) {
		compRef.memberVisibilityValid = false;
	}
	console.log('@@@handleDateChange -', event.target.name);
	if (event.target.name == 'StartDate') {
		//const todayDate = new Date().toISOString().split('T')[0];
		const prevStartDate = compRef.campaignFieldValue["StartDate"];
		compRef.campaignFieldValue["StartDate"] = event.target.value;
		compRef.startYearOfCampaign = new Date(compRef.campaignFieldValue["StartDate"]).getUTCFullYear();

		console.log('@@@VS compRef.userTodayDate', compRef.userTodayDate);
		console.log('@@@VS compRef.campaignFieldValue["StartDate"] ', compRef.campaignFieldValue["StartDate"]);
		console.log('@@@VS compRef.campaignFieldValue["StartDate"] < compRef.userTodayDate', compRef.campaignFieldValue["StartDate"] < compRef.userTodayDate);

		if (compRef.recordTypeDeveloperName === Core_MDF_Co_GTM_RecordType && !compRef.isCommunity) {
			if (compRef.campaignFieldValue["StartDate"] < compRef.userTodayDate && ((prevStartDate >= compRef.userTodayDate || !prevStartDate) || (compRef.mode == 'edit' && !compRef.startDateChangedOnce))) {
				compRef.isStartDateInPast = true;
				compRef.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = true;
				if (compRef.mode == 'edit' && !compRef.startDateChangedOnce && checkForUndefinedEmptyAndNull(compRef.campaignFieldValue["Core_MDF_Reason_for_Back_Dating_Nm__c"])) {
					compRef.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = compRef.campaignFieldValue["Core_MDF_Reason_for_Back_Dating_Nm__c"] == 'Other' ? true : false;
				} else {
					compRef.campaignFieldValue["Core_MDF_Reason_for_Back_Dating_Nm__c"] = '';
					compRef.campaignFieldValue["Core_MDF_Other_Reason_Name_txt__c"] = '';
					compRef.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = false;
				}
			} else if (compRef.campaignFieldValue["StartDate"] >= compRef.userTodayDate && (prevStartDate < compRef.userTodayDate || !prevStartDate)) {
				compRef.isStartDateInPast = false;
				compRef.campaignFieldVisibility["Core_MDF_Reason_for_Back_Dating_Nm__c"] = false;
				compRef.campaignFieldValue["Core_MDF_Reason_for_Back_Dating_Nm__c"] = '';
				compRef.campaignFieldVisibility["Core_MDF_Other_Reason_Name_txt__c"] = false;
				compRef.campaignFieldValue["Core_MDF_Other_Reason_Name_txt__c"] = '';
			}
		}
		if (compRef.validOutcomeMetricRecordType.includes(compRef.recordTypeDeveloperName)) {
			console.log('startdate:', compRef.campaignFieldValue["StartDate"]);
			console.log('startdate1:', compRef.campaignFieldValue["StartDate"] == null);
			console.log('optinvalindate:', compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]);
			console.log('propbasedInd:', compRef.proposalBasedIndicatorCamp);
			console.log('actList:', (checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0));
			console.log('mode:', compRef.mode);
			if (compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] && compRef.mode == 'edit' && (compRef.campaignFieldValue["StartDate"] < dateJune2025 || compRef.campaignFieldValue["StartDate"] == null) && checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0 && compRef.recordTypeDeveloperName == Core_MDF_IPA_RecordType) { //Ealay added optin check, 
				const dateObj = new Date(dateJune2025);
				const formattedDate = dateObj.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
				const errorMessage = `${startDateErrorForOutcome} ${formattedDate}.`;
				startDateCmp.setCustomValidity(errorMessage);
				startDateCmp.reportValidity();
				compRef.datevalid = false;
				compRef.skipOutcomeFieldUpdate = true;
			}else if(compRef.recordTypeDeveloperName == Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp && checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0 && compRef.mode == 'edit' && compRef.campaignFieldValue["StartDate"] >= campaignIPAOutcomeConfigureDate && !compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]){
				startDateCmp.setCustomValidity(blockStartDateChangeForNonOutcome);
				startDateCmp.reportValidity();
				compRef.datevalid = false;
				compRef.skipOutcomeFieldUpdate = true;
			}
			else {
				compRef.skipOutcomeFieldUpdate = false;
				startDateCmp.setCustomValidity("");
				startDateCmp.reportValidity();
				updateOutcomeFieldVisibility(compRef.campaignFieldValue["StartDate"], compRef);
			}
			compRef.validateOutcomeError();//14751
			if(compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName){
				compRef.validateActivityCategory();
			}
		}
		compRef.startDateChangedOnce = true;

	} else if (event.target.name == 'EndDate') {
		compRef.campaignFieldValue["EndDate"] = event.target.value;
	} else if (event.target.name == 'Core_MDF_External_Visibility_Date__c') {
		compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] = event.target.value;
	}

	let strtOfDate = new Date(compRef.campaignFieldValue["StartDate"]);
	let yearOfstrtDate = strtOfDate.getUTCFullYear();
	let endOfDate = new Date(compRef.campaignFieldValue["EndDate"]);
	let yearOfEndDate = endOfDate.getUTCFullYear();
	if ((compRef.campaignFieldValue["StartDate"] != '' && compRef.campaignFieldValue["StartDate"] != undefined && compRef.campaignFieldValue["StartDate"] != null) &&
		(compRef.campaignFieldValue["EndDate"] != '' && compRef.campaignFieldValue["EndDate"] != undefined && compRef.campaignFieldValue["EndDate"] != null)) {
		if (compRef.campaignFieldValue["EndDate"] < compRef.campaignFieldValue["StartDate"]) {
			endDateCmp.setCustomValidity(campaignEndDateValidation);
			endDateCmp.reportValidity();
			compRef.datevalid = false;
			compRef.showAvailableBudgets = false;
			compRef.showCampaignBudgets = false;
		} else if (compRef.recordTypeDeveloperName != Core_MDF_Co_GTM_RecordType && (yearOfEndDate - yearOfstrtDate) >= 2) {
			endDateCmp.setCustomValidity(campaignSpanYearsValidation);
			endDateCmp.reportValidity();
			compRef.datevalid = false;
			compRef.showAvailableBudgets = false;
			compRef.showCampaignBudgets = false;
		} else if (compRef.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType && (yearOfEndDate - yearOfstrtDate) >= 3) {
			endDateCmp.setCustomValidity(coGTMCampaignSpanYearsValidation);
			endDateCmp.reportValidity();
			compRef.datevalid = false;
			compRef.showAvailableBudgets = false;
		} else {
			endDateCmp.setCustomValidity("");
			endDateCmp.reportValidity();
			if (memberVisibilityDateCmp != null) {
				memberVisibilityDateCmp.setCustomValidity("");
				memberVisibilityDateCmp.reportValidity();
			}
			compRef.datevalid = true;
		}
	}

	if ((compRef.campaignFieldValue["StartDate"] != '' && compRef.campaignFieldValue["StartDate"] != undefined && compRef.campaignFieldValue["StartDate"] != null) &&
		(compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] != '' && compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] != undefined && compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] != null) && memberVisibilityDateCmp != null) {
		if (compRef.campaignFieldValue["Core_MDF_External_Visibility_Date__c"] > compRef.campaignFieldValue["StartDate"]) {
			memberVisibilityDateCmp.setCustomValidity("Campaign Member Visibility Date must be no later than Campaign Start Date.");
			memberVisibilityDateCmp.reportValidity(); compRef.datevalid = false; compRef.showAvailableBudgets = false; compRef.showCampaignBudgets = false;
		} else {
			if (memberVisibilityDateCmp != null) { memberVisibilityDateCmp.setCustomValidity(""); memberVisibilityDateCmp.reportValidity(); }
			compRef.datevalid = true;
		}
	}
	if (event.target.name == 'StartDate' && (compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType || compRef.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType)) {
		if ((compRef.campaignFieldValue["StartDate"] != '' && compRef.campaignFieldValue["StartDate"] != undefined) && (compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != '' && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != undefined && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != null)) {
			let budgetType = compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"];
			let restrictStartDateEdit = compRef.setSupportLegacyProgramField(budgetType, compRef.startYearOfCampaign, event.target.name);
			if (restrictStartDateEdit) {
				startDateCmp.setCustomValidity(restrictStartDateUpdate);
				startDateCmp.reportValidity();
				compRef.campaignFieldDisabled['Core_MDF_Opal_Budget_Type_Txt__c'] = true;
				compRef.datevalid = false;
				//compRef.showAvailableBudgets = false;
				//compRef.showCampaignBudgets = false;
			} else {
				startDateCmp.setCustomValidity('');
				startDateCmp.reportValidity();
				compRef.campaignFieldDisabled['Core_MDF_Opal_Budget_Type_Txt__c'] = false;
				compRef.datevalid = true;
				//compRef.showAvailableBudgets = true;
				//compRef.showCampaignBudgets = true;
			}
		}
	}
	//aditya
	if (event.target.name == 'StartDate' && compRef.isCommunity && compRef.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType && (compRef.campaignFieldValue["StartDate"] != '' && compRef.campaignFieldValue["StartDate"] != undefined && compRef.campaignFieldValue["StartDate"] != null)) {
		if (compRef.campaignFieldValue["StartDate"] < compRef.userTodayDate) {
			startDateCmp.setCustomValidity(coGTMCampaignStartDateValidation);
			startDateCmp.reportValidity();
			compRef.datevalid = false;
			console.log('@@@Inside helper save Start Date', this.isPastDatedCampaign);
		}
		else {
			compRef.datevalid = true;
			compRef.isPastDatedCampaign = false;
		}
	}

	if ((compRef.campaignFieldValue["Core_MDF_Account__c"] != '' && compRef.campaignFieldValue["Core_MDF_Account__c"] != undefined && compRef.campaignFieldValue["Core_MDF_Account__c"] != null) &&
		(compRef.campaignFieldValue["StartDate"] != '' && compRef.campaignFieldValue["StartDate"] != undefined && compRef.campaignFieldValue["StartDate"] != null) &&
		(compRef.campaignFieldValue["EndDate"] != '' && compRef.campaignFieldValue["EndDate"] != undefined && compRef.campaignFieldValue["EndDate"] != null) &&
		(compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != '' && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != undefined && compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"] != null) &&
		compRef.datevalid) {
		compRef.setCCFDCFFields(compRef.campaignFieldValue["Core_MDF_Opal_Budget_Type_Txt__c"]);
		//Instead of setCCFDCFFields => move (single budget auto selection code) to a separate method
	}
	if ((compRef.mode == 'clone') && (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp) && (event.target.name == 'StartDate' || event.target.name == 'EndDate') && (compRef.activityListClone.length > 0)) {
		compRef.validateCampaignDateRangeError('dateChange');
	}
	if ((event.target.name == 'StartDate' || event.target.name == 'EndDate') && (compRef.datevalid)) {
		compRef.isDateChanged = true;
	}
	
	//CCF-DCF-'Outcome-based campaigns must start on or after January 1, 2026' error to be displayed when outcome based campaign's with activity start date is changed to <1 Jan 2026. 
	if (compRef.mode == 'edit' && (compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName /*|| compRef.recordTypeDeveloperName == rmfRecTypeName*/) && compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] && event.target.name == 'StartDate' && (compRef.campaignFieldValue["StartDate"] < campaignOutcomeVisibilityDateCCF_DCF_RMF || compRef.campaignFieldValue["StartDate"] == null) && (checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0)) {
		const dateObj = new Date(campaignOutcomeVisibilityDateCCF_DCF_RMF);
		const formattedDate = dateObj.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
		const errorMessage = `${startDateErrorForOutcome} ${formattedDate}.`;
		startDateCmp.setCustomValidity(errorMessage);
		startDateCmp.reportValidity();
		compRef.datevalid = false;
		compRef.skipOutcomeFieldUpdate = true;
	}
	//16406
	if (compRef.mode == 'edit' && (compRef.recordTypeDeveloperName == rmfRecTypeName) && compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] && event.target.name == 'StartDate' && (compRef.campaignFieldValue["StartDate"] < campaignOutcomeVisibilityDate_RMF || compRef.campaignFieldValue["StartDate"] == null) && (checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0)) {
		const dateObj = new Date(campaignOutcomeVisibilityDate_RMF);
		const formattedDate = dateObj.toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' });
		const errorMessage = `${startDateErrorForOutcome} ${formattedDate}.`;
		startDateCmp.setCustomValidity(errorMessage);
		startDateCmp.reportValidity();
		compRef.datevalid = false;
		compRef.skipOutcomeFieldUpdate = true;
	}

	compRef.validateIPAStartDateError();
	console.log('@@@HandleDate changes end');
}

export function updateOutcomeFieldVisibility(startDate, compRef) {
	//Ealay
	let shouldShowOutcomeFieldValue;
	//const dateJune2025 = '2025-06-29';
	//const dateDCFCCFRMF ='2025-10-01';// Ealaya TWC3117-14432 changes
	//AJ start
	//const dateJan2026 = '2026-01-01';
	if(compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp && startDate >= campaignIPAOutcomeConfigureDate){
		shouldShowOutcomeFieldValue= true;
	} else if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) { //Aj End
		shouldShowOutcomeFieldValue= startDate >= dateJune2025; 
	}else if (validOutcomeMetricRecordTypeWithOutIPA.includes(compRef.recordTypeDeveloperName) && checkForUndefinedEmptyAndNull(startDate)){
	  	if(compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] && checkForUndefinedEmptyAndNull(compRef.activityListEdit) && compRef.activityListEdit.length > 0){//14753
			shouldShowOutcomeFieldValue = true;
		}
		else{
			shouldShowOutcomeFieldValue = startDate >= dateOct2025; //2025-10-01 Oct 
		}
	}
	
	const shouldShowOutcomeField = shouldShowOutcomeFieldValue;
	if (compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType) {
		compRef.campaignFieldVisibility["Core_MDF_CampOutcomeOpt_In_Ind__c"] = shouldShowOutcomeField;
		//AJ start
		if(startDate >= campaignIPAOutcomeConfigureDate && compRef.proposalBasedIndicatorCamp && (!checkForUndefinedEmptyAndNull(compRef.activityListEdit) || compRef.activityListEdit.length == 0)){
			console.log('--inside after Jan--');
			compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = true;
			console.log('optinvalue::', compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"]);
			compRef.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = true;
			compRef.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = true;
			compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = true;
			compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = true; //aditya
			//Aditya TWC3117-16962
			compRef.filterOtherFromOutcomeMetric();
		}else if (startDate >= dateOct2025) { //Aj End
			console.log('--inside after october--');
			//compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false; //AJ
			//compRef.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false; //AJ
			compRef.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = true;
			compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = true;
			compRef.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = false;
			compRef.campaignFieldValue["Core_MDF_Key_Performance_Indicator__c"] = null;
			compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = true; //aditya
		} else if (compRef.campaignFieldValue["StartDate"] >= dateJune2025 && compRef.campaignFieldValue["StartDate"] < dateOct2025 && compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] == false) {
			console.log('--inside between june and october--');
			//compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false; //AJ
			//compRef.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false; //AJ
			compRef.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = false;
			compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = false;
			compRef.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = null;
			compRef.editedOutcomeData = {};
			compRef.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = true;
			compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = false;
			compRef.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
			compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = false; //aditya
			compRef.campaignFieldValue["Core_MDF_Other_Outcome_Criteria_txt__c"] = null; //aditya
		}
	} else if (validOutcomeMetricRecordTypeWithOutIPA.includes(compRef.recordTypeDeveloperName)) { //DCF, CCF RMF
		//Ealaya TWC3117-14432 changes
		console.log('Test updateOutcomeFieldVisibility');
		if(/*startDate >= dateDCFCCFRMF &&*/ (startDate < campaignOutcomeVisibilityDateCCF_DCF_RMF && (compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName)) || (startDate < campaignOutcomeVisibilityDate_RMF && compRef.recordTypeDeveloperName == rmfRecTypeName)){//14752 , 16406
			if(!checkForUndefinedEmptyAndNull(compRef.activityListEdit) || compRef.activityListEdit.length == 0){
				compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false;
				//14754
				Object.keys(compRef.editedOutcomeData).forEach(key => {
					compRef.editedOutcomeData[key].baselineQuantity = null;
				});
			}
			compRef.campaignFieldVisibility["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false;
			compRef.rows = Object.values(compRef.editedOutcomeData);
		}else if((startDate >= campaignOutcomeVisibilityDateCCF_DCF_RMF && (compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName)) || (startDate >= campaignOutcomeVisibilityDate_RMF && compRef.recordTypeDeveloperName == rmfRecTypeName)){ // 16406
			compRef.campaignFieldVisibility["Core_MDF_CampOutcomeOpt_In_Ind__c"] = true;
		}
		//Ealaya TWC3117-14432 changes
		//compRef.campaignFieldVisibility["Core_MDF_CampOutcomeOpt_In_Ind__c"] = (startDate >= dateDCFCCFRMF) ? true : (startDate >= campaignOutcomeVisibilityDateCCF_DCF_RMF && startDate < dateDCFCCFRMF) ? false : compRef.campaignFieldVisibility["Core_MDF_CampOutcomeOpt_In_Ind__c"];
		
	}
	console.log('--outside undef--');
	//Ealay
	if ((checkForUndefinedEmptyAndNull(shouldShowOutcomeField) && !shouldShowOutcomeField) || (compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] !== true && compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] !== false)) { //Ealay removed optin check
		console.log('--inside undef--');
		compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false;
		//14754
		Object.keys(compRef.editedOutcomeData).forEach(key => {
			compRef.editedOutcomeData[key].baselineQuantity = null;
		});
		compRef.campaignFieldValue["Core_MDF_Outcomes_nm__c"] = null;
		compRef.campaignFieldVisibility["Core_MDF_Key_Performance_Indicator__c"] = true; //only one check bocx ot this
		compRef.multipleValuesSelected = false;
		compRef.isOutcomeValid = true;
		compRef.editedOutcomeData = {};
		compRef.campaignFieldValue["Core_MDF_Other_Outcome_txt__c"] = null;
		compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_txt__c"] = false;
		compRef.outcomeBasedError = false;
		//Ealay
		compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = false;//new
		compRef.campaignFieldVisibility["Core_MDF_Other_Outcome_Criteria_txt__c"] = false;
		compRef.campaignFieldValue["Core_MDF_Other_Outcome_Criteria_txt__c"] = null;
		//IPA-Jegan
		const customEvent = new CustomEvent('outcomechange', {
			detail: { value: false }
		});
		compRef.dispatchEvent(customEvent);
	}
	if(!checkForUndefinedEmptyAndNull(compRef.activityListEdit) || compRef.activityListEdit.length == 0){
		console.log('--hp@@--');
		if(compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] == false){
			console.log('--hp1@@--');
			Object.keys(compRef.editedOutcomeData).forEach(key => {
				compRef.editedOutcomeData[key].baselineQuantity = null;
			});
			compRef.rows = Object.values(compRef.editedOutcomeData);
		}
		if(compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp && startDate < campaignIPAOutcomeConfigureDate){
			console.log('--hp2@@--');
			compRef.campaignFieldDisabled["Core_MDF_CampOutcomeOpt_In_Ind__c"] = false;
		}
	}
	if(compRef.mode == 'clone' && compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType && compRef.proposalBasedIndicatorCamp){
		const customEvent = new CustomEvent('outcomechange', {
			detail: { value: compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] }
		});
		compRef.dispatchEvent(customEvent);
	}
	// const showOutcomes = compRef.campaignFieldValue["Core_MDF_CampOutcomeOpt_In_Ind__c"] === true || shouldShowOutcomeField ; //Previous code
	// compRef.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = showOutcomes;//Ealay added optin check
	// compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = showOutcomes; 
	if (validOutcomeMetricRecordTypeWithOutIPA.includes(compRef.recordTypeDeveloperName)) {
		compRef.campaignRequiredFields["Core_MDF_Outcomes_nm__c"] = shouldShowOutcomeField;//Ealay added optin check
		compRef.campaignFieldVisibility["Core_MDF_Outcomes_nm__c"] = shouldShowOutcomeField;
	}
	compRef.setColumns();// Ealaya TWC3117-14432 changes
	//else if(compRef.recordTypeDeveloperName === Core_MDF_IPA_RecordType){}
}
export function handlePicklistDependentValueChangeEdits(pickListValuesOnChange, campFieldAPIName, labelValue, compRef) {
	let pfrFieldAPIName = compRef.cmpFieldAPINametoPFRFieldAPIName[campFieldAPIName];
	let activityValues = compRef.selectedActCatTypePicValues;
	let valuesReferencedOnActivities = new Set();
	let valuesRemovedFromCampaign = [];
	let activeAvailableOptions;
	if (campFieldAPIName === 'availableBudgetValues') {//specific to EEF as its multi select picklist
		activeAvailableOptions = compRef.availableBudgetValues;
	} else {
		activeAvailableOptions = compRef.campaignPicValues[campFieldAPIName];
	}
	valuesReferencedOnActivities = getValuesRefOnActivities(campFieldAPIName, pfrFieldAPIName, compRef);
	let removedPicklistValues = [];
	if (valuesReferencedOnActivities.size) {
		//const valuesReferencedOnActivitiesList = [...valuesReferencedOnActivities];
		valuesReferencedOnActivities.forEach(val => {
			let actVal;
			let removedVal;
			if (!pickListValuesOnChange.includes(val)) {
				if (checkForUndefinedEmptyAndNull(activeAvailableOptions) && Array.isArray(activeAvailableOptions)
					&& activeAvailableOptions.length > 0) {
					if (campFieldAPIName === 'Core_MDF_Partner_Mapping_Txt__c') {
						if (compRef.vitualCorpToNodeAcc != {} && Object.keys(compRef.vitualCorpToNodeAcc).length > 0) {
							for (const [key, value] of Object.entries(compRef.vitualCorpToNodeAcc)) {
								if (value.includes(val) && !pickListValuesOnChange.includes(key)) {
									actVal = key;
								}
							}
						}
					} else {
						actVal = val;
					}
					removedVal = (checkForUndefinedEmptyAndNull(actVal)) ? activeAvailableOptions.find(availOpt => availOpt.value == actVal) : removedVal;
				}
				if (checkForUndefinedEmptyAndNull(removedVal) && checkForUndefinedEmptyAndNull(actVal)) {
					removedVal = (checkForUndefinedEmptyAndNull(removedVal) && Object.keys(removedVal).length > 0) ? removedVal.label : actVal;
					if (!removedPicklistValues.includes(removedVal)) {
						if (campFieldAPIName == 'Core_MDF_Opal_Budget_Type_Txt__c' || campFieldAPIName == 'Core_MDF_Budget_Type_txt__c') {
							compRef.isActAssociatedBudgetTypeRemoved = true;
						}
						removedPicklistValues.push(removedVal);
					}
					valuesRemovedFromCampaign.push(actVal);
				}
			}
		});
	}
	if (valuesRemovedFromCampaign.length) {
		compRef.showErrorToast(picklistValueRemovalErrorOnEdit + ' ' + labelValue + ' - ' + removedPicklistValues, 'sticky');
		valuesRemovedFromCampaign.forEach(element => {
			if (campFieldAPIName == 'Core_MDF_Market__c') {
				if (!compRef.countryValue.includes(element)) {
					compRef.countryValue.push(element);
				}
			} else if (campFieldAPIName == 'availableBudgetValues') {
				if (!compRef.selectedCmpBudgets.includes(element)) { compRef.selectedCmpBudgets.push(element); }
			} else if ((campFieldAPIName == 'Core_MDF_Opal_Budget_Type_Txt__c' || campFieldAPIName == 'Core_MDF_Budget_Type_txt__c')
				&& (compRef.recordTypeDeveloperName == Core_MDF_IPA_RecordType || compRef.recordTypeDeveloperName == rmfRecTypeName || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType)) {
				//handle single select picklist for budget type
				if (compRef.campaignFieldValue[campFieldAPIName] !== element) {
					compRef.campaignFieldValue[campFieldAPIName] = element;
					const budgetTypeComboboxUIElement = compRef.template.querySelector('[data-name="' + campFieldAPIName + '"]');
					budgetTypeComboboxUIElement.value = element;
				}
			} else {
				if (!compRef.campaignFieldValue[campFieldAPIName].includes(element)) {
					compRef.campaignFieldValue[campFieldAPIName].push(element);
				}
			}
		});
	}
}

export function getSIOrISVAccounts(accountId, compRef, actPartOptions) {
	getSIOrISVAccount({ accountId: accountId })
		.then(result => {
			if (result != {} && Object.keys(result).length > 0) {
				let isvAccounts = [];
				for (const [key, value] of Object.entries(result)) {
					isvAccounts.push({
						label: key,
						value: value
					})
				}
				compRef.campaignPicValues['Core_MDF_Partner_Mapping_Txt__c'] = isvAccounts;
				compRef.showAvailableISVAccounts = true;
				compRef.noAvailablePartnerAccounts = false;
			}
			else {
				if (checkForUndefinedEmptyAndNull(accountId)) {
					compRef.noAvailablePartnerAccounts = true;
				} else {
					compRef.noAvailablePartnerAccounts = false;
					compRef.showAvailableBudgets = false;
					compRef.availableBudgetWarning["Core_MDF_Opal_Budget_Type_Txt__c"] = false;
				}
				compRef.showAvailableISVAccounts = false;
			}
			if (compRef.mode == 'clone') {
				compRef.campaignFieldValue['Core_MDF_Partner_Mapping_Txt__c'] = [];//empty the selected partner accounts
				compRef.selectedCmpBudgets = [];//empty the selected budgets
			} else if (compRef.mode == 'edit') {
				compRef.campaignPicValues['Core_MDF_Partner_Mapping_Txt__c'] = lovValueAdditionforEEF(compRef.campaignPicValues['Core_MDF_Partner_Mapping_Txt__c'], compRef.campaignFieldValue['Core_MDF_Partner_Mapping_Txt__c'], actPartOptions);
			}
			getpicklistSize('Core_MDF_Partner_Mapping_Txt__c', compRef);
		})
		.catch(error => {
			console.log('error in getSIOrISVAccount', error);
			compRef.campaignPicValues['Core_MDF_Partner_Mapping_Txt__c'] = [];
			compRef.showAvailableISVAccounts = false;
		})
}


export function handleISVAccountSelection(event, compRef) {
	let selectedVal = event.target.value;
	let fieldAPIName = event.target.name;
	compRef.campaignFieldValue[fieldAPIName] = selectedVal;
	compRef.handlePicklistDependentValueChange(event);
}



export function fetchCampToActPartnerData(compRef) {// Camp to ISV Mapping
	fetchCampToActPartnerRecord({ campaignId: compRef.recordId })
		.then(result => {
			let selectedISVAccountNames = [];
			let actPartOptions = [];
			let actPartners = [];
			let campToActPartners = result;
			//if (checkForUndefinedEmptyAndNull(campToActPartners) && campToActPartners !== {} && Object.keys(campToActPartners).length > 0) {
			if (checkForUndefinedEmptyAndNull(campToActPartners) && Object.keys(campToActPartners).length > 0) {
				campToActPartners.forEach(CampToActPart => {
					let selActPartAccId = CampToActPart.accountId;
					if (checkForUndefinedEmptyAndNull(selActPartAccId)) {
						compRef.showAvailableISVAccounts = true;
						selectedISVAccountNames.push(CampToActPart.accName);
						actPartners.push(selActPartAccId);
						actPartOptions.push({
							label: CampToActPart.accName,
							value: CampToActPart.accountId
						})
					}
				});
			}
			getSIOrISVAccounts(compRef.campaignFieldValue['Core_MDF_Account__c'], compRef, actPartOptions);
			if (compRef.mode == 'edit') {
				compRef.campaignFieldValue['Core_MDF_Partner_Mapping_Txt__c'] = actPartners;
			}
		})
		.catch(error => {
			console.log('error in fetchCampToActPartnerData', error);
		})
}
export function validateSelectedBudgets(compRef) {
	if (compRef.recordTypeDeveloperName == Core_MDF_CCF_RecordTypeName || compRef.recordTypeDeveloperName == Core_MDF_DCF_RecordTypeName) {
		let validBudgetTypes = [...compRef.campaignFieldValue['Core_MDF_Opal_Budget_Type_Txt__c']];
		let oldCampaignBudgetsArray = JSON.parse(JSON.stringify(compRef.campaignBudgetsForSave));
		let finalCampBudgetsArray = compRef.campaignBudgetsForSave;
		//let selectedBudgetIds = compRef.selectedCmpBudgets;
		const availableBudgetValues = JSON.parse(JSON.stringify(compRef.availableBudgetValues));//6 - MDF, MDF+, MDF, MDF+, OEM CMP, MDF
		let finalAvailBudgetVal = compRef.availableBudgetValues;//6 - MDF, MDF+, MDF, MDF+, OEM CMP, MDF
		if (checkForUndefinedEmptyAndNull(oldCampaignBudgetsArray) && oldCampaignBudgetsArray.length > 0) {
			oldCampaignBudgetsArray.forEach(campBudget => {//2 Sel - MDF+, MDF
				if (!validBudgetTypes.includes(campBudget.budgetType)) { // MDF+ - valid , skipped. MDF - invalid
					//let budgetId = campBudget.budgetId;
					let selIndex = finalCampBudgetsArray.findIndex(sel => sel.budgetId == campBudget.budgetId);
					finalCampBudgetsArray.splice(selIndex, 1);
				}
			});

			compRef.campaignBudgetsForSave = finalCampBudgetsArray;
			compRef.campaignBudgets = finalCampBudgetsArray
			if (checkForUndefinedEmptyAndNull(finalCampBudgetsArray) && finalCampBudgetsArray.length > 0) {
				compRef.showCampaignBudgets = true;
			} else {
				compRef.showCampaignBudgets = false;
			}
		}
		if (checkForUndefinedEmptyAndNull(availableBudgetValues) && availableBudgetValues.length > 0) {
			availableBudgetValues.forEach(avlBgt => {
				let availableBudgetList = avlBgt.label.split(':');
				let selectedBudget = availableBudgetList[2].trim();
				if (!validBudgetTypes.includes(selectedBudget)) {
					let selIndex = finalAvailBudgetVal.findIndex(sel => sel.label.split(':')[0] === availableBudgetList[0]);
					finalAvailBudgetVal.splice(selIndex, 1);
				}
			});
			compRef.availableBudgetValues = finalAvailBudgetVal;
			compRef.showAvailableBudgets = true;
		}
	}
}

export function getpicklistSize(fieldAPINamesList, compRef) {
	let fieldAPINamesListArr = fieldAPINamesList.split(',');
	for (var i = 0; i < fieldAPINamesListArr.length; i++) {
		let fieldValue = compRef.campaignPicValues[fieldAPINamesListArr[i]];
		if (fieldValue != null && fieldValue.length > 0 && fieldValue.length <= 3) {
			compRef.picklistSize[fieldAPINamesListArr[i]] = 3;
		} else if (fieldValue != null && fieldValue.length > 3) {
			compRef.picklistSize[fieldAPINamesListArr[i]] = 6;
		}
	}
}

export function calReimbursementAmt(compRef) {
	let reimbursementRate = '';
	if (compRef.recordTypeDeveloperName == Core_MDF_IPA_RecordType || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType) {
		reimbursementRate = compRef.finalRRrate;
	} else {
		reimbursementRate = compRef.campaignFieldValue["Core_MDF_Reimbursement_Rate__c"];
	}
	let totalCampaignCost = compRef.campaignFieldValue["Core_MDF_Total_Campaign_Cost_Amt__c"];
	compRef.campaignFieldValue.Core_MDF_Reimbursement_Amt__c = (parseInt(reimbursementRate) / 100) * parseFloat(totalCampaignCost);
}

export function getValuesRefOnActivities(campFieldAPIName, pfrFieldAPIName, compRef) {
	let valuesReferencedOnActivities = new Set();
	let activityRecordList = compRef.activityListEdit;
	if (compRef.recordTypeDeveloperName === compRef.ccfRecordType || compRef.recordTypeDeveloperName === compRef.dcfRecordType || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType) {
		if (campFieldAPIName === 'Core_MDF_Activity_Category_Type__c') {
			let actRecordeList = JSON.parse(JSON.stringify(compRef.activityListEdit));
			let pfrToUpdate = [];
			actRecordeList.forEach(element => {
				let act_Category_Typ = element['Core_MDF_ActivityCategory__c'] + '->' + element['Core_MDF_Activity_Types__c'];
				element['Activity_Category_Type'] = act_Category_Typ;
				pfrToUpdate.push(element);
			});
			activityRecordList = pfrToUpdate;
		}
	}
	activityRecordList && activityRecordList.map(activity => {
		let valuesOnIndividualActivity = activity[pfrFieldAPIName]?.split(';');
		valuesOnIndividualActivity?.map(val => {
			valuesReferencedOnActivities.add(val);
		});
	});

	return valuesReferencedOnActivities;
}

// export function getActivityFieldValues(activityList) {
//     let fieldValues = new Set();
//     if (activityList && activityList.length > 0) {
//         activityList.forEach(activity => {
//             Object.keys(activity).forEach(field => {
//                 let fieldValue = activity[field];
//                 if (typeof fieldValue === 'string' && fieldValue.trim() !== '') {
//                     let values = fieldValue.split(/\s*;\s*/);
//                     values.forEach(val => {
//                         if (val.trim()) {
//                             fieldValues.add(val.trim());
//                         }
//                     });
//                 }
//             });
//         });
//     }
//     return Array.from(fieldValues);
// }

export function retainAndUpdateCampaignBudgetsOldMap(compRef, retainPrevData, retainSelectedBudgetWithInactiveInd) {
	if (compRef.recordTypeDeveloperName == compRef.ccfRecordType || compRef.recordTypeDeveloperName == compRef.dcfRecordType || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType || compRef.recordTypeDeveloperName == Core_MDF_Co_GTM_RecordType) {
		let isBudgetDataOrBudgetRetained = false;
		let updatedCampaignBudgetsMap = new Map();

		// Retain old budgets on date change after initial load
		if (retainPrevData) {
			compRef.campaignBudgetsForSave.forEach(campaignBudgetObj => {
				if (compRef.campaignBudgetsPrevMap.has(campaignBudgetObj.budgetId)) {
					const oldData = compRef.campaignBudgetsPrevMap.get(campaignBudgetObj.budgetId);
					updatedCampaignBudgetsMap.set(campaignBudgetObj.budgetId, { ...oldData });
					isBudgetDataOrBudgetRetained = true;
				}
			});
		}

		// Add rest all current budgets which are not retained
		compRef.campaignBudgetsForSave.forEach(campaignBudgetObj => {
			if (!updatedCampaignBudgetsMap.has(campaignBudgetObj.budgetId)) {
				const { budgetId, ...rest } = campaignBudgetObj;
				updatedCampaignBudgetsMap.set(budgetId, { ...rest });
			}
		});

		// Retain Selected Budgets With Inactive Indicator as False in case of date change
		if (retainSelectedBudgetWithInactiveInd) {
			compRef.campaignBudgetsPrevMap.forEach((value, key) => {
				if (!updatedCampaignBudgetsMap.has(key) && compRef.selectedCmpBudgets.includes(key)) {
					updatedCampaignBudgetsMap.set(key, value);
					isBudgetDataOrBudgetRetained = true;
				}
			});
		}

		// Replace the prev data map with the new map of data
		compRef.campaignBudgetsPrevMap.clear();
		updatedCampaignBudgetsMap.forEach((value, key) => compRef.campaignBudgetsPrevMap.set(key, value));

		// Reassign campaignBudgetsForSave with retained and new both data
		if (isBudgetDataOrBudgetRetained) {
			compRef.campaignBudgetsForSave.length = 0;
			updatedCampaignBudgetsMap.forEach((value, key) => {
				const campaignBudgetObj = { budgetId: key, ...value };
				compRef.campaignBudgetsForSave.push(campaignBudgetObj);
			});
		}
	}
}

export function resetOrRollbackPriority2Or3(compRef, context) {
	if (compRef.recordTypeDeveloperName == compRef.ccfRecordType || compRef.recordTypeDeveloperName == compRef.dcfRecordType || compRef.recordTypeDeveloperName == Core_MDF_EEF_RecordType || compRef.recordTypeDeveloperName == rmfRecTypeName) {
		if (context == 'reset') {
			compRef.campaignFieldValue['Core_MDF_Priority_2_nm__c'] = (compRef.campaignFieldValue['Core_MDF_Priority_2_nm__c'] === 'None' ? '' : compRef.campaignFieldValue['Core_MDF_Priority_2_nm__c']);
			compRef.campaignFieldValue['Core_MDF_Priority_3_nm__c'] = (compRef.campaignFieldValue['Core_MDF_Priority_3_nm__c'] === 'None' ? '' : compRef.campaignFieldValue['Core_MDF_Priority_3_nm__c']);
		} else if (context == 'rollback') {
			compRef.campaignFieldValue['Core_MDF_Priority_2_nm__c'] = compRef.priorityValuesForRollback['Core_MDF_Priority_2_nm__c'];
			compRef.campaignFieldValue['Core_MDF_Priority_3_nm__c'] = compRef.priorityValuesForRollback['Core_MDF_Priority_3_nm__c'];
		}
	}
}

export function handlePriorityNoneValueSelection(event, compRef, priorityPerApiName, uiElementClass) {
	let priorityPerUIElement = compRef.template.querySelector(uiElementClass);
	let priorityFieldApiName = event.target.name;
	let priorityFieldValue = event.target.value;
	compRef.priorityValuesForRollback[priorityFieldApiName] = priorityFieldValue;
	if (priorityFieldValue == 'None' && compRef.campaignSource === 'Target Setting'
		&& (compRef.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_CCF_Program_Name
			|| compRef.campaignFieldValue["Core_MDF_Program__c"] === Core_MDF_DCF_Program_Name)) {
		compRef.campaignFieldValue[priorityPerApiName] = '';
		if (priorityPerApiName === 'Core_MDF_Priority_Percentage_2__c') {
			compRef.priorityPer2 = 0;
		}
		else if (priorityPerApiName === 'Core_MDF_Priority_Percentage_3__c') {
			compRef.priorityPer3 = 0;
		}
		if (priorityPerUIElement != null) {
			priorityPerUIElement.value = '';
			priorityPerUIElement.setCustomValidity('');
			priorityPerUIElement.reportValidity();
		}
		compRef.campaignFieldDisabled[priorityPerApiName] = true;
	} else {
		compRef.campaignFieldDisabled[priorityPerApiName] = (compRef.status === 'Draft') ? false : compRef.campaignFieldDisabled[priorityPerApiName];
	}
}
export function handleOEMDateChange(event, compRef) {

	if (event.target.name === 'Core_MDF_OEM_Platform_Start_Date_Dt__c') {
		compRef.campaignFieldValue["Core_MDF_OEM_Platform_Start_Date_Dt__c"] = event.target.value;
	} else if (event.target.name === 'Core_MDF_OEM_Platform_End_Date_Dt__c') {
		compRef.campaignFieldValue["Core_MDF_OEM_Platform_End_Date_Dt__c"] = event.target.value;
	}
	let endDateCmp = compRef.template.querySelector('.oemEndDate');
	let oemStartDate = compRef.campaignFieldValue["Core_MDF_OEM_Platform_Start_Date_Dt__c"];
	let oemEndDate = compRef.campaignFieldValue["Core_MDF_OEM_Platform_End_Date_Dt__c"];
	if (oemStartDate && oemEndDate) {
		if (oemEndDate < oemStartDate) {
			endDateCmp.setCustomValidity(Core_MDF_Campaign_OEM_Platform_End_Date_Validation);
			endDateCmp.reportValidity();
		}
		else {
			endDateCmp.setCustomValidity("");
			endDateCmp.reportValidity();
		}
	}

}