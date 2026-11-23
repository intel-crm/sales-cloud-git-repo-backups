import search from '@salesforce/apex/PMP_SearchUtilityNew.newSearch';
import USERLANG from '@salesforce/i18n/lang';
import { handleError } from 'c/ipaErrorServiceMarketplace';

const checkContext = () => {
  let context = '';

  if (window.location.href.match('pmp-category')) {
    context = 'pmp-category';
  } else if (window.location.href.match('pmp-partner-program')) {
    context = 'pmp-partner-program';
  } else if (window.location.href.match('pmp-partner-specialty')) {
    context = 'pmp-partner-specialty';
  } else if (window.location.href.match('pmp-partner-segment')) {
    context = 'pmp-partner-segment';
  } else if (window.location.href.match('pmp-partner-category')) {
    context = 'pmp-partner-category';
  }

  return context;
};

export default async (params = {}) => {
  let response = {};
	console.log('params123::',params);
  await search({
    requestJSON: JSON.stringify({
      ...params,
      searchType: checkContext(),
      langCode: USERLANG,
    }),
  }).then((result) => {
    response = JSON.parse(result);
  }).catch((error) => {
    handleError(error, 'ipaSearchService - search');
    throw error;
  });

  return response;
};