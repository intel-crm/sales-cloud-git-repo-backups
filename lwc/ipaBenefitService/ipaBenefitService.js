/**
 * Benefit Service
 * @namespace ipaBenefitService
 * @example
 * ...TODO
 */

import getBenefits from './getBenefits';
import { getPartnerMessages, markMessageAsRead, markMessageAsDelete } from './partnerMessage';
import getPartnerQuickLinks from './getPartnerQuicklinks';
import getBenefitProfile from './getBenefitProfile';
import getSupportFooter from './getSupportFooter';
import { getPartnerMessagesViewAll, markMessageAsReadViewAll } from './partnerMessageViewAll';

export default {
    getBenefits,
    getBenefitProfile,
    getSupportFooter,
    getPartnerMessages,
    getPartnerMessagesViewAll,
    getPartnerQuickLinks,
    markMessageAsRead,
    markMessageAsDelete
}