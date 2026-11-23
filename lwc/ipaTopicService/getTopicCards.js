/**
 * Get Topic Cards ( Partner / Product )
 *
 * @param {object} params @AuraEnabled Method Parameters
 * @param {string} params.topicId topic Id
 * @param {string} params.cardType required - can be 'partner' or 'product'
 * @param {string} params.keyword search keyword
 * @param {object} params.categories list of categories id
 * @param {object} params.specifications list of specifications id
 * @param {number} [params.page] page number for results (only used if lazy loading data)
 * @param {number} [params.perPage] per page count for results (only used if lazy loading data)
 * @returns {json} response format: <code>{ heading: '', cards: Product|Partner[], total: number }</code><br> - example:'C-Offerings' / 'C-Partners'<br>
 * @function getTopicCards
 * @memberof ipaTopicService
 *
 *
 */

import partners from '@salesforce/label/c.PMP_L2_Tab_Partners';
//import offerings from '@salesforce/label/c.PMP_Marketplace_Offerings';
//import getTopicDetails from '@salesforce/apex/PMP_SearchTopicDetailController.getTopicDetails';
import USERLANG from '@salesforce/i18n/lang';
import errorPageURL from '@salesforce/label/c.PMP_Error_Page_URL';
import { handleError } from 'c/ipaErrorServiceMarketplace';

// page and perPage are only needed if lazy loading... NOTE: MIGHT NOT NEED TO IMPLEMENT LAZY LOADING AT ALL
export default async ({
  topicId, cardType, keyword, categories, specifications, page, perPage,
}) => {
  //IPA2.0:TWC729-8114 Topics Removal/Event Removal
  /* let responseData = {};
  const requestObject = {
    topicId, langCode: USERLANG, currentPage: page, pageSize: perPage, keyword, categories, specifications, cardType,
  };
  const requestJSON = JSON.stringify(requestObject);

 /* await getTopicDetails({
    requestJSON,
  })
    .then((result) => {
      if (result.isActive === false || result.isActive === undefined) {
        window.location.href = errorPageURL;
      } else {
        let response = {};
        response = result;
        if (response.isActive !== false && response.isActive !== undefined) {
          let cards = [];
          let total = 0;
          let topicName = '';
          topicName = response.name;
          if (cardType === 'partner') {
            cards = response.partnerCards;
            total = response.partnerTotal;
          }
          if (cardType === 'product') {
            cards = response.productCards;
            total = response.productTotal;
          }
          //ipa 2.0 offerings eol
          // responseData = {
          //   heading: `${topicName} ${cardType === 'partner' ? partners : offerings}`,//?? need to check what to
          //   cards: cards,
          //   total: total,
          // };
          let heading = topicName;
          if (cardType === 'partner') {
            heading += ' ' + partners;
          }

          responseData = {
            heading: heading,
            cards: cards,
            total: total,
          };

        }
      }
    })
    .catch((error) => {
      handleError(error, 'getTopicDetails');
    });
  return Promise.resolve(responseData); */
};