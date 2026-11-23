/**
 * Get Topic Details (for Marquee)
 *
 * @param {object} params @AuraEnabled Method Parameters
 * @param {string} params.topicId topic Id
 * @returns {object} Topic Response, includes details for Marquee
 * @function getTopicDetails
 * @memberof ipaTopicService
 *
 */

//import getTopicMarquee from '@salesforce/apex/PMP_SearchTopicDetailController.getTopicMarqueeDetails';
import errorPageURL from '@salesforce/label/c.PMP_Error_Page_URL';
import USERLANG from '@salesforce/i18n/lang';
import { handleError } from 'c/ipaErrorServiceMarketplace';

export default async () => {
  //IPA2.0:TWC729-8114 Topics Removal/Event Removal
  /* const url = window.location.href;
  const splits = url.indexOf('topic/') !== -1 ? url.split('topic/') : [];
  const topicId = splits.length > 0 ? splits[1].split('/')[0] : '';

  let response = {};
  /*await getTopicMarquee({ topicId, langCode: USERLANG })
    .then((result) => {
      if (result.isActive === false || result.isActive === undefined) {
        window.location.href = errorPageURL;
      } else {
        response = result;
      }
    })
    .catch((error) => {
      handleError(error, 'getTopicMarquee');
    });
  return Promise.resolve(response); */
};