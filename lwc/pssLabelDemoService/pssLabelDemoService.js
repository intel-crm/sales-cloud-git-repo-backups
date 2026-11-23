import UserLocale from '@salesforce/i18n/locale';
import returnLabels from '@salesforce/apex/PSS_CustomLabelsForLWC.customLabelsForSolDetailPage';


const labelSeparator = ':-:';

function addLabelsToStorage(labels) {
  for (const labelName in labels) {
    sessionStorage.setItem(`${UserLocale}${labelSeparator}${labelName}`, labels[labelName]);
    console.log(`Mike ${UserLocale}${labelSeparator}${labelName}`, labels[labelName]);
  }
}

function getLabelFromStorage(labelName) {
  const sessionLabelName = `${UserLocale}${labelSeparator}${labelName}`;
  return sessionStorage.getItem(sessionLabelName);
}




async function getLabelValue(labelName, labelValue) {
  console.log('Mike Locale', UserLocale);
  if (validateLabelValue(labelValue) && false) {
    console.log('Mike From LABEL');
    return labelValue;
  } else {
    let sessionLabelValue = getLabelFromStorage(labelName);
    if (validateLabelValue(sessionLabelValue)) {
      console.log('Mike From SESSION');
      return sessionLabelValue;
    } else {
      return returnLabels()
        .then((result) => {
          console.log('Mike Result', result);
          addLabelsToStorage(result);
          sessionLabelValue = getLabelFromStorage(labelName);
          if (validateLabelValue(sessionLabelValue)) {
            console.log('Mike From SESSION After SERVER');
            return sessionLabelValue;
          } else {
            // Handle error
          }
        })
        .catch((error) => {
          // Handle Error
          console.log('Mike Catch', error);
        });
    }
  }
}


function validateLabelValue(labelValue) {
  if (labelValue === null || labelValue === undefined || labelValue === '') {
    return false;
  }
  return true;
}


export default {
  getLabelValue
}