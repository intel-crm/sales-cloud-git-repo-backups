const API_NAME = 'IPA Marketplace @AuraEnabled';

export const log = (value, apiName, params) => {
    console.group(`%c🚀 API Call using api: ${API_NAME}%c - ${apiName}`, 'color: #1798c1; font-weight: bold', 'font-weight: bold');
    console.log('%cAPI Params:    ', 'color: #1798c1; font-weight: bold', params.length === 1 ? params[0] : params);
    console.log('%cAPI Response:  ', 'color: #1798c1; font-weight: bold', value);
    console.groupEnd();
    return value;
}

export const logError = (err, apiName, params) => {
    console.group(`%c🚀 API Call ERROR! Using api: ${API_NAME}%c - ${apiName}`, 'color: #ac0000; font-weight: bold', 'font-weight: bold');
    console.log('%cAPI Params:    ', 'color: #1798c1; font-weight: bold', params.length === 1 ? params[0] : params);
    console.log('%cAPI Response:  ', 'color: #1798c1; font-weight: bold', err);
    console.groupEnd();
    return null;
}